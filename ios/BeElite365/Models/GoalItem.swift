import Foundation
import SwiftData

@Model
class GoalItem {
    var id: UUID
    var text: String
    var categoryRaw: String
    var currentValue: Double
    var targetValue: Double
    var unit: String
    var source: String
    var isCompleted: Bool
    var completedAt: Date?
    var createdAt: Date

    var category: GoalCategory {
        get { GoalCategory(rawValue: categoryRaw) ?? .mental }
        set { categoryRaw = newValue.rawValue }
    }

    var progress: Double {
        guard targetValue > 0 else { return 0 }
        return min(1.0, max(0, currentValue / targetValue))
    }

    init(
        text: String,
        category: GoalCategory,
        currentValue: Double = 0,
        targetValue: Double = 100,
        unit: String = "%",
        source: String = "Custom Goal"
    ) {
        self.id = UUID()
        self.text = text
        self.categoryRaw = category.rawValue
        self.currentValue = currentValue
        self.targetValue = targetValue
        self.unit = unit
        self.source = source
        self.isCompleted = false
        self.completedAt = nil
        self.createdAt = Date()
    }
}

nonisolated enum GoalCategory: String, CaseIterable, Codable, Sendable, Identifiable {
    case mental = "Mental"
    case technical = "Technical"
    case physical = "Physical"
    case lifestyle = "Lifestyle"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .mental: "brain.head.profile"
        case .technical: "target"
        case .physical: "figure.run"
        case .lifestyle: "moon.stars"
        }
    }
}
