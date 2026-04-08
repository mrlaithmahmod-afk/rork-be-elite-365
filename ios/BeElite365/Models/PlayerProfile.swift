import Foundation
import SwiftData

@Model
class PlayerProfile {
    var name: String
    var genderRaw: String
    var ageBandRaw: String
    var positionRaw: String
    var levelRaw: String
    var primaryGoalRaw: String
    var currentIssuesRaw: [String]
    var pressureMomentRaw: String
    var mistakeResponseRaw: String
    var selfTalkStyleRaw: String
    var confidenceDependencyRaw: String
    var emotionalControlScore: Double
    var focusConsistencyScore: Double
    var disciplineBaselineRaw: String
    var decisionPointHabitRaw: String

    var mentalPrepScore: Double
    var practiceScore: Double
    var performanceScore: Double
    var defaultSkippedRRaw: String
    var currentEnergyLoopRaw: String
    var currentRStageRaw: String
    var trainingFocusAreaRaw: String

    var subscriptionTierRaw: String
    var dailyCoachMessagesToday: Int
    var lastCoachMessageDate: Date?

    var onboardingComplete: Bool
    var consentAI: Bool
    var consentPrivacy: Bool
    var hasInjuryHistory: Bool

    var createdAt: Date
    var updatedAt: Date

    var gender: Gender {
        get { Gender(rawValue: genderRaw) ?? .preferNotToSay }
        set { genderRaw = newValue.rawValue }
    }

    var ageBand: AgeBand {
        get { AgeBand(rawValue: ageBandRaw) ?? .under24 }
        set { ageBandRaw = newValue.rawValue }
    }

    var position: FootballPosition {
        get { FootballPosition(rawValue: positionRaw) ?? .centreMidfield }
        set { positionRaw = newValue.rawValue }
    }

    var level: PlayingLevel {
        get { PlayingLevel(rawValue: levelRaw) ?? .academy }
        set { levelRaw = newValue.rawValue }
    }

    var primaryGoal: PrimaryGoal {
        get { PrimaryGoal(rawValue: primaryGoalRaw) ?? .calmUnderPressure }
        set { primaryGoalRaw = newValue.rawValue }
    }

    var currentIssues: [CurrentIssue] {
        currentIssuesRaw.compactMap { CurrentIssue(rawValue: $0) }
    }

    var pressureMoment: PressureMoment {
        get { PressureMoment(rawValue: pressureMomentRaw) ?? .afterMistake }
        set { pressureMomentRaw = newValue.rawValue }
    }

    var mistakeResponse: MistakeResponse {
        get { MistakeResponse(rawValue: mistakeResponseRaw) ?? .rushToFix }
        set { mistakeResponseRaw = newValue.rawValue }
    }

    var selfTalkStyle: SelfTalkStyle {
        get { SelfTalkStyle(rawValue: selfTalkStyleRaw) ?? .calmInconsistent }
        set { selfTalkStyleRaw = newValue.rawValue }
    }

    var confidenceDependency: ConfidenceDependency {
        get { ConfidenceDependency(rawValue: confidenceDependencyRaw) ?? .results }
        set { confidenceDependencyRaw = newValue.rawValue }
    }

    var disciplineBaseline: DisciplineBaseline {
        get { DisciplineBaseline(rawValue: disciplineBaselineRaw) ?? .inconsistent }
        set { disciplineBaselineRaw = newValue.rawValue }
    }

    var decisionPointHabit: DecisionPointHabit {
        get { DecisionPointHabit(rawValue: decisionPointHabitRaw) ?? .forceIt }
        set { decisionPointHabitRaw = newValue.rawValue }
    }

    var defaultSkippedR: RStage {
        get { RStage(rawValue: defaultSkippedRRaw) ?? .reset }
        set { defaultSkippedRRaw = newValue.rawValue }
    }

    var currentEnergyLoop: EnergyLoopState {
        get { EnergyLoopState(rawValue: currentEnergyLoopRaw) ?? .neutral }
        set { currentEnergyLoopRaw = newValue.rawValue }
    }

    var currentRStage: RStage {
        get { RStage(rawValue: currentRStageRaw) ?? .reset }
        set { currentRStageRaw = newValue.rawValue }
    }

    var trainingFocusArea: TriangleSide {
        get { TriangleSide(rawValue: trainingFocusAreaRaw) ?? .mentalPreparation }
        set { trainingFocusAreaRaw = newValue.rawValue }
    }

    var subscriptionTier: SubscriptionTier {
        get { SubscriptionTier(rawValue: subscriptionTierRaw) ?? .free }
        set { subscriptionTierRaw = newValue.rawValue }
    }

    func canAccess(_ feature: AppFeature) -> Bool {
        FeatureAccessService.canAccess(feature: feature, level: level, tier: subscriptionTier)
    }

    func checkCoachMessageLimit() -> Bool {
        let limit = FeatureAccessService.dailyCoachMessageLimit(for: subscriptionTier)
        guard limit != .max else { return true }
        if let lastDate = lastCoachMessageDate, !Calendar.current.isDateInToday(lastDate) {
            return true
        }
        return dailyCoachMessagesToday < limit
    }

    func incrementCoachMessages() {
        if let lastDate = lastCoachMessageDate, !Calendar.current.isDateInToday(lastDate) {
            dailyCoachMessagesToday = 1
        } else {
            dailyCoachMessagesToday += 1
        }
        lastCoachMessageDate = Date()
    }

    var triangleAverage: Double {
        (mentalPrepScore + practiceScore + performanceScore) / 3.0
    }

    var isMinor: Bool { ageBand.isMinor }

    init(
        name: String,
        gender: Gender = .preferNotToSay,
        ageBand: AgeBand,
        position: FootballPosition,
        level: PlayingLevel,
        primaryGoal: PrimaryGoal,
        currentIssues: [CurrentIssue],
        pressureMoment: PressureMoment,
        mistakeResponse: MistakeResponse,
        selfTalkStyle: SelfTalkStyle,
        confidenceDependency: ConfidenceDependency,
        emotionalControlScore: Double,
        focusConsistencyScore: Double,
        disciplineBaseline: DisciplineBaseline,
        decisionPointHabit: DecisionPointHabit,
        mentalPrepScore: Double,
        practiceScore: Double,
        performanceScore: Double,
        defaultSkippedR: RStage,
        currentEnergyLoop: EnergyLoopState,
        currentRStage: RStage,
        trainingFocusArea: TriangleSide
    ) {
        self.name = name
        self.genderRaw = gender.rawValue
        self.ageBandRaw = ageBand.rawValue
        self.positionRaw = position.rawValue
        self.levelRaw = level.rawValue
        self.primaryGoalRaw = primaryGoal.rawValue
        self.currentIssuesRaw = currentIssues.map(\.rawValue)
        self.pressureMomentRaw = pressureMoment.rawValue
        self.mistakeResponseRaw = mistakeResponse.rawValue
        self.selfTalkStyleRaw = selfTalkStyle.rawValue
        self.confidenceDependencyRaw = confidenceDependency.rawValue
        self.emotionalControlScore = emotionalControlScore
        self.focusConsistencyScore = focusConsistencyScore
        self.disciplineBaselineRaw = disciplineBaseline.rawValue
        self.decisionPointHabitRaw = decisionPointHabit.rawValue
        self.mentalPrepScore = mentalPrepScore
        self.practiceScore = practiceScore
        self.performanceScore = performanceScore
        self.defaultSkippedRRaw = defaultSkippedR.rawValue
        self.currentEnergyLoopRaw = currentEnergyLoop.rawValue
        self.currentRStageRaw = currentRStage.rawValue
        self.trainingFocusAreaRaw = trainingFocusArea.rawValue
        self.subscriptionTierRaw = SubscriptionTier.free.rawValue
        self.dailyCoachMessagesToday = 0
        self.lastCoachMessageDate = nil
        self.onboardingComplete = true
        self.consentAI = true
        self.consentPrivacy = true
        self.hasInjuryHistory = false
        self.createdAt = Date()
        self.updatedAt = Date()
    }
}
