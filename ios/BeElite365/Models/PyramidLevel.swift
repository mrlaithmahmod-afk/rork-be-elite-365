import Foundation

struct PyramidLevel: Identifiable, Sendable {
    let id: Int
    let name: String
    let description: String
    let icon: String
    let requiredDrillCount: Int
    let skills: [String]

    var isUnlocked: Bool { false }
}

struct ElitePyramid {
    static let levels: [PyramidLevel] = [
        PyramidLevel(
            id: 1,
            name: "Awareness",
            description: "Recognise your emotional and mental patterns under pressure.",
            icon: "eye",
            requiredDrillCount: 0,
            skills: ["Emotional recognition", "Trigger identification", "Self-awareness"]
        ),
        PyramidLevel(
            id: 2,
            name: "Emotional Control",
            description: "Manage emotional responses without suppressing them.",
            icon: "waveform.path",
            requiredDrillCount: 5,
            skills: ["Breathing reset", "Body language control", "Anger channelling"]
        ),
        PyramidLevel(
            id: 3,
            name: "Confidence Stability",
            description: "Build confidence through controllable actions, not results.",
            icon: "shield.checkered",
            requiredDrillCount: 15,
            skills: ["Evidence-based confidence", "Self-talk management", "Process focus"]
        ),
        PyramidLevel(
            id: 4,
            name: "Pressure Mastery",
            description: "Perform at your best when the stakes are highest.",
            icon: "flame",
            requiredDrillCount: 30,
            skills: ["Pre-match routine", "Penalty composure", "Crowd focus"]
        ),
        PyramidLevel(
            id: 5,
            name: "Elite Consistency",
            description: "Sustain high performance across an entire season.",
            icon: "crown",
            requiredDrillCount: 50,
            skills: ["Season-long discipline", "Recovery automation", "Mental endurance"]
        ),
    ]

    static func currentLevel(drillCount: Int) -> Int {
        for level in levels.reversed() {
            if drillCount >= level.requiredDrillCount {
                return level.id
            }
        }
        return 1
    }

    static func progressToNext(drillCount: Int) -> Double {
        let current = currentLevel(drillCount: drillCount)
        guard current < levels.count else { return 1.0 }
        let currentRequired = levels[current - 1].requiredDrillCount
        let nextRequired = levels[current].requiredDrillCount
        let range = nextRequired - currentRequired
        guard range > 0 else { return 1.0 }
        return min(1.0, Double(drillCount - currentRequired) / Double(range))
    }
}
