import Foundation
import SwiftData

@Model
class CoachConversation {
    var id: UUID
    var messages: [CoachMessageData]
    var detectedRStageRaw: String?
    var triangleBreakdownRaw: String?
    var energyLoopRaw: String?
    var topicTags: [String]
    var hasSafetyFlag: Bool
    var createdAt: Date
    var updatedAt: Date

    init() {
        self.id = UUID()
        self.messages = []
        self.detectedRStageRaw = nil
        self.triangleBreakdownRaw = nil
        self.energyLoopRaw = nil
        self.topicTags = []
        self.hasSafetyFlag = false
        self.createdAt = Date()
        self.updatedAt = Date()
    }

    func addMessage(_ message: CoachMessageData) {
        messages.append(message)
        updatedAt = Date()
    }
}

nonisolated struct CoachMessageData: Codable, Sendable, Identifiable {
    let id: UUID
    let content: String
    let isUser: Bool
    let timestamp: Date
    var resetInstruction: String?
    var regroupInstruction: String?
    var refocusInstruction: String?
    var ifThenScript: String?

    init(content: String, isUser: Bool) {
        self.id = UUID()
        self.content = content
        self.isUser = isUser
        self.timestamp = Date()
    }
}
