import Foundation
import SwiftData

struct DailyTask: Identifiable, Sendable {
    let id: String
    let title: String
    let subtitle: String
    let icon: String
    let rStage: RStage
    let drillID: String?
    let taskType: DailyTaskType
    let reason: String
}

nonisolated enum DailyTaskType: String, Sendable {
    case breathing
    case drill
    case checkIn
    case solve
    case regroup
    case refocus
}

struct RecommendationEngine {
    static func generateDailyTasks(
        profile: PlayerProfile,
        checkIns: [DailyCheckIn],
        completions: [DrillCompletion],
        solutionCards: [SolutionCard],
        upcomingMatch: MatchEvent?,
        confidenceState: ConfidenceState
    ) -> [DailyTask] {
        var tasks: [DailyTask] = []

        if confidenceState == .spiral || confidenceState == .dip {
            tasks.append(DailyTask(
                id: "recovery-reset",
                title: "90-Second Reset",
                subtitle: "Break the pattern before it compounds",
                icon: "arrow.counterclockwise",
                rStage: .reset,
                drillID: "reset-breathing-30s",
                taskType: .breathing,
                reason: "Confidence has dipped. A controlled reset helps break the negative cycle."
            ))
        } else {
            tasks.append(resetTask(for: profile))
        }

        tasks.append(regroupTask(for: profile, checkIns: checkIns, solutionCards: solutionCards))
        tasks.append(refocusTask(for: profile, completions: completions))

        if let match = upcomingMatch {
            let hoursUntil = Calendar.current.dateComponents([.hour], from: Date(), to: match.date).hour ?? 999
            if hoursUntil > 0 && hoursUntil <= 24 {
                tasks.insert(DailyTask(
                    id: "prematch-routine",
                    title: "Pre-Match Routine",
                    subtitle: "Get mentally ready for \(match.opponent.isEmpty ? "your match" : "vs \(match.opponent)")",
                    icon: "figure.run",
                    rStage: .reset,
                    drillID: "pressure-prematch-routine",
                    taskType: .drill,
                    reason: "Match within 24 hours. Pre-match preparation is critical."
                ), at: 0)
            }
        }

        let todayCheckIn = checkIns.first.flatMap { Calendar.current.isDateInToday($0.date) ? $0 : nil }
        if todayCheckIn == nil {
            tasks.append(DailyTask(
                id: "daily-checkin",
                title: "Daily Check-In",
                subtitle: "Log how you are feeling today",
                icon: "square.and.pencil",
                rStage: .regroup,
                drillID: nil,
                taskType: .checkIn,
                reason: "Consistent check-ins build self-awareness and track progress."
            ))
        }

        return Array(tasks.prefix(4))
    }

    private static func resetTask(for profile: PlayerProfile) -> DailyTask {
        let skipsReset = profile.defaultSkippedR == .reset
        if skipsReset {
            return DailyTask(
                id: "reset-breathing",
                title: "Breathing Reset",
                subtitle: "4-2-6 pattern, 3 cycles",
                icon: "wind",
                rStage: .reset,
                drillID: "reset-breathing-30s",
                taskType: .breathing,
                reason: "You tend to skip Reset. Building this habit strengthens your recovery."
            )
        }
        return DailyTask(
            id: "reset-release",
            title: "Release Drill",
            subtitle: "Practice letting go of the last action",
            icon: "arrow.counterclockwise",
            rStage: .reset,
            drillID: "reset-release-cue",
            taskType: .drill,
            reason: "Daily reset practice builds automatic recovery under pressure."
        )
    }

    private static func regroupTask(for profile: PlayerProfile, checkIns: [DailyCheckIn], solutionCards: [SolutionCard]) -> DailyTask {
        let recentNegative = checkIns.prefix(3).filter { $0.energyLoop == .negative }.count
        if recentNegative >= 2 {
            return DailyTask(
                id: "regroup-controllables",
                title: "Controllables Mapping",
                subtitle: "Identify what you can and cannot control",
                icon: "arrow.triangle.merge",
                rStage: .regroup,
                drillID: "regroup-controllables",
                taskType: .regroup,
                reason: "Recent sessions show negative energy. Regrouping on controllables restores clarity."
            )
        }
        return DailyTask(
            id: "regroup-composure",
            title: "Composure Anchor",
            subtitle: "Build your physical reset cue",
            icon: "arrow.triangle.merge",
            rStage: .regroup,
            drillID: "regroup-composure-anchor",
            taskType: .drill,
            reason: "Composure anchoring strengthens automatic regulation under pressure."
        )
    }

    private static func refocusTask(for profile: PlayerProfile, completions: [DrillCompletion]) -> DailyTask {
        let focusWeak = profile.focusConsistencyScore < 6
        if focusWeak {
            return DailyTask(
                id: "refocus-next-action",
                title: "Next-Action Targeting",
                subtitle: "Train single-point focus",
                icon: "scope",
                rStage: .refocus,
                drillID: "refocus-next-action",
                taskType: .refocus,
                reason: "Your focus consistency score is below average. This drill trains attention control."
            )
        }
        return DailyTask(
            id: "refocus-visualisation",
            title: "Visualisation",
            subtitle: "See your next involvement",
            icon: "scope",
            rStage: .refocus,
            drillID: "refocus-visualisation",
            taskType: .drill,
            reason: "Mental rehearsal primes the brain for automatic execution."
        )
    }

    static func suggestedDrill(for profile: PlayerProfile, completions: [DrillCompletion]) -> Drill? {
        let completedToday = Set(completions.filter {
            Calendar.current.isDateInToday($0.completedAt)
        }.map(\.drillID))

        let effective = completions
            .filter { $0.effectiveness >= 4 }
            .map(\.drillID)
        let effectiveSet = Set(effective)

        let skippedDrills = DrillLibrary.drills.filter { $0.rStage == profile.defaultSkippedR }
        if let fresh = skippedDrills.first(where: { !completedToday.contains($0.id) }) {
            return fresh
        }

        if let proven = DrillLibrary.drills.first(where: { effectiveSet.contains($0.id) && !completedToday.contains($0.id) }) {
            return proven
        }

        return DrillLibrary.drills.first { !completedToday.contains($0.id) }
    }
}
