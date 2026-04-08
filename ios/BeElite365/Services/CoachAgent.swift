import Foundation
import SwiftData

nonisolated enum MessageIntent: Sendable {
    case greeting
    case casual
    case relational
    case identityQuestion
    case emotionalIssue
    case performanceIssue
    case preMatchNerves
    case postMatchReflection
    case thankYou
    case question
}

nonisolated struct DrillSuggestion: Sendable, Identifiable {
    let id = UUID()
    let drillType: String
    let title: String
    let icon: String
    let reason: String
    let urgency: Urgency
    let durationSeconds: Int

    nonisolated enum Urgency: String, Sendable {
        case low
        case medium
        case high
    }
}

@Observable
class CoachAgent {
    var conversationHistory: [LLMClient.ChatMessage] = []
    var conversationSummary: ConversationSummary?

    private var memory: PlayerMemory?
    private var debriefSummaries: [String] = []
    private var vaultSummaries: [String] = []
    private var matchDaySummary: String?
    private var debriefPatterns: String?
    private let maxHistoryMessages = 20
    private let summariseThreshold = 10

    private let crisisKeywords: [String] = [
        "kill myself", "suicide", "self-harm", "hurt myself",
        "end it all", "don't want to live", "want to die",
        "cutting myself", "harming myself"
    ]

    func loadContext(modelContext: ModelContext) {
        memory = ContextBuilder.buildMemory(context: modelContext)
        debriefSummaries = ContextBuilder.buildDebriefSummaries(context: modelContext)
        vaultSummaries = ContextBuilder.buildVaultSummaries(context: modelContext)
        matchDaySummary = ContextBuilder.buildMatchDaySummary(context: modelContext)
        debriefPatterns = ContextBuilder.recentDebriefPatterns(context: modelContext)
    }

    func resetHistory() {
        conversationHistory = []
        conversationSummary = nil
    }

    func restoreHistory(from messages: [ConversationMessage]) {
        conversationHistory = []
        let recent = messages.suffix(maxHistoryMessages)
        for msg in recent {
            let role = msg.role == .user ? "user" : "assistant"
            conversationHistory.append(LLMClient.ChatMessage(role: role, content: msg.content))
        }
    }

    func containsCrisisContent(_ text: String) -> Bool {
        let lower = text.lowercased()
        return crisisKeywords.contains { lower.contains($0) }
    }

    func classifyIntent(_ text: String) -> MessageIntent {
        let lower = text.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        let wordCount = lower.split(separator: " ").count

        let greetingExact = ["hi", "hey", "hello", "yo", "sup", "hiya", "alright", "morning", "evening", "afternoon", "good morning", "good evening", "good afternoon", "hey coach", "hi coach", "yo coach"]
        if greetingExact.contains(where: { lower == $0 }) {
            return .greeting
        }
        if wordCount <= 4 {
            let greetingStarts = ["hi ", "hey ", "hello ", "yo ", "hiya ", "alright ", "morning ", "evening "]
            if greetingStarts.contains(where: { lower.hasPrefix($0) }) {
                return .greeting
            }
        }

        let identityPatterns = ["what's your name", "whats your name", "what is your name", "who are you", "what are you", "are you real", "are you a bot", "are you ai", "are you human", "tell me about yourself", "what do you do", "what can you do"]
        if identityPatterns.contains(where: { lower.contains($0) }) {
            return .identityQuestion
        }

        let howAreYou = ["how are you", "how you doing", "how are things", "how's it going", "hows it going", "how you been", "you good", "you alright", "you okay", "what's up", "whats up", "wassup"]
        if howAreYou.contains(where: { lower.contains($0) }) && wordCount <= 6 {
            return .greeting
        }

        if lower.contains("thank") || lower.contains("cheers") || lower.contains("nice one") || lower.contains("appreciate") || lower.contains("thanks") {
            return .thankYou
        }

        let relationalBids = ["i need someone", "i need to talk", "can you talk", "can we talk", "i just need", "i feel off", "i'm not okay", "im not okay", "just want to talk", "need someone to speak", "i feel alone", "i feel lost", "nobody understands", "can i talk to you", "i need help", "help me"]
        if relationalBids.contains(where: { lower.contains($0) }) {
            return .relational
        }

        if lower.contains("before the match") || lower.contains("pre-match") || lower.contains("match tomorrow") || lower.contains("game tomorrow") || lower.contains("nervous before") || lower.contains("match today") || lower.contains("game today") || lower.contains("playing today") || lower.contains("playing tomorrow") || lower.contains("big game") {
            return .preMatchNerves
        }

        if lower.contains("after the match") || lower.contains("post-match") || lower.contains("played today") || lower.contains("played yesterday") || lower.contains("played badly") || lower.contains("played well") || lower.contains("we lost") || lower.contains("we won") || lower.contains("got subbed") || lower.contains("got benched") {
            return .postMatchReflection
        }

        let emotionWords = ["nervous", "anxious", "scared", "worried", "stressed", "angry", "frustrated", "upset", "sad", "down", "low", "hopeless", "doubt", "fear", "overwhelmed", "drained", "exhausted", "embarrassed", "ashamed", "panicking", "depressed", "gutted", "devastated"]
        if emotionWords.contains(where: { lower.contains($0) }) {
            return .emotionalIssue
        }

        let performanceWords = ["mistake", "error", "messed up", "missed", "lost the ball", "benched", "subbed", "coach said", "criticism", "confidence", "focus", "concentration", "pressure", "penalty", "training", "session", "performance", "form", "inconsistent", "losing my head", "switched off", "lost my head"]
        if performanceWords.contains(where: { lower.contains($0) }) {
            return .performanceIssue
        }

        let casualExact = ["good", "fine", "ok", "okay", "not bad", "yeah", "yep", "nah", "cool", "decent", "alright", "great", "nice", "all good", "im good", "i'm good", "doing well", "not much", "nothing much", "same old"]
        if wordCount <= 5 && casualExact.contains(where: { lower == $0 || lower.hasPrefix($0) }) {
            return .casual
        }

        if lower.contains("?") || lower.hasPrefix("how") || lower.hasPrefix("what") || lower.hasPrefix("why") || lower.hasPrefix("should") || lower.hasPrefix("can") || lower.hasPrefix("do you") || lower.hasPrefix("is it") || lower.hasPrefix("when") {
            return .question
        }

        if wordCount <= 5 {
            return .casual
        }

        return .performanceIssue
    }

    func determineMode(for intent: MessageIntent) -> PromptBuilder.ResponseMode {
        switch intent {
        case .greeting, .casual, .thankYou, .identityQuestion:
            return .light
        case .relational, .emotionalIssue, .performanceIssue, .preMatchNerves, .postMatchReflection, .question:
            return .coach
        }
    }

    func buildSystemPrompt(for intent: MessageIntent, playerLevel: PlayingLevel = .academy, playerGender: Gender = .preferNotToSay) -> String {
        let mode = determineMode(for: intent)
        let mem = memory ?? defaultMemory()
        return PromptBuilder.buildSystemPrompt(
            memory: mem,
            intent: intent,
            mode: mode,
            conversationSummary: conversationSummary,
            playerLevel: playerLevel,
            playerGender: playerGender,
            debriefSummaries: debriefSummaries,
            vaultSummaries: vaultSummaries,
            matchDaySummary: matchDaySummary,
            debriefPatterns: debriefPatterns
        )
    }

    func chatHistory() -> [LLMClient.ChatMessage] {
        Array(conversationHistory.suffix(maxHistoryMessages))
    }

    func appendUserMessage(_ text: String) {
        conversationHistory.append(LLMClient.ChatMessage(role: "user", content: text))
        trimHistory()
    }

    func appendAssistantMessage(_ text: String) {
        conversationHistory.append(LLMClient.ChatMessage(role: "assistant", content: text))
        trimHistory()
    }

    func runSummariserIfNeeded() async {
        guard ConversationSummariser.shouldSummarise(
            messageCount: conversationHistory.count,
            existingSummary: conversationSummary
        ) else { return }

        let result = await ConversationSummariser.summarise(
            messages: conversationHistory,
            existingSummary: conversationSummary
        )

        conversationSummary = result.summary
        conversationHistory = result.recentMessages
    }

    func suggestDrills(for intent: MessageIntent, responseText: String) -> [DrillSuggestion] {
        let lower = responseText.lowercased()
        var suggestions: [DrillSuggestion] = []

        switch intent {
        case .emotionalIssue:
            if lower.contains("breath") || lower.contains("calm") || lower.contains("anxiety") || lower.contains("nervous") {
                suggestions.append(DrillSuggestion(
                    drillType: "physiological_sigh",
                    title: "Quick Reset",
                    icon: "wind",
                    reason: "Recommended because you're dealing with strong emotions right now",
                    urgency: .high,
                    durationSeconds: 60
                ))
            }
            suggestions.append(DrillSuggestion(
                drillType: "cognitive_defusion",
                title: "Thought Interrupt",
                icon: "brain.head.profile",
                reason: "Helps detach from negative thought patterns",
                urgency: .medium,
                durationSeconds: 120
            ))

        case .performanceIssue:
            suggestions.append(DrillSuggestion(
                drillType: "reset_game",
                title: "10-Second Reset",
                icon: "timer",
                reason: "Train fast recovery after a setback",
                urgency: .high,
                durationSeconds: 30
            ))
            if lower.contains("mistake") || lower.contains("error") {
                suggestions.append(DrillSuggestion(
                    drillType: "mistake_recovery",
                    title: "Mistake Recovery",
                    icon: "arrow.counterclockwise",
                    reason: "Build your recovery speed after mistakes",
                    urgency: .high,
                    durationSeconds: 60
                ))
            }

        case .preMatchNerves:
            suggestions.append(DrillSuggestion(
                drillType: "pre_match_visualization",
                title: "Pre-Match Routine",
                icon: "figure.run",
                reason: "Get mentally locked in before the game",
                urgency: .high,
                durationSeconds: 180
            ))
            suggestions.append(DrillSuggestion(
                drillType: "box_breathing",
                title: "Box Breathing",
                icon: "square",
                reason: "Settle your system before kickoff",
                urgency: .medium,
                durationSeconds: 120
            ))

        case .postMatchReflection:
            suggestions.append(DrillSuggestion(
                drillType: "confidence_replay",
                title: "Confidence Replay",
                icon: "star.fill",
                reason: "Anchor your best moments from today",
                urgency: .medium,
                durationSeconds: 180
            ))

        case .relational:
            suggestions.append(DrillSuggestion(
                drillType: "physiological_sigh",
                title: "Quick Reset",
                icon: "wind",
                reason: "A short reset to settle yourself",
                urgency: .low,
                durationSeconds: 60
            ))

        default:
            break
        }

        return Array(suggestions.prefix(2))
    }

    private func trimHistory() {
        if conversationHistory.count > maxHistoryMessages {
            conversationHistory = Array(conversationHistory.suffix(maxHistoryMessages))
        }
    }

    private func defaultMemory() -> PlayerMemory {
        PlayerMemory(
            identity: .init(name: "Athlete", gender: "Unknown", position: "Unknown", level: "Academy", ageBand: "19-24", isMinor: false, primaryGoal: ""),
            patterns: .init(dominantIssues: [], mainTrigger: "", pressurePoint: "", mistakeResponse: "", selfTalkStyle: "", skippedRStage: "Reset", confidenceStyle: "", decisionHabit: "", commonBreakdownPattern: ""),
            recentState: .init(confidenceTrend: [], confidenceDirection: "not enough data", energyLoopState: "Neutral", currentRStage: "Reset", mentalPrepScore: 50, practiceScore: 50, performanceScore: 50, nextMatchHours: nil, nextMatchOpponent: nil, lastDrillUsed: nil, recentDrillCount: 0, recentSolutionSummaries: [])
        )
    }
}
