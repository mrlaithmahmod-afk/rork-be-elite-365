import Foundation

struct ConversationSummariser {
    private static let summariseThreshold = 10
    private static let keepRecentCount = 4

    static func shouldSummarise(messageCount: Int, existingSummary: ConversationSummary?) -> Bool {
        if existingSummary == nil {
            return messageCount >= summariseThreshold
        }
        return messageCount >= summariseThreshold
    }

    static func summarise(
        messages: [LLMClient.ChatMessage],
        existingSummary: ConversationSummary?
    ) async -> (summary: ConversationSummary, recentMessages: [LLMClient.ChatMessage]) {
        let totalCount = messages.count
        guard totalCount >= summariseThreshold else {
            return (existingSummary ?? .empty, messages)
        }

        let messagesToSummarise = Array(messages.dropLast(keepRecentCount))
        let recentMessages = Array(messages.suffix(keepRecentCount))

        let summaryText = buildLocalSummary(from: messagesToSummarise, existingSummary: existingSummary)

        return (summaryText, recentMessages)
    }

    private static func buildLocalSummary(
        from messages: [LLMClient.ChatMessage],
        existingSummary: ConversationSummary?
    ) -> ConversationSummary {
        var topics: [String] = existingSummary?.mainTopics ?? []
        var emotionalWords: [String] = []
        var playerConcerns: [String] = []

        let emotionKeywords = ["nervous", "anxious", "scared", "worried", "stressed", "angry",
                               "frustrated", "upset", "sad", "down", "low", "confident",
                               "pressure", "doubt", "fear", "overwhelmed", "gutted"]

        let topicKeywords: [String: String] = [
            "match": "match preparation",
            "game": "match preparation",
            "mistake": "dealing with mistakes",
            "confidence": "confidence issues",
            "pressure": "handling pressure",
            "training": "training mindset",
            "coach": "coach relationship",
            "focus": "focus and concentration",
            "nervous": "pre-match nerves",
            "benched": "selection disappointment",
            "injury": "injury recovery"
        ]

        for message in messages {
            let lower = message.content.lowercased()

            if message.role == "user" {
                for keyword in emotionKeywords where lower.contains(keyword) {
                    emotionalWords.append(keyword)
                }

                for (keyword, topic) in topicKeywords where lower.contains(keyword) {
                    if !topics.contains(topic) {
                        topics.append(topic)
                    }
                }

                if message.content.count > 20 {
                    let trimmed = String(message.content.prefix(100))
                    playerConcerns.append(trimmed)
                }
            }
        }

        let dominantEmotion: String
        if emotionalWords.isEmpty {
            dominantEmotion = existingSummary?.emotionalTone ?? "neutral"
        } else {
            let counts = Dictionary(grouping: emotionalWords, by: { $0 })
            dominantEmotion = counts.max(by: { $0.value.count < $1.value.count })?.key ?? "mixed"
        }

        var summaryParts: [String] = []
        if let existing = existingSummary, !existing.summary.isEmpty {
            summaryParts.append("Previous: \(existing.summary)")
        }
        if !playerConcerns.isEmpty {
            let recentConcerns = playerConcerns.suffix(3).joined(separator: ". ")
            summaryParts.append("Player discussed: \(recentConcerns)")
        }
        if !emotionalWords.isEmpty {
            let uniqueEmotions = Array(Set(emotionalWords)).prefix(4)
            summaryParts.append("Emotional tone: \(uniqueEmotions.joined(separator: ", "))")
        }

        let summaryText = summaryParts.isEmpty ? "General conversation, no specific issues raised." : summaryParts.joined(separator: ". ")

        return ConversationSummary(
            summary: String(summaryText.prefix(500)),
            emotionalTone: dominantEmotion,
            mainTopics: Array(topics.prefix(5))
        )
    }
}
