import Foundation
import SwiftData

@Model
class DrillCompletion {
    var drillID: String
    var completedAt: Date
    var effectiveness: Int
    var contextRaw: String

    var context: DrillContext {
        get { DrillContext(rawValue: contextRaw) ?? .any }
        set { contextRaw = newValue.rawValue }
    }

    init(drillID: String, effectiveness: Int = 3, context: DrillContext = .any) {
        self.drillID = drillID
        self.completedAt = Date()
        self.effectiveness = effectiveness
        self.contextRaw = context.rawValue
    }
}
