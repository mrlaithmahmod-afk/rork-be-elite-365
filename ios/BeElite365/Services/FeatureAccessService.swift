import Foundation

nonisolated enum AppFeature: String, Sendable, CaseIterable {
    case unlimitedCoachChat
    case voiceCoach
    case fullThinkingGym
    case advancedThinkingGym
    case eliteThinkingGym
    case fullSolve
    case advancedSolve
    case quickFix
    case basicInsights
    case advancedInsights
    case eliteInsights
    case preMatchTools
    case postMatchTools
    case dailyPlan
    case matchCalendar
    case confidenceTracker
    case consistencyEngine
    case pressureSystem
    case eliteMaintenanceMode
    case fixturePrep
    case leadershipMode
    case injuryReturnPathway
    case pressureLoadMonitor
    case privateDebrief
    case routineBuilder
    case formRecovery
}

struct FeatureAccessService {

    static func canAccess(
        feature: AppFeature,
        level: PlayingLevel,
        tier: SubscriptionTier
    ) -> Bool {
        let required = requiredTier(for: feature, at: level)
        return tier.meetsMinimum(required)
    }

    static func requiredTier(for feature: AppFeature, at level: PlayingLevel) -> SubscriptionTier {
        switch feature {

        case .basicInsights, .preMatchTools, .postMatchTools, .confidenceTracker, .quickFix, .matchCalendar:
            return .free

        case .unlimitedCoachChat, .fullSolve, .dailyPlan, .fullThinkingGym:
            return .perform

        case .voiceCoach:
            return .perform

        case .advancedThinkingGym, .advancedSolve, .advancedInsights, .pressureSystem, .consistencyEngine, .routineBuilder, .formRecovery:
            return .progress

        case .eliteThinkingGym, .eliteInsights, .eliteMaintenanceMode, .fixturePrep, .leadershipMode, .injuryReturnPathway, .pressureLoadMonitor, .privateDebrief:
            return .elite
        }
    }

    static func recommendedTier(for level: PlayingLevel) -> SubscriptionTier {
        switch level {
        case .grassroots: return .perform
        case .academy: return .progress
        case .semiPro: return .progress
        case .professional: return .elite
        }
    }

    static func dailyCoachMessageLimit(for tier: SubscriptionTier) -> Int {
        switch tier {
        case .free: return 5
        case .perform, .progress, .elite: return .max
        }
    }

    static func availableFeatures(level: PlayingLevel, tier: SubscriptionTier) -> [AppFeature] {
        AppFeature.allCases.filter { canAccess(feature: $0, level: level, tier: tier) }
    }

    static func lockedFeatures(level: PlayingLevel, tier: SubscriptionTier) -> [AppFeature] {
        AppFeature.allCases.filter { !canAccess(feature: $0, level: level, tier: tier) }
    }
}
