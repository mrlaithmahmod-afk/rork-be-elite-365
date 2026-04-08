import Foundation
import SwiftData

@Model
class SolutionCard {
    var situationTypeRaw: String
    var situationDescription: String
    var emotionTypeRaw: String
    var emotionIntensity: Double
    var triangleBreakdownRaw: String
    var skippedRRaw: String
    var reframe: String
    var microActions: [String]
    var refocusAction: String
    var ifThenTrigger: String
    var ifThenResponse: String
    var tags: [String]
    var isPinned: Bool
    var usageCount: Int
    var lastUsedDate: Date?
    var createdAt: Date
    var isBookmarked: Bool

    var situationType: SituationType {
        SituationType(rawValue: situationTypeRaw) ?? .other
    }

    var emotionType: EmotionType {
        EmotionType(rawValue: emotionTypeRaw) ?? .frustrated
    }

    var triangleBreakdown: TriangleSide {
        TriangleSide(rawValue: triangleBreakdownRaw) ?? .performance
    }

    var skippedR: RStage {
        RStage(rawValue: skippedRRaw) ?? .reset
    }

    var ifThenScript: String {
        guard !ifThenTrigger.isEmpty, !ifThenResponse.isEmpty else { return "" }
        return "If \(ifThenTrigger), then I will \(ifThenResponse)"
    }

    init(
        situationType: SituationType,
        situationDescription: String,
        emotionType: EmotionType,
        emotionIntensity: Double,
        triangleBreakdown: TriangleSide,
        skippedR: RStage,
        reframe: String,
        microActions: [String],
        refocusAction: String,
        ifThenTrigger: String,
        ifThenResponse: String,
        tags: [String] = []
    ) {
        self.situationTypeRaw = situationType.rawValue
        self.situationDescription = situationDescription
        self.emotionTypeRaw = emotionType.rawValue
        self.emotionIntensity = emotionIntensity
        self.triangleBreakdownRaw = triangleBreakdown.rawValue
        self.skippedRRaw = skippedR.rawValue
        self.reframe = reframe
        self.microActions = microActions
        self.refocusAction = refocusAction
        self.ifThenTrigger = ifThenTrigger
        self.ifThenResponse = ifThenResponse
        self.tags = tags
        self.isPinned = false
        self.usageCount = 0
        self.lastUsedDate = nil
        self.createdAt = Date()
        self.isBookmarked = false
    }

    func recordUsage() {
        usageCount += 1
        lastUsedDate = Date()
    }
}
