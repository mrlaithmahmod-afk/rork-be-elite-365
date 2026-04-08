import Foundation

struct LevelConfig {

    struct LevelProfile: Sendable {
        let focusAreas: [String]
        let solveIssueTypes: [SituationType]
        let exclusiveModuleIDs: [String]
        let dashboardStyle: DashboardStyle
        let insightsStyle: InsightsStyle
        let controlRoomTitle: String
        let controlRoomSubtitle: String
    }

    nonisolated enum DashboardStyle: Sendable {
        case guided
        case pressureAware
        case structured
        case minimal
    }

    nonisolated enum InsightsStyle: Sendable {
        case simpleTrends
        case pressurePatterns
        case consistencyAnalytics
        case performanceIntelligence
    }

    static func profile(for level: PlayingLevel) -> LevelProfile {
        switch level {
        case .grassroots:
            return LevelProfile(
                focusAreas: ["Confidence", "Nerves", "Basic emotional control", "Simple routines"],
                solveIssueTypes: [.mistake, .missedChance, .lostBall, .lostFocus, .other],
                exclusiveModuleIDs: ["confidence-builder", "simple-routine", "confidence-recall", "beginner-self-talk"],
                dashboardStyle: .guided,
                insightsStyle: .simpleTrends,
                controlRoomTitle: "Control Room",
                controlRoomSubtitle: "Build your foundation"
            )
        case .academy:
            return LevelProfile(
                focusAreas: ["Pressure under evaluation", "Coach criticism", "Selection anxiety", "Composure"],
                solveIssueTypes: [.mistake, .receivedCriticism, .gotSubbed, .missedChance, .lostFocus, .lostBall, .other],
                exclusiveModuleIDs: ["coach-pressure-reset", "selection-week", "criticism-processing", "training-composure"],
                dashboardStyle: .pressureAware,
                insightsStyle: .pressurePatterns,
                controlRoomTitle: "Control Room",
                controlRoomSubtitle: "Sharpen your edge"
            )
        case .semiPro:
            return LevelProfile(
                focusAreas: ["Consistency", "Life vs football balance", "Discipline", "Mental maintenance"],
                solveIssueTypes: SituationType.allCases,
                exclusiveModuleIDs: ["consistency-engine", "routine-rebuild", "form-recovery", "mental-maintenance"],
                dashboardStyle: .structured,
                insightsStyle: .consistencyAnalytics,
                controlRoomTitle: "Control Room",
                controlRoomSubtitle: "Stay consistent"
            )
        case .professional:
            return LevelProfile(
                focusAreas: ["Elite performance maintenance", "Pressure control", "Leadership", "Mental stability"],
                solveIssueTypes: SituationType.allCases,
                exclusiveModuleIDs: ["elite-maintenance", "fixture-prep", "leadership-mode", "injury-return", "pressure-monitor", "private-debrief"],
                dashboardStyle: .minimal,
                insightsStyle: .performanceIntelligence,
                controlRoomTitle: "Control Room",
                controlRoomSubtitle: "Peak performance"
            )
        }
    }

    static func thinkingGymSections(for level: PlayingLevel, tier: SubscriptionTier, gender: Gender = .preferNotToSay) -> [ThinkingGymModule] {
        var modules: [ThinkingGymModule] = []

        modules.append(contentsOf: coreModules)

        switch level {
        case .grassroots:
            modules.append(contentsOf: grassrootsModules)
        case .academy:
            modules.append(contentsOf: grassrootsModules)
            modules.append(contentsOf: academyModules)
        case .semiPro:
            modules.append(contentsOf: grassrootsModules)
            modules.append(contentsOf: academyModules)
            modules.append(contentsOf: semiProModules)
        case .professional:
            modules.append(contentsOf: grassrootsModules)
            modules.append(contentsOf: academyModules)
            modules.append(contentsOf: semiProModules)
            modules.append(contentsOf: proModules)
        }

        if gender == .female {
            modules.append(contentsOf: femaleModules)
        }

        return modules.map { mod in
            var m = mod
            m.isLocked = !tier.meetsMinimum(mod.requiredTier)
            return m
        }
    }

    static func filteredDrills(for level: PlayingLevel) -> [Drill] {
        switch level {
        case .grassroots:
            return DrillLibrary.drills.filter { $0.category == .reset || $0.category == .regroup || $0.category == .refocus || $0.category == .mistakeRecovery }
        case .academy:
            return DrillLibrary.drills.filter { $0.category != .identity }
        case .semiPro, .professional:
            return DrillLibrary.drills
        }
    }
}

struct ThinkingGymModule: Identifiable, Sendable {
    let id: String
    let title: String
    let subtitle: String
    let icon: String
    let category: ModuleCategory
    let requiredLevel: PlayingLevel
    let requiredTier: SubscriptionTier
    let drillType: String?
    var isLocked: Bool

    init(id: String, title: String, subtitle: String, icon: String, category: ModuleCategory, requiredLevel: PlayingLevel, requiredTier: SubscriptionTier, drillType: String? = nil, isLocked: Bool = false) {
        self.id = id
        self.title = title
        self.subtitle = subtitle
        self.icon = icon
        self.category = category
        self.requiredLevel = requiredLevel
        self.requiredTier = requiredTier
        self.drillType = drillType
        self.isLocked = isLocked
    }
}

nonisolated enum ModuleCategory: String, Sendable, CaseIterable, Identifiable {
    case decisionTraining = "Decision Training"
    case mentalControl = "Mental Control"
    case performanceTraining = "Performance Training"
    case breathingRegulation = "Breathing & Regulation"
    case levelExclusive = "Specialist Modules"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .decisionTraining: "bolt.fill"
        case .mentalControl: "brain.head.profile"
        case .performanceTraining: "shield.checkered"
        case .breathingRegulation: "wind"
        case .levelExclusive: "star.fill"
        }
    }
}

extension LevelConfig {

    private static var coreModules: [ThinkingGymModule] {
        [
            ThinkingGymModule(id: "reset-game", title: "10s Reset", subtitle: "Mistake recovery", icon: "timer", category: .decisionTraining, requiredLevel: .grassroots, requiredTier: .free, drillType: "reset_game"),
            ThinkingGymModule(id: "focus-snap", title: "Focus Snap", subtitle: "Reaction speed", icon: "eye.circle.fill", category: .decisionTraining, requiredLevel: .grassroots, requiredTier: .free, drillType: "focus_snap"),
            ThinkingGymModule(id: "thought-interrupt", title: "Thought Interrupt", subtitle: "Stop overthinking", icon: "xmark.octagon", category: .mentalControl, requiredLevel: .grassroots, requiredTier: .free, drillType: "thought_interrupt"),
            ThinkingGymModule(id: "physiological-sigh", title: "Physiological Sigh", subtitle: "Fast calming technique", icon: "lungs.fill", category: .breathingRegulation, requiredLevel: .grassroots, requiredTier: .free, drillType: "physiological_sigh"),
            ThinkingGymModule(id: "box-breathing", title: "Box Breathing", subtitle: "Controlled reset", icon: "wind", category: .breathingRegulation, requiredLevel: .grassroots, requiredTier: .free, drillType: "box_breathing"),
        ]
    }

    private static var grassrootsModules: [ThinkingGymModule] {
        [
            ThinkingGymModule(id: "confidence-builder", title: "Confidence Builder", subtitle: "Pre-match confidence routine", icon: "star.circle", category: .levelExclusive, requiredLevel: .grassroots, requiredTier: .perform, drillType: "confidence_builder"),
            ThinkingGymModule(id: "simple-routine", title: "Routine Builder", subtitle: "Build your first routine", icon: "calendar.badge.clock", category: .levelExclusive, requiredLevel: .grassroots, requiredTier: .perform, drillType: "routine_builder"),
            ThinkingGymModule(id: "confidence-recall", title: "Confidence Recall", subtitle: "Replay your best moments", icon: "play.circle", category: .levelExclusive, requiredLevel: .grassroots, requiredTier: .perform, drillType: "confidence_replay"),
            ThinkingGymModule(id: "beginner-self-talk", title: "Self-Talk Starter", subtitle: "Build positive internal cues", icon: "text.bubble", category: .levelExclusive, requiredLevel: .grassroots, requiredTier: .perform, drillType: "self_talk_builder"),
        ]
    }

    private static var academyModules: [ThinkingGymModule] {
        [
            ThinkingGymModule(id: "coach-pressure-reset", title: "Coach Pressure Reset", subtitle: "Handle criticism constructively", icon: "person.fill.questionmark", category: .levelExclusive, requiredLevel: .academy, requiredTier: .perform, drillType: "cognitive_defusion"),
            ThinkingGymModule(id: "selection-week", title: "Selection Week Mode", subtitle: "Stay composed during trials", icon: "calendar.badge.exclamationmark", category: .levelExclusive, requiredLevel: .academy, requiredTier: .progress, drillType: "pressure_simulator"),
            ThinkingGymModule(id: "criticism-processing", title: "Criticism Processing", subtitle: "Extract value, discard noise", icon: "arrow.triangle.branch", category: .levelExclusive, requiredLevel: .academy, requiredTier: .progress, drillType: "emotional_labeling"),
            ThinkingGymModule(id: "training-composure", title: "Training Composure", subtitle: "Stay composed under evaluation", icon: "shield.lefthalf.filled", category: .levelExclusive, requiredLevel: .academy, requiredTier: .progress, drillType: "clutch_mode"),
        ]
    }

    private static var semiProModules: [ThinkingGymModule] {
        [
            ThinkingGymModule(id: "consistency-engine", title: "Consistency Engine", subtitle: "Build match-to-match reliability", icon: "chart.line.flattrend.xyaxis", category: .levelExclusive, requiredLevel: .semiPro, requiredTier: .progress, drillType: "focus_switch"),
            ThinkingGymModule(id: "routine-rebuild", title: "Routine Rebuild", subtitle: "Restructure your mental routine", icon: "arrow.triangle.2.circlepath", category: .levelExclusive, requiredLevel: .semiPro, requiredTier: .progress, drillType: "routine_builder"),
            ThinkingGymModule(id: "form-recovery", title: "Form Recovery", subtitle: "Systematic form rebuild", icon: "arrow.up.forward", category: .levelExclusive, requiredLevel: .semiPro, requiredTier: .progress, drillType: "confidence_replay"),
            ThinkingGymModule(id: "mental-maintenance", title: "Mental Maintenance", subtitle: "Sustain peak mental state", icon: "wrench.and.screwdriver", category: .levelExclusive, requiredLevel: .semiPro, requiredTier: .progress, drillType: "visualization"),
        ]
    }

    private static var proModules: [ThinkingGymModule] {
        [
            ThinkingGymModule(id: "elite-maintenance", title: "Elite Maintenance", subtitle: "Sustain elite mental standards", icon: "crown", category: .levelExclusive, requiredLevel: .professional, requiredTier: .elite, drillType: "elite_maintenance"),
            ThinkingGymModule(id: "fixture-prep", title: "Fixture Prep System", subtitle: "Match-by-match preparation", icon: "sportscourt", category: .levelExclusive, requiredLevel: .professional, requiredTier: .elite, drillType: "pre_match_visualization"),
            ThinkingGymModule(id: "leadership-mode", title: "Leadership Mode", subtitle: "Lead under pressure", icon: "person.3.fill", category: .levelExclusive, requiredLevel: .professional, requiredTier: .elite, drillType: "leadership"),
            ThinkingGymModule(id: "injury-return", title: "Injury Return Pathway", subtitle: "Mental rebuild after injury", icon: "cross.case", category: .levelExclusive, requiredLevel: .professional, requiredTier: .elite, drillType: "injury_return"),
            ThinkingGymModule(id: "pressure-monitor", title: "Pressure Load Monitor", subtitle: "Track cumulative pressure", icon: "gauge.with.dots.needle.67percent", category: .levelExclusive, requiredLevel: .professional, requiredTier: .elite, drillType: "pressure_monitor"),
            ThinkingGymModule(id: "private-debrief", title: "Private Debrief", subtitle: "Structured post-match analysis", icon: "doc.text.magnifyingglass", category: .levelExclusive, requiredLevel: .professional, requiredTier: .elite, drillType: "debrief"),
        ]
    }

    private static var femaleModules: [ThinkingGymModule] {
        [
            ThinkingGymModule(id: "belonging-builder", title: "Belonging Builder", subtitle: "Own your place on the pitch", icon: "sparkles", category: .levelExclusive, requiredLevel: .grassroots, requiredTier: .perform, drillType: "confidence_builder"),
            ThinkingGymModule(id: "inner-voice-reset", title: "Inner Voice Reset", subtitle: "Rewrite your internal narrative", icon: "text.bubble.fill", category: .levelExclusive, requiredLevel: .grassroots, requiredTier: .perform, drillType: "self_talk_builder"),
            ThinkingGymModule(id: "comparison-detox", title: "Comparison Detox", subtitle: "Stop measuring against others", icon: "person.2.slash", category: .levelExclusive, requiredLevel: .academy, requiredTier: .progress, drillType: "cognitive_defusion"),
            ThinkingGymModule(id: "visibility-pressure", title: "Visibility Pressure", subtitle: "Handle scrutiny and expectation", icon: "eye.trianglebadge.exclamationmark", category: .levelExclusive, requiredLevel: .academy, requiredTier: .progress, drillType: "pressure_simulator"),
        ]
    }
}
