import Foundation

nonisolated struct ConversationSummary: Codable, Sendable {
    let summary: String
    let emotionalTone: String
    let mainTopics: [String]
    let timestamp: Date

    init(summary: String, emotionalTone: String = "", mainTopics: [String] = []) {
        self.summary = summary
        self.emotionalTone = emotionalTone
        self.mainTopics = mainTopics
        self.timestamp = Date()
    }

    static let empty = ConversationSummary(summary: "")
}
