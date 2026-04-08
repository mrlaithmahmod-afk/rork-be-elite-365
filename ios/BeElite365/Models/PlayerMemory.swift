import Foundation

nonisolated struct PlayerMemory: Sendable {
    let identity: Identity
    let patterns: Patterns
    let recentState: RecentState

    nonisolated struct Identity: Sendable {
        let name: String
        let gender: String
        let position: String
        let level: String
        let ageBand: String
        let isMinor: Bool
        let primaryGoal: String
    }

    nonisolated struct Patterns: Sendable {
        let dominantIssues: [String]
        let mainTrigger: String
        let pressurePoint: String
        let mistakeResponse: String
        let selfTalkStyle: String
        let skippedRStage: String
        let confidenceStyle: String
        let decisionHabit: String
        let commonBreakdownPattern: String
    }

    nonisolated struct RecentState: Sendable {
        let confidenceTrend: [Double]
        let confidenceDirection: String
        let energyLoopState: String
        let currentRStage: String
        let mentalPrepScore: Double
        let practiceScore: Double
        let performanceScore: Double
        let nextMatchHours: Double?
        let nextMatchOpponent: String?
        let lastDrillUsed: String?
        let recentDrillCount: Int
        let recentSolutionSummaries: [String]
    }

    var forPrompt: String {
        var lines: [String] = []
        lines.append("Name: \(identity.name), \(identity.position), \(identity.level), Age: \(identity.ageBand), Gender: \(identity.gender)")
        lines.append("Goal: \(identity.primaryGoal)")

        if !patterns.dominantIssues.isEmpty {
            lines.append("Issues: \(patterns.dominantIssues.joined(separator: ", "))")
        }
        lines.append("Main trigger: \(patterns.mainTrigger)")
        lines.append("Pressure point: \(patterns.pressurePoint)")
        lines.append("Mistake response: \(patterns.mistakeResponse)")
        lines.append("Self-talk: \(patterns.selfTalkStyle)")
        lines.append("Confidence style: \(patterns.confidenceStyle)")
        lines.append("Skipped R stage: \(patterns.skippedRStage)")
        if !patterns.commonBreakdownPattern.isEmpty {
            lines.append("Pattern: \(patterns.commonBreakdownPattern)")
        }

        lines.append("Confidence trend (last 7): \(recentState.confidenceTrend.map { "\(Int($0))" }.joined(separator: ", ")) (\(recentState.confidenceDirection))")
        lines.append("Energy: \(recentState.energyLoopState) | Current R: \(recentState.currentRStage)")
        lines.append("Triangle: Mental Prep \(Int(recentState.mentalPrepScore))% | Practice \(Int(recentState.practiceScore))% | Performance \(Int(recentState.performanceScore))%")

        if let hours = recentState.nextMatchHours {
            let opponent = recentState.nextMatchOpponent ?? "Unknown"
            if hours <= 0 {
                lines.append("Next match: already started or passed (vs \(opponent))")
            } else if hours < 24 {
                lines.append("Next match: in \(Int(hours)) hours (vs \(opponent)) — MATCH DAY")
            } else {
                lines.append("Next match: in \(Int(hours / 24)) days (vs \(opponent))")
            }
        }

        if let lastDrill = recentState.lastDrillUsed {
            lines.append("Last drill: \(lastDrill) | Drills this week: \(recentState.recentDrillCount)")
        }

        if !recentState.recentSolutionSummaries.isEmpty {
            lines.append("Recent solutions: \(recentState.recentSolutionSummaries.prefix(3).joined(separator: "; "))")
        }

        if identity.isMinor {
            lines.append("[MINOR: age-appropriate language required]")
        }

        return lines.joined(separator: "\n")
    }

    var briefForPrompt: String {
        var parts: [String] = []
        if !identity.name.isEmpty && identity.name != "Athlete" {
            parts.append("Name: \(identity.name)")
        }
        if !identity.position.isEmpty && identity.position != "Unknown" {
            parts.append("Position: \(identity.position)")
        }
        if !identity.level.isEmpty {
            parts.append("Level: \(identity.level)")
        }
        if let hours = recentState.nextMatchHours, hours < 24 && hours > 0 {
            parts.append("Match in \(Int(hours))h")
        }
        return parts.joined(separator: ", ")
    }
}
