import SwiftUI
import SwiftData

@Observable
class CoachViewModel {
    var messages: [ConversationMessage] = []
    var currentMessage: String = ""
    var isProcessing: Bool = false
    var isStreaming: Bool = false
    var showSafetyAlert: Bool = false
    var showErrorAlert: Bool = false
    var errorAlertMessage: String = ""
    var suggestedDrills: [DrillSuggestion] = []
    var isVoiceMode: Bool = false
    var voiceOutputEnabled: Bool = false
    var lastIntent: MessageIntent = .casual
    var showMessageLimitAlert: Bool = false

    private var agent = CoachAgent()
    private var hasLoadedContext: Bool = false
    private var streamTask: Task<Void, Never>?

    func loadConversation(context: ModelContext) {
        guard !hasLoadedContext else { return }
        hasLoadedContext = true
        agent.loadContext(modelContext: context)

        let desc = FetchDescriptor<CoachConversation>(sortBy: [SortDescriptor(\.updatedAt, order: .reverse)])
        if let existing = try? context.fetch(desc).first,
           Calendar.current.isDateInToday(existing.updatedAt),
           !existing.messages.isEmpty {
            messages = existing.messages.map { msg in
                ConversationMessage(
                    role: msg.isUser ? .user : .coach,
                    content: msg.content
                )
            }
            agent.restoreHistory(from: messages)
        } else {
            let profile = fetchProfile(context: context)
            let name = profile?.name ?? ""
            let firstName = name.components(separatedBy: " ").first ?? name
            let hasName = !firstName.isEmpty
            let greeting = hasName ? "Hey, \(firstName). What's on your mind?" : "Hey. I'm here. What's on your mind?"
            messages = [ConversationMessage(role: .coach, content: greeting)]
        }
    }

    func sendMessage(context: ModelContext, speechService: SpeechService? = nil) {
        let text = currentMessage.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty, !isProcessing else { return }

        if agent.containsCrisisContent(text) {
            showSafetyAlert = true
            currentMessage = ""
            return
        }

        messages.append(ConversationMessage(role: .user, content: text))
        currentMessage = ""
        isProcessing = true
        isStreaming = false
        suggestedDrills = []

        let intent = agent.classifyIntent(text)
        lastIntent = intent
        agent.appendUserMessage(text)

        let profile = fetchProfile(context: context)
        let playerLevel = profile?.level ?? .academy

        if let profile, !profile.checkCoachMessageLimit() {
            messages.removeLast()
            currentMessage = text
            isProcessing = false
            showMessageLimitAlert = true
            return
        }

        profile?.incrementCoachMessages()

        let playerGender = profile?.gender ?? .preferNotToSay
        let systemPrompt = agent.buildSystemPrompt(for: intent, playerLevel: playerLevel, playerGender: playerGender)
        let history = agent.chatHistory()
        let mode = agent.determineMode(for: intent)
        let maxTokens = mode == .light ? 100 : 300

        streamTask?.cancel()
        streamTask = Task {
            await agent.runSummariserIfNeeded()

            var streamingMessage = ConversationMessage(role: .coach, content: "", isStreaming: true)
            messages.append(streamingMessage)
            let streamingIndex = messages.count - 1

            var fullResponse = ""
            var receivedAnyContent = false

            do {
                let stream = LLMClient.stream(systemPrompt: systemPrompt, history: Array(history.dropLast()), userMessage: text, maxTokens: maxTokens)

                for try await chunk in stream {
                    if Task.isCancelled { break }
                    receivedAnyContent = true
                    if !isStreaming {
                        isStreaming = true
                    }
                    fullResponse += chunk
                    messages[streamingIndex].content = fullResponse
                }

                if !receivedAnyContent {
                    let fallback = try await LLMClient.send(systemPrompt: systemPrompt, history: Array(history.dropLast()), userMessage: text, maxTokens: maxTokens)
                    fullResponse = fallback
                    messages[streamingIndex].content = fullResponse
                }
            } catch let clientError as LLMClient.ClientError {
                if fullResponse.isEmpty {
                    messages.remove(at: streamingIndex)
                    errorAlertMessage = clientError.userMessage
                    showErrorAlert = true
                    agent.conversationHistory.removeLast()
                    isProcessing = false
                    isStreaming = false
                    return
                }
            } catch {
                if fullResponse.isEmpty {
                    messages.remove(at: streamingIndex)
                    errorAlertMessage = "Something went wrong: \(error.localizedDescription)"
                    showErrorAlert = true
                    agent.conversationHistory.removeLast()
                    isProcessing = false
                    isStreaming = false
                    return
                }
            }

            messages[streamingIndex].isStreaming = false
            agent.appendAssistantMessage(fullResponse)
            persistConversation(userText: text, coachText: fullResponse, context: context)
            suggestedDrills = agent.suggestDrills(for: intent, responseText: fullResponse)

            if voiceOutputEnabled, let speech = speechService, !fullResponse.isEmpty {
                speech.speak(fullResponse)
            }

            isProcessing = false
            isStreaming = false
        }
    }

    func startNewConversation(context: ModelContext) {
        streamTask?.cancel()
        agent.loadContext(modelContext: context)
        agent.resetHistory()
        suggestedDrills = []
        isProcessing = false
        isStreaming = false

        let profile = fetchProfile(context: context)
        let name = profile?.name ?? ""
        let firstName = name.components(separatedBy: " ").first ?? name
        let hasName = !firstName.isEmpty

        let greetings = hasName ? [
            "Fresh session, \(firstName). What are we working on?",
            "New session. I'm here, \(firstName). What's up?",
            "Clean slate. What's on your mind, \(firstName)?"
        ] : [
            "New session. What are we working on?",
            "Fresh start. I'm here. What's up?",
            "Clean slate. Talk to me."
        ]

        messages = [ConversationMessage(role: .coach, content: greetings.randomElement()!)]
    }

    func sendVoiceMessage(text: String, context: ModelContext, speechService: SpeechService?) {
        currentMessage = text
        voiceOutputEnabled = true
        sendMessage(context: context, speechService: speechService)
    }

    private func fetchProfile(context: ModelContext) -> PlayerProfile? {
        let desc = FetchDescriptor<PlayerProfile>(sortBy: [SortDescriptor(\.createdAt, order: .reverse)])
        return try? context.fetch(desc).first
    }

    private func persistConversation(userText: String, coachText: String, context: ModelContext) {
        let conversation = getOrCreateConversation(context: context)

        let userMsg = CoachMessageData(content: userText, isUser: true)
        conversation.addMessage(userMsg)

        let coachMsg = CoachMessageData(content: coachText, isUser: false)
        conversation.addMessage(coachMsg)
    }

    private func getOrCreateConversation(context: ModelContext) -> CoachConversation {
        let desc = FetchDescriptor<CoachConversation>(sortBy: [SortDescriptor(\.updatedAt, order: .reverse)])
        if let existing = try? context.fetch(desc).first,
           Calendar.current.isDateInToday(existing.updatedAt) {
            return existing
        }
        let conversation = CoachConversation()
        context.insert(conversation)
        return conversation
    }
}
