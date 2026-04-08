import Foundation

nonisolated enum Gender: String, Codable, CaseIterable, Sendable, Identifiable {
    case male = "Male"
    case female = "Female"
    case preferNotToSay = "Prefer not to say"

    var id: String { rawValue }
}

nonisolated enum FootballPosition: String, Codable, CaseIterable, Sendable, Identifiable {
    case goalkeeper = "GK"
    case rightBack = "RB"
    case centreBack = "CB"
    case leftBack = "LB"
    case rightWingBack = "RWB"
    case leftWingBack = "LWB"
    case centreMidfield = "CM"
    case centralDefensiveMid = "CDM"
    case centralAttackingMid = "CAM"
    case rightWing = "RW"
    case leftWing = "LW"
    case striker = "ST"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .goalkeeper: "Goalkeeper"
        case .rightBack: "Right Back"
        case .centreBack: "Centre Back"
        case .leftBack: "Left Back"
        case .rightWingBack: "Right Wing Back"
        case .leftWingBack: "Left Wing Back"
        case .centreMidfield: "Central Midfield"
        case .centralDefensiveMid: "Defensive Midfield"
        case .centralAttackingMid: "Attacking Midfield"
        case .rightWing: "Right Wing"
        case .leftWing: "Left Wing"
        case .striker: "Striker"
        }
    }
}

nonisolated struct PitchPositionSlot: Sendable, Identifiable {
    let id = UUID()
    let position: FootballPosition
    let x: CGFloat
    let y: CGFloat
}

struct PitchLayout {
    static let positions: [PitchPositionSlot] = [
        PitchPositionSlot(position: .goalkeeper, x: 0.50, y: 0.92),
        PitchPositionSlot(position: .leftBack, x: 0.12, y: 0.72),
        PitchPositionSlot(position: .centreBack, x: 0.38, y: 0.75),
        PitchPositionSlot(position: .centreBack, x: 0.62, y: 0.75),
        PitchPositionSlot(position: .rightBack, x: 0.88, y: 0.72),
        PitchPositionSlot(position: .centralDefensiveMid, x: 0.50, y: 0.58),
        PitchPositionSlot(position: .centreMidfield, x: 0.30, y: 0.48),
        PitchPositionSlot(position: .centreMidfield, x: 0.70, y: 0.48),
        PitchPositionSlot(position: .centralAttackingMid, x: 0.50, y: 0.35),
        PitchPositionSlot(position: .leftWing, x: 0.12, y: 0.25),
        PitchPositionSlot(position: .rightWing, x: 0.88, y: 0.25),
        PitchPositionSlot(position: .striker, x: 0.50, y: 0.12),
    ]
}

nonisolated enum AgeBand: String, Codable, CaseIterable, Sendable, Identifiable {
    case under16 = "13-15"
    case under18 = "16-18"
    case under24 = "19-24"
    case senior = "25-30"

    var id: String { rawValue }

    var isMinor: Bool {
        self == .under16 || self == .under18
    }
}

nonisolated enum PlayingLevel: String, Codable, CaseIterable, Sendable, Identifiable {
    case grassroots = "Grassroots"
    case academy = "Academy"
    case semiPro = "Semi-Professional"
    case professional = "Professional"

    var id: String { rawValue }
}

nonisolated enum PrimaryGoal: String, Codable, CaseIterable, Sendable, Identifiable {
    case calmUnderPressure = "Calm under pressure"
    case fasterRecovery = "Faster recovery after mistakes"
    case consistency = "Consistency across matches"
    case strongerFocus = "Stronger focus in key moments"
    case independentConfidence = "Confidence independent of results"
    case returnToPlay = "Return-to-play confidence"

    var id: String { rawValue }
}

nonisolated enum CurrentIssue: String, Codable, CaseIterable, Sendable, Identifiable {
    case mistakesKillConfidence = "Mistakes kill my confidence"
    case overthinking = "Overthinking"
    case matchdayNerves = "Pressure/nerves on matchday"
    case coachCriticism = "Coach criticism affects me"
    case inconsistency = "Inconsistency"
    case focusDrops = "Focus drops mid-match"
    case fearOfFailure = "Fear of failure"
    case injurySetback = "Injury setback/return"

    var id: String { rawValue }
}

nonisolated enum PressureMoment: String, Codable, CaseIterable, Sendable, Identifiable {
    case preMatch = "Pre-match"
    case firstFifteen = "First 15 minutes"
    case afterMistake = "After a mistake"
    case underPressure = "When losing/under pressure"
    case afterCriticism = "After criticism"
    case postMatch = "Post-match rumination"
    case duringRehab = "During rehab/return"

    var id: String { rawValue }
}

nonisolated enum MistakeResponse: String, Codable, CaseIterable, Sendable, Identifiable {
    case rushToFix = "I rush to make up for it"
    case goQuiet = "I go quiet and hide"
    case getAngry = "I get angry/frustrated"
    case loseFocus = "I lose focus for minutes"
    case resetQuickly = "I reset quickly and move on"

    var id: String { rawValue }
}

nonisolated enum SelfTalkStyle: String, Codable, CaseIterable, Sendable, Identifiable {
    case harshCritical = "Harsh/critical"
    case doubtfulAnxious = "Doubtful/anxious"
    case calmInconsistent = "Calm but inconsistent"
    case positiveFragile = "Positive but fragile"
    case quietTaskFocused = "Quiet and task-focused"

    var id: String { rawValue }
}

nonisolated enum ConfidenceDependency: String, Codable, CaseIterable, Sendable, Identifiable {
    case results = "Depends on results"
    case firstAction = "Depends on first action"
    case coachFeedback = "Depends on coach feedback"
    case mostlyStable = "Mostly stable"
    case startsHighDrops = "Starts high then drops quickly"

    var id: String { rawValue }
}

nonisolated enum DisciplineBaseline: String, Codable, CaseIterable, Sendable, Identifiable {
    case noRoutine = "No routine"
    case inconsistent = "Inconsistent routine"
    case solid = "Solid routine"
    case elite = "Elite routine already"

    var id: String { rawValue }
}

nonisolated enum DecisionPointHabit: String, Codable, CaseIterable, Sendable, Identifiable {
    case forceIt = "Try to force it"
    case blameMyself = "Blame myself"
    case blameOthers = "Blame others"
    case stepBackReset = "Step back and reset"
    case dontKnow = "I don't know what to do"

    var id: String { rawValue }
}

nonisolated enum RStage: String, Codable, CaseIterable, Sendable, Identifiable {
    case reset = "Reset"
    case regroup = "Regroup"
    case refocus = "Refocus"

    var id: String { rawValue }

    var detail: String {
        switch self {
        case .reset: "Break emotional momentum. Release the previous moment."
        case .regroup: "Restore clarity, composure, and purpose."
        case .refocus: "Commit attention to the next controllable action."
        }
    }

    var icon: String {
        switch self {
        case .reset: "arrow.counterclockwise"
        case .regroup: "arrow.triangle.merge"
        case .refocus: "scope"
        }
    }
}

nonisolated enum EnergyLoopState: String, Codable, Sendable, Identifiable {
    case positive = "Positive Flow"
    case negative = "Negative Spiral"
    case neutral = "Neutral"

    var id: String { rawValue }
}

nonisolated enum TriangleSide: String, Codable, CaseIterable, Sendable, Identifiable {
    case mentalPreparation = "Mental Preparation"
    case practice = "Practice"
    case performance = "Performance"

    var id: String { rawValue }

    var shortName: String {
        switch self {
        case .mentalPreparation: "Mental Prep"
        case .practice: "Practice"
        case .performance: "Performance"
        }
    }
}

nonisolated enum SituationType: String, Codable, CaseIterable, Sendable, Identifiable {
    case mistake = "Made a Mistake"
    case lostBall = "Lost the Ball"
    case missedChance = "Missed a Chance"
    case gotSubbed = "Got Substituted"
    case receivedCriticism = "Received Criticism"
    case concededGoal = "Conceded a Goal"
    case lostFocus = "Lost Focus"
    case other = "Other"

    var id: String { rawValue }
}

nonisolated enum EmotionType: String, Codable, CaseIterable, Sendable, Identifiable {
    case frustrated = "Frustrated"
    case anxious = "Anxious"
    case angry = "Angry"
    case defeated = "Defeated"
    case confused = "Confused"
    case embarrassed = "Embarrassed"
    case numb = "Numb"

    var id: String { rawValue }
}

nonisolated enum FoundationalPrinciple: String, Codable, CaseIterable, Sendable {
    case discipline = "Discipline"
    case determination = "Determination"
    case dedication = "Dedication"
    case persistence = "Persistence"
    case perseverance = "Perseverance"
    case patience = "Patience"
}

nonisolated enum CheckInType: String, Codable, CaseIterable, Sendable {
    case daily = "Daily"
    case preMatch = "Pre-Match"
    case postMatch = "Post-Match"
    case postTraining = "Post-Training"
    case injuryRehab = "Injury Rehab"
}

nonisolated enum AppTab: String, Sendable {
    case dashboard
    case solve
    case skills
    case coach
    case insights
}

nonisolated enum DrillContext: String, Codable, CaseIterable, Sendable {
    case preMatch = "Pre-Match"
    case inMatch = "In-Match"
    case postMatch = "Post-Match"
    case training = "Training"
    case restDay = "Rest Day"
    case any = "Any Time"
}
