import Foundation
import SwiftData

struct ContextBuilder {
    static func buildMemory(context: ModelContext) -> PlayerMemory {
        let profileDesc = FetchDescriptor<PlayerProfile>(sortBy: [SortDescriptor(\.createdAt, order: .reverse)])
        let profile = try? context.fetch(profileDesc).first

        let checkInDesc = FetchDescriptor<DailyCheckIn>(sortBy: [SortDescriptor(\.date, order: .reverse)])
        let checkIns = (try? context.fetch(checkInDesc)) ?? []
        let recentConfidence = Array(checkIns.prefix(7).map(\.confidenceLevel))

        let confidenceDirection: String
        if recentConfidence.count >= 3 {
            let recent = Array(recentConfidence.prefix(3))
            let older = Array(recentConfidence.dropFirst(3).prefix(3))
            let recentAvg = recent.reduce(0, +) / Double(recent.count)
            let olderAvg = older.isEmpty ? recentAvg : older.reduce(0, +) / Double(older.count)
            if recentAvg > olderAvg + 5 { confidenceDirection = "improving" }
            else if recentAvg < olderAvg - 5 { confidenceDirection = "dipping" }
            else { confidenceDirection = "stable" }
        } else {
            confidenceDirection = "not enough data"
        }

        let cardDesc = FetchDescriptor<SolutionCard>(sortBy: [SortDescriptor(\.createdAt, order: .reverse)])
        let cards = (try? context.fetch(cardDesc)) ?? []

        let skippedRCounts = Dictionary(grouping: cards, by: \.skippedR)
        let commonPattern: String
        if let mostSkipped = skippedRCounts.max(by: { $0.value.count < $1.value.count }), mostSkipped.value.count >= 2 {
            commonPattern = "Most frequently skipped stage: \(mostSkipped.key.rawValue)"
        } else {
            commonPattern = ""
        }

        let recentCardSummaries = cards.prefix(3).map { card in
            "\(card.situationType.rawValue): \(card.reframe)"
        }

        let matchDesc = FetchDescriptor<MatchEvent>(sortBy: [SortDescriptor(\.date)])
        let matches = (try? context.fetch(matchDesc)) ?? []
        let upcomingMatch = matches.first { $0.date > Date() }
        let nextMatchHours: Double? = upcomingMatch.map { $0.date.timeIntervalSince(Date()) / 3600 }

        let drillDesc = FetchDescriptor<DrillCompletion>(sortBy: [SortDescriptor(\.completedAt, order: .reverse)])
        let drills = (try? context.fetch(drillDesc)) ?? []
        let weekAgo = Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date()
        let recentDrills = drills.filter { $0.completedAt > weekAgo }

        let identity = PlayerMemory.Identity(
            name: profile?.name ?? "Athlete",
            gender: profile?.gender.rawValue ?? "Prefer not to say",
            position: profile?.position.displayName ?? "Unknown",
            level: profile?.level.rawValue ?? "Academy",
            ageBand: profile?.ageBand.rawValue ?? "19-24",
            isMinor: profile?.isMinor ?? false,
            primaryGoal: profile?.primaryGoal.rawValue ?? ""
        )

        let patterns = PlayerMemory.Patterns(
            dominantIssues: profile?.currentIssues.map(\.rawValue) ?? [],
            mainTrigger: profile?.pressureMoment.rawValue ?? "",
            pressurePoint: profile?.pressureMoment.rawValue ?? "",
            mistakeResponse: profile?.mistakeResponse.rawValue ?? "",
            selfTalkStyle: profile?.selfTalkStyle.rawValue ?? "",
            skippedRStage: profile?.defaultSkippedR.rawValue ?? "Reset",
            confidenceStyle: profile?.confidenceDependency.rawValue ?? "",
            decisionHabit: profile?.decisionPointHabit.rawValue ?? "",
            commonBreakdownPattern: commonPattern
        )

        let recentState = PlayerMemory.RecentState(
            confidenceTrend: recentConfidence,
            confidenceDirection: confidenceDirection,
            energyLoopState: profile?.currentEnergyLoop.rawValue ?? "Neutral",
            currentRStage: profile?.currentRStage.rawValue ?? "Reset",
            mentalPrepScore: profile?.mentalPrepScore ?? 50,
            practiceScore: profile?.practiceScore ?? 50,
            performanceScore: profile?.performanceScore ?? 50,
            nextMatchHours: nextMatchHours,
            nextMatchOpponent: upcomingMatch?.opponent,
            lastDrillUsed: recentDrills.first?.drillID,
            recentDrillCount: recentDrills.count,
            recentSolutionSummaries: recentCardSummaries
        )

        return PlayerMemory(identity: identity, patterns: patterns, recentState: recentState)
    }

    static func buildDebriefSummaries(context: ModelContext, limit: Int = 5) -> [String] {
        let desc = FetchDescriptor<PostGameDebrief>(sortBy: [SortDescriptor(\PostGameDebrief.date, order: .reverse)])
        let debriefs = (try? context.fetch(desc)) ?? []
        return debriefs.prefix(limit).compactMap { d in
            d.summaryForCoach.isEmpty ? nil : d.summaryForCoach
        }
    }

    static func buildVaultSummaries(context: ModelContext, limit: Int = 5) -> [String] {
        let desc = FetchDescriptor<ConfidenceVaultEntry>(sortBy: [SortDescriptor(\ConfidenceVaultEntry.date, order: .reverse)])
        let entries = (try? context.fetch(desc)) ?? []
        return entries.prefix(limit).map { $0.summaryForCoach }
    }

    static func buildMatchDaySummary(context: ModelContext) -> String? {
        let desc = FetchDescriptor<MatchDaySession>(sortBy: [SortDescriptor(\MatchDaySession.date, order: .reverse)])
        guard let session = (try? context.fetch(desc))?.first else { return nil }
        let dayAgo = Calendar.current.date(byAdding: .day, value: -1, to: Date()) ?? Date()
        guard session.date > dayAgo else { return nil }
        var parts: [String] = []
        parts.append("Last match day lock-in: arousal was '\(session.arousalState.rawValue)', anchor word '\(session.anchorWord)'")
        if session.sequenceCompleted {
            parts.append("Completed full sequence (regulate + rehearse + anchor)")
        }
        return parts.joined(separator: ". ")
    }

    static func recentDebriefPatterns(context: ModelContext) -> String? {
        let desc = FetchDescriptor<PostGameDebrief>(sortBy: [SortDescriptor(\PostGameDebrief.date, order: .reverse)])
        let debriefs = (try? context.fetch(desc)) ?? []
        guard debriefs.count >= 3 else { return nil }
        let recent = Array(debriefs.prefix(10))
        var challengeCounts: [String: Int] = [:]
        for d in recent {
            for tag in d.challengedTags {
                challengeCounts[tag, default: 0] += 1
            }
        }
        let recurring = challengeCounts.filter { $0.value >= 3 }.sorted { $0.value > $1.value }
        guard !recurring.isEmpty else { return nil }
        let patterns = recurring.prefix(3).map { "'\($0.key)' (\($0.value)/\(recent.count) matches)" }
        return "Recurring debrief patterns: \(patterns.joined(separator: ", "))"
    }
}
