import SwiftUI
import SwiftData

@Observable
class InsightsViewModel {
    var checkIns: [DailyCheckIn] = []
    var solutionCards: [SolutionCard] = []
    var drillCompletions: [DrillCompletion] = []
    var profile: PlayerProfile?

    var hasEnoughData: Bool { checkIns.count >= 2 || solutionCards.count >= 1 }

    var confidenceTrend: [Double] {
        Array(checkIns.prefix(14).reversed().map(\.confidenceLevel))
    }

    var triangleHistory: [(mental: Double, practice: Double, performance: Double)] {
        Array(checkIns.prefix(7).reversed().map { ($0.mentalPrepRating, $0.practiceRating, $0.performanceRating) })
    }

    var positiveFlowCount: Int {
        checkIns.prefix(14).filter { $0.energyLoop == .positive }.count
    }

    var negativeFlowCount: Int {
        checkIns.prefix(14).filter { $0.energyLoop == .negative }.count
    }

    var recoverySpeed: String {
        let recentCards = Array(solutionCards.prefix(5))
        guard recentCards.count >= 2 else { return "Not enough data yet." }
        let avgIntensity = recentCards.map(\.emotionIntensity).reduce(0, +) / Double(recentCards.count)
        if avgIntensity <= 4 {
            return "Strong. You are processing setbacks with lower emotional intensity."
        } else if avgIntensity <= 7 {
            return "Developing. Emotional responses are moderate. Continue training the Reset stage."
        }
        return "High intensity responses detected. Prioritise the 30-second breathing reset before your next match."
    }

    var mostSkippedR: RStage? {
        let rCounts = Dictionary(grouping: solutionCards, by: \.skippedR)
        return rCounts.max(by: { $0.value.count < $1.value.count })?.key
    }

    var mostEffectiveCards: [SolutionCard] {
        solutionCards.filter { $0.usageCount > 0 }.sorted { $0.usageCount > $1.usageCount }.prefix(3).map { $0 }
    }

    var pinnedCards: [SolutionCard] {
        solutionCards.filter(\.isPinned)
    }

    var bookmarkedCards: [SolutionCard] {
        solutionCards.filter(\.isBookmarked)
    }

    var totalDrillsCompleted: Int { drillCompletions.count }

    var weeklyDrillCount: Int {
        let weekAgo = Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date()
        return drillCompletions.filter { $0.completedAt >= weekAgo }.count
    }

    var weeklyPattern: String {
        guard hasEnoughData else { return "Complete more sessions to reveal patterns." }
        if let skipped = mostSkippedR {
            return "You most frequently skip the \(skipped.rawValue) stage. Focus on building this into your response sequence."
        }
        return "Keep logging to uncover deeper patterns in your mental game."
    }

    var weeklyImprovement: String {
        guard checkIns.count >= 3 else { return "More check-ins needed to track improvement." }
        let recent = Array(checkIns.prefix(3))
        let older = Array(checkIns.dropFirst(3).prefix(3))
        guard !older.isEmpty else { return "Building your baseline. Keep checking in." }

        let recentAvg = recent.map(\.triangleAverage).reduce(0, +) / Double(recent.count)
        let olderAvg = older.map(\.triangleAverage).reduce(0, +) / Double(older.count)

        if recentAvg > olderAvg + 3 {
            return "Your triangle stability is improving. Consistency in your recent sessions is paying off."
        } else if recentAvg < olderAvg - 3 {
            return "Triangle stability has dipped recently. Review your recent sessions for patterns."
        }
        return "Your performance is steady. Look for one specific area to sharpen."
    }

    var weeklyAdjustment: String {
        guard let profile else { return "" }
        return "Prioritise \(profile.trainingFocusArea.shortName) this week. Dedicate extra attention to drills that target this area."
    }

    func loadData(context: ModelContext) {
        let checkInDesc = FetchDescriptor<DailyCheckIn>(sortBy: [SortDescriptor(\.date, order: .reverse)])
        checkIns = (try? context.fetch(checkInDesc)) ?? []

        let cardDesc = FetchDescriptor<SolutionCard>(sortBy: [SortDescriptor(\.createdAt, order: .reverse)])
        solutionCards = (try? context.fetch(cardDesc)) ?? []

        let drillDesc = FetchDescriptor<DrillCompletion>(sortBy: [SortDescriptor(\.completedAt, order: .reverse)])
        drillCompletions = (try? context.fetch(drillDesc)) ?? []

        let profileDesc = FetchDescriptor<PlayerProfile>(sortBy: [SortDescriptor(\.createdAt, order: .reverse)])
        profile = try? context.fetch(profileDesc).first
    }
}
