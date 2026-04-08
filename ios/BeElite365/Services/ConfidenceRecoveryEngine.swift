import Foundation
import SwiftData

nonisolated enum ConfidenceState: String, Sendable {
    case stable = "Stable"
    case recovering = "Recovering"
    case dip = "Confidence Dip"
    case spiral = "Confidence Spiral"

    var icon: String {
        switch self {
        case .stable: "checkmark.shield"
        case .recovering: "arrow.up.heart"
        case .dip: "arrow.down.right"
        case .spiral: "exclamationmark.triangle"
        }
    }

    var color: String {
        switch self {
        case .stable: "stable"
        case .recovering: "weakening"
        case .dip: "weakening"
        case .spiral: "breakdown"
        }
    }

    var recoveryPrompt: String {
        switch self {
        case .stable: "Your confidence is steady. Keep building through controllable actions."
        case .recovering: "You are rebuilding. Stack small wins. One action at a time."
        case .dip: "Confidence has dipped. Time to reset and refocus on what you can control."
        case .spiral: "You are in a confidence spiral. Stop. Reset now. Break the pattern before it compounds."
        }
    }
}

struct ConfidenceRecoveryEngine {
    static func assess(checkIns: [DailyCheckIn], solutionCards: [SolutionCard]) -> ConfidenceState {
        let recent = Array(checkIns.prefix(7))
        guard recent.count >= 3 else { return .stable }

        let confidences = recent.map(\.confidenceLevel)
        let avgConfidence = confidences.reduce(0, +) / Double(confidences.count)

        let isDecliningSteadily = confidences.count >= 3 && zip(confidences, confidences.dropFirst()).allSatisfy { $0 >= $1 }

        let recentCards = solutionCards.prefix(5)
        let highIntensityCount = recentCards.filter { $0.emotionIntensity >= 7 }.count
        let negativeLoopCount = recent.filter { $0.energyLoop == .negative }.count

        if avgConfidence <= 30 && negativeLoopCount >= 3 && isDecliningSteadily {
            return .spiral
        }

        if avgConfidence <= 45 && (negativeLoopCount >= 2 || highIntensityCount >= 2) {
            return .dip
        }

        if avgConfidence <= 55 && avgConfidence > 45 && negativeLoopCount >= 1 {
            return .recovering
        }

        return .stable
    }

    static func recoveryDrills(for state: ConfidenceState) -> [Drill] {
        switch state {
        case .spiral:
            return DrillLibrary.drills.filter { $0.rStage == .reset }.prefix(2).map { $0 }
        case .dip:
            return DrillLibrary.drills.filter { $0.category == .mistakeRecovery }.prefix(2).map { $0 }
        case .recovering:
            return DrillLibrary.drills.filter { $0.rStage == .refocus }.prefix(1).map { $0 }
        case .stable:
            return []
        }
    }
}
