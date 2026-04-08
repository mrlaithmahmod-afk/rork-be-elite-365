import SwiftUI
import SwiftData

@Observable
class DashboardViewModel {
    var profile: PlayerProfile?
    var latestCheckIn: DailyCheckIn?
    var recentCheckIns: [DailyCheckIn] = []
    var solutionCards: [SolutionCard] = []
    var recommendedDrill: Drill?
    var drillCompletionsToday: Int = 0
    var confidenceState: ConfidenceState = .stable
    var dailyTasks: [DailyTask] = []
    var completedTaskIDs: Set<String> = []
    var upcomingMatch: MatchEvent?

    var currentMentalPrep: Double { profile?.mentalPrepScore ?? 50 }
    var currentPractice: Double { profile?.practiceScore ?? 50 }
    var currentPerformance: Double { profile?.performanceScore ?? 50 }
    var currentRStage: RStage { profile?.currentRStage ?? .reset }
    var currentEnergyLoop: EnergyLoopState { profile?.currentEnergyLoop ?? .neutral }
    var playerName: String { profile?.name ?? "" }
    var playerGender: Gender { profile?.gender ?? .preferNotToSay }

    var primaryActionTitle: String {
        if confidenceState == .spiral { return "Recovery Protocol" }
        if currentEnergyLoop == .negative { return "Reset Now" }
        switch currentRStage {
        case .reset: return "Reset Now"
        case .regroup: return "Regroup Plan"
        case .refocus: return "Refocus Drill"
        }
    }

    var primaryActionSubtitle: String {
        if confidenceState == .spiral {
            return "Confidence spiral detected. Start the recovery protocol."
        }
        if currentEnergyLoop == .negative {
            return "Break the negative spiral. Start with a controlled reset."
        }
        return currentRStage.detail
    }

    var energyExplanation: String {
        switch currentEnergyLoop {
        case .positive: return "Mental preparation is driving focused practice and confident performance."
        case .negative: return "Current patterns are draining confidence. Time to break the cycle."
        case .neutral: return "Your energy flow is balanced. Small adjustments can shift momentum."
        }
    }

    func loadData(context: ModelContext) {
        let descriptor = FetchDescriptor<PlayerProfile>(sortBy: [SortDescriptor(\.createdAt, order: .reverse)])
        profile = try? context.fetch(descriptor).first

        let checkInDescriptor = FetchDescriptor<DailyCheckIn>(sortBy: [SortDescriptor(\.date, order: .reverse)])
        recentCheckIns = (try? context.fetch(checkInDescriptor)) ?? []

        let cardDesc = FetchDescriptor<SolutionCard>(sortBy: [SortDescriptor(\.createdAt, order: .reverse)])
        solutionCards = (try? context.fetch(cardDesc)) ?? []

        if let latest = recentCheckIns.first {
            latestCheckIn = latest
            profile?.mentalPrepScore = latest.mentalPrepRating
            profile?.practiceScore = latest.practiceRating
            profile?.performanceScore = latest.performanceRating
            profile?.currentEnergyLoop = latest.energyLoop
            profile?.currentRStage = latest.rStage
            profile?.updatedAt = Date()

            updateEnergyLoop()
        }

        confidenceState = ConfidenceRecoveryEngine.assess(checkIns: recentCheckIns, solutionCards: solutionCards)

        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: Date())
        let drillDesc = FetchDescriptor<DrillCompletion>(
            predicate: #Predicate { $0.completedAt >= startOfDay }
        )
        let todayCompletions = (try? context.fetch(drillDesc)) ?? []
        drillCompletionsToday = todayCompletions.count

        let allCompletions = (try? context.fetch(FetchDescriptor<DrillCompletion>())) ?? []

        let matchDesc = FetchDescriptor<MatchEvent>(
            predicate: #Predicate { $0.date >= startOfDay },
            sortBy: [SortDescriptor(\.date)]
        )
        upcomingMatch = (try? context.fetch(matchDesc))?.first

        if let profile {
            recommendedDrill = RecommendationEngine.suggestedDrill(for: profile, completions: allCompletions)

            dailyTasks = RecommendationEngine.generateDailyTasks(
                profile: profile,
                checkIns: recentCheckIns,
                completions: allCompletions,
                solutionCards: solutionCards,
                upcomingMatch: upcomingMatch,
                confidenceState: confidenceState
            )
        }

        let completedDrillIDs = Set(todayCompletions.map(\.drillID))
        completedTaskIDs = Set(dailyTasks.filter { task in
            if let drillID = task.drillID, completedDrillIDs.contains(drillID) { return true }
            if task.taskType == .checkIn, latestCheckIn != nil, Calendar.current.isDateInToday(latestCheckIn!.date) { return true }
            return false
        }.map(\.id))
    }

    private func updateEnergyLoop() {
        let recent = Array(recentCheckIns.prefix(5))
        guard recent.count >= 3 else { return }

        let avgConfidence = recent.map(\.confidenceLevel).reduce(0, +) / Double(recent.count)
        let avgTriangle = recent.map(\.triangleAverage).reduce(0, +) / Double(recent.count)
        let negativeCount = recent.filter { $0.energyLoop == .negative }.count

        if avgConfidence < 40 && negativeCount >= 3 {
            profile?.currentEnergyLoop = .negative
        } else if avgConfidence >= 60 && avgTriangle >= 55 {
            profile?.currentEnergyLoop = .positive
        }
    }
}
