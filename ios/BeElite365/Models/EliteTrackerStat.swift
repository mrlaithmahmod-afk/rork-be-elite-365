import Foundation

nonisolated struct TrackerStatConfig: Identifiable, Sendable {
    let id: String
    let label: String
    let unit: String
    let lowerIsBetter: Bool

    init(id: String, label: String, unit: String, lowerIsBetter: Bool = false) {
        self.id = id
        self.label = label
        self.unit = unit
        self.lowerIsBetter = lowerIsBetter
    }
}

nonisolated struct TrackerCategory: Identifiable, Sendable {
    let id: String
    let title: String
    let icon: String
    let stats: [TrackerStatConfig]
}

struct EliteTrackerData {
    static let categories: [TrackerCategory] = [
        TrackerCategory(
            id: "speed",
            title: "Speed & Agility",
            icon: "bolt.fill",
            stats: [
                TrackerStatConfig(id: "sprintSpeed", label: "Sprint Speed", unit: "km/h"),
                TrackerStatConfig(id: "agility", label: "Agility", unit: "/10"),
            ]
        ),
        TrackerCategory(
            id: "strength",
            title: "Strength & Fitness",
            icon: "figure.strengthtraining.traditional",
            stats: [
                TrackerStatConfig(id: "vo2Max", label: "VO2 Max", unit: ""),
                TrackerStatConfig(id: "pushUps", label: "Max Push-ups", unit: ""),
                TrackerStatConfig(id: "plankHold", label: "Plank Hold", unit: "s"),
            ]
        ),
        TrackerCategory(
            id: "technical",
            title: "Technical",
            icon: "soccerball",
            stats: [
                TrackerStatConfig(id: "weakFootAccuracy", label: "Weak Foot Accuracy", unit: "%"),
                TrackerStatConfig(id: "firstTouch", label: "First Touch Rating", unit: "/10"),
                TrackerStatConfig(id: "passCompletion", label: "Pass Completion", unit: "%"),
            ]
        ),
        TrackerCategory(
            id: "recovery",
            title: "Recovery",
            icon: "bed.double.fill",
            stats: [
                TrackerStatConfig(id: "sleepQuality", label: "Sleep Quality", unit: "/10"),
                TrackerStatConfig(id: "restingHeartRate", label: "Resting Heart Rate", unit: "bpm", lowerIsBetter: true),
                TrackerStatConfig(id: "hydration", label: "Hydration Score", unit: "/10"),
            ]
        ),
    ]

    private static let storageKey = "eliteTrackerStats"

    nonisolated struct StatValue: Codable, Sendable {
        var current: Double
        var previous: Double
        var lastUpdated: String
    }

    static func loadStats() -> [String: StatValue] {
        guard let data = UserDefaults.standard.data(forKey: storageKey),
              let decoded = try? JSONDecoder().decode([String: StatValue].self, from: data) else {
            return defaultStats()
        }
        return decoded
    }

    static func saveStats(_ stats: [String: StatValue]) {
        if let data = try? JSONEncoder().encode(stats) {
            UserDefaults.standard.set(data, forKey: storageKey)
        }
    }

    static func defaultStats() -> [String: StatValue] {
        var stats: [String: StatValue] = [:]
        let dateStr = Date().formatted(date: .abbreviated, time: .omitted)
        for category in categories {
            for stat in category.stats {
                stats[stat.id] = StatValue(current: 0, previous: 0, lastUpdated: dateStr)
            }
        }
        return stats
    }
}
