import Foundation
import SwiftData

@Model
class DailyCheckIn {
    var date: Date
    var typeRaw: String
    var mentalPrepRating: Double
    var practiceRating: Double
    var performanceRating: Double
    var currentRStageRaw: String
    var energyLoopRaw: String
    var confidenceLevel: Double
    var focusRating: Double
    var emotionalControlRating: Double
    var usedReset: Bool
    var usedRegroup: Bool
    var usedRefocus: Bool
    var notes: String

    var checkInType: CheckInType {
        get { CheckInType(rawValue: typeRaw) ?? .daily }
        set { typeRaw = newValue.rawValue }
    }

    var rStage: RStage {
        get { RStage(rawValue: currentRStageRaw) ?? .reset }
        set { currentRStageRaw = newValue.rawValue }
    }

    var energyLoop: EnergyLoopState {
        get { EnergyLoopState(rawValue: energyLoopRaw) ?? .neutral }
        set { energyLoopRaw = newValue.rawValue }
    }

    var triangleAverage: Double {
        (mentalPrepRating + practiceRating + performanceRating) / 3.0
    }

    init(
        date: Date = Date(),
        type: CheckInType = .daily,
        mentalPrepRating: Double,
        practiceRating: Double,
        performanceRating: Double,
        rStage: RStage,
        energyLoop: EnergyLoopState,
        confidenceLevel: Double,
        focusRating: Double = 50,
        emotionalControlRating: Double = 50,
        usedReset: Bool = false,
        usedRegroup: Bool = false,
        usedRefocus: Bool = false,
        notes: String = ""
    ) {
        self.date = date
        self.typeRaw = type.rawValue
        self.mentalPrepRating = mentalPrepRating
        self.practiceRating = practiceRating
        self.performanceRating = performanceRating
        self.currentRStageRaw = rStage.rawValue
        self.energyLoopRaw = energyLoop.rawValue
        self.confidenceLevel = confidenceLevel
        self.focusRating = focusRating
        self.emotionalControlRating = emotionalControlRating
        self.usedReset = usedReset
        self.usedRegroup = usedRegroup
        self.usedRefocus = usedRefocus
        self.notes = notes
    }
}
