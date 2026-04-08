import Foundation

nonisolated struct FootballersPrinciple: Identifiable, Sendable {
    let id: String
    let name: String
    let description: String
}

struct FootballersPyramidData {
    static let principles: [FootballersPrinciple] = [
        FootballersPrinciple(id: "discipline", name: "Discipline", description: "Consistency in training, lifestyle, and decision-making"),
        FootballersPrinciple(id: "determination", name: "Determination", description: "Relentless drive to achieve your goals no matter what"),
        FootballersPrinciple(id: "dedication", name: "Dedication", description: "Full commitment to improving every single day"),
        FootballersPrinciple(id: "balance", name: "Balance", description: "Harmony between football, rest, and personal life"),
        FootballersPrinciple(id: "patience", name: "Patience", description: "Trusting the process and staying calm through setbacks"),
        FootballersPrinciple(id: "persistence", name: "Persistence", description: "Continuing to push forward when progress feels slow"),
        FootballersPrinciple(id: "perseverance", name: "Perseverance", description: "Overcoming obstacles and never giving up on your dream"),
        FootballersPrinciple(id: "resilience", name: "Resilience", description: "Bouncing back stronger after failure or injury"),
        FootballersPrinciple(id: "focus", name: "Focus", description: "Eliminating distractions and staying locked in on what matters"),
        FootballersPrinciple(id: "confidence", name: "Confidence", description: "Belief in your ability to perform at the highest level"),
        FootballersPrinciple(id: "sacrifice", name: "Sacrifice", description: "Giving up short-term comfort for long-term greatness"),
        FootballersPrinciple(id: "hunger", name: "Hunger", description: "An insatiable appetite to win and keep improving"),
        FootballersPrinciple(id: "accountability", name: "Accountability", description: "Taking ownership of your performances and mistakes"),
        FootballersPrinciple(id: "leadership", name: "Leadership", description: "Inspiring teammates and leading by example on and off the pitch"),
        FootballersPrinciple(id: "humility", name: "Humility", description: "Staying grounded and open to learning from anyone"),
    ]

    static func principle(for id: String) -> FootballersPrinciple? {
        principles.first { $0.id == id }
    }

    nonisolated struct PyramidTier: Sendable {
        let name: String
        let slotCount: Int
        let description: String
    }

    static let tiers: [PyramidTier] = [
        PyramidTier(name: "The Foundation", slotCount: 4, description: "The non-negotiable base behaviours required for any footballer."),
        PyramidTier(name: "The Growth Engine", slotCount: 2, description: "The drivers that accelerate your development and separate good from great."),
        PyramidTier(name: "The Peak", slotCount: 1, description: "The ultimate expression of your mental game."),
    ]

    static let storageKey = "footballersPyramidSlots"

    static func loadSlots() -> [String: String?] {
        guard let data = UserDefaults.standard.data(forKey: storageKey),
              let decoded = try? JSONDecoder().decode([String: String].self, from: data) else {
            return defaultSlots()
        }
        var result: [String: String?] = defaultSlots()
        for (key, value) in decoded {
            result[key] = value
        }
        return result
    }

    static func saveSlots(_ slots: [String: String?]) {
        var toEncode: [String: String] = [:]
        for (key, value) in slots {
            if let v = value {
                toEncode[key] = v
            }
        }
        if let data = try? JSONEncoder().encode(toEncode) {
            UserDefaults.standard.set(data, forKey: storageKey)
        }
    }

    static func defaultSlots() -> [String: String?] {
        [
            "foundation-0": nil,
            "foundation-1": nil,
            "foundation-2": nil,
            "foundation-3": nil,
            "growth-0": nil,
            "growth-1": nil,
            "peak-0": nil,
        ]
    }
}
