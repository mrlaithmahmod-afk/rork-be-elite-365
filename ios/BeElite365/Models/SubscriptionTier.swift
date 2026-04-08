import Foundation

nonisolated enum SubscriptionTier: String, Codable, CaseIterable, Sendable, Identifiable {
    case free = "Free"
    case perform = "Perform"
    case progress = "Progress"
    case elite = "Elite"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .free: "Free"
        case .perform: "Perform"
        case .progress: "Progress"
        case .elite: "Elite"
        }
    }

    var monthlyPrice: String {
        switch self {
        case .free: "Free"
        case .perform: "\u{00A3}4.99/mo"
        case .progress: "\u{00A3}9.99/mo"
        case .elite: "\u{00A3}14.99/mo"
        }
    }

    var yearlyPrice: String {
        switch self {
        case .free: "Free"
        case .perform: "\u{00A3}39.99/yr"
        case .progress: "\u{00A3}79.99/yr"
        case .elite: "\u{00A3}119.99/yr"
        }
    }

    var yearlyMonthlyEquivalent: String {
        switch self {
        case .free: "Free"
        case .perform: "\u{00A3}3.33/mo"
        case .progress: "\u{00A3}6.67/mo"
        case .elite: "\u{00A3}9.99/mo"
        }
    }

    var tagline: String {
        switch self {
        case .free: "Get started"
        case .perform: "Build your mental game"
        case .progress: "Accelerate your development"
        case .elite: "Peak performance system"
        }
    }

    var rank: Int {
        switch self {
        case .free: 0
        case .perform: 1
        case .progress: 2
        case .elite: 3
        }
    }

    func meetsMinimum(_ required: SubscriptionTier) -> Bool {
        rank >= required.rank
    }
}
