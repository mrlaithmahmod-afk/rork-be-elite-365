import SwiftUI
import SwiftData

struct CoachView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel = CoachViewModel()
    @State private var speechService = SpeechService()
    @State private var showVoiceMode: Bool = false
    @State private var showPaywall: Bool = false
    @FocusState private var isInputFocused: Bool

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                chatArea

                if !viewModel.suggestedDrills.isEmpty && !viewModel.isProcessing {
                    suggestedDrillsBar
                }

                Divider()
                    .overlay(Color(.separator))

                inputBar
            }
            .background(Color(.systemBackground))
            .navigationTitle("Mental Mentor")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        viewModel.voiceOutputEnabled.toggle()
                    } label: {
                        Image(systemName: viewModel.voiceOutputEnabled ? "speaker.wave.2.fill" : "speaker.slash")
                            .font(.subheadline)
                            .foregroundStyle(viewModel.voiceOutputEnabled ? AppTheme.gold : .secondary)
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        viewModel.startNewConversation(context: modelContext)
                    } label: {
                        Image(systemName: "plus.message")
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .task { viewModel.loadConversation(context: modelContext) }
            .fullScreenCover(isPresented: $showVoiceMode) {
                VoiceCoachView(viewModel: viewModel, speechService: speechService)
                    .environment(\.modelContext, modelContext)
            }
            .alert("Support Available", isPresented: $viewModel.showSafetyAlert) {
                Button("I Understand") {}
            } message: {
                Text("If you are in immediate danger, call emergency services.\n\nSamaritans (UK): 116 123\nChildline: 0800 1111\n\nTalk to a trusted adult, coach, or family member.\n\nThis app provides mental performance training, not medical or crisis support.")
            }
            .alert("Error", isPresented: $viewModel.showErrorAlert) {
                Button("OK") {}
            } message: {
                Text(viewModel.errorAlertMessage)
            }
            .alert("Daily Limit Reached", isPresented: $viewModel.showMessageLimitAlert) {
                Button("Upgrade") { showPaywall = true }
                Button("OK", role: .cancel) {}
            } message: {
                Text("You've used all your free coach messages today. Upgrade to unlock unlimited conversations.")
            }
            .sheet(isPresented: $showPaywall) {
                PaywallView()
            }
        }
    }

    private var chatArea: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(spacing: 12) {
                    ForEach(viewModel.messages) { message in
                        messageRow(message)
                            .id(message.id)
                    }
                }
                .padding(.vertical, 12)
            }
            .scrollDismissesKeyboard(.interactively)
            .onChange(of: viewModel.messages.last?.content) { _, _ in
                withAnimation(.easeOut(duration: 0.2)) {
                    if let last = viewModel.messages.last {
                        proxy.scrollTo(last.id, anchor: .bottom)
                    }
                }
            }
            .onChange(of: viewModel.messages.count) { _, _ in
                withAnimation(.easeOut(duration: 0.3)) {
                    if let last = viewModel.messages.last {
                        proxy.scrollTo(last.id, anchor: .bottom)
                    }
                }
            }
        }
    }

    private var suggestedDrillsBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(viewModel.suggestedDrills) { drill in
                    Button {
                        viewModel.currentMessage = "I want to try the \(drill.title)"
                        viewModel.sendMessage(context: modelContext, speechService: speechService)
                    } label: {
                        VStack(alignment: .leading, spacing: 2) {
                            HStack(spacing: 6) {
                                Image(systemName: drill.icon)
                                    .font(.caption2.weight(.semibold))
                                Text(drill.title)
                                    .font(.caption.weight(.medium))
                            }
                            Text(drill.reason)
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                                .lineLimit(1)
                        }
                        .foregroundStyle(AppTheme.gold)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(AppTheme.gold.opacity(0.1))
                        .clipShape(.rect(cornerRadius: 12))
                        .overlay(RoundedRectangle(cornerRadius: 12).strokeBorder(AppTheme.gold.opacity(0.25), lineWidth: 1))
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
        }
    }

    private var inputBar: some View {
        HStack(spacing: 8) {
            Button {
                showVoiceMode = true
            } label: {
                Image(systemName: "mic.fill")
                    .font(.title3)
                    .foregroundStyle(.secondary)
                    .frame(width: 36, height: 36)
            }

            TextField("", text: $viewModel.currentMessage, prompt: Text("What is on your mind?").foregroundStyle(.white.opacity(0.3)), axis: .vertical)
                .font(.subheadline)
                .lineLimit(1...4)
                .focused($isInputFocused)
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background(Color(.secondarySystemGroupedBackground))
                .clipShape(.rect(cornerRadius: 20))
                .submitLabel(.send)
                .onSubmit {
                    viewModel.sendMessage(context: modelContext, speechService: speechService)
                }

            Button {
                viewModel.sendMessage(context: modelContext, speechService: speechService)
            } label: {
                Image(systemName: "arrow.up.circle.fill")
                    .font(.title2)
                    .foregroundStyle(sendButtonDisabled ? .secondary : AppTheme.gold)
            }
            .disabled(sendButtonDisabled)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(Color(.systemBackground))
    }

    private var sendButtonDisabled: Bool {
        viewModel.currentMessage.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || viewModel.isProcessing
    }

    @ViewBuilder
    private func messageRow(_ message: ConversationMessage) -> some View {
        switch message.role {
        case .user:
            userBubble(message)
        case .coach:
            coachBubble(message)
        }
    }

    private func userBubble(_ message: ConversationMessage) -> some View {
        VStack(alignment: .trailing, spacing: 4) {
            Text(message.content)
                .font(.subheadline)
                .foregroundStyle(.black)
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background(AppTheme.gold)
                .clipShape(.rect(cornerRadius: 18, style: .continuous))

            Text(message.timestamp.formatted(date: .omitted, time: .shortened))
                .font(.caption2)
                .foregroundStyle(.quaternary)
        }
        .frame(maxWidth: 280, alignment: .trailing)
        .frame(maxWidth: .infinity, alignment: .trailing)
        .padding(.horizontal, 16)
    }

    private func coachBubble(_ message: ConversationMessage) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            if message.content.isEmpty && message.isStreaming {
                streamingIndicator
            } else {
                Text(message.content)
                    .font(.subheadline)
                    .foregroundStyle(.primary)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .background(Color(.secondarySystemGroupedBackground))
                    .clipShape(.rect(cornerRadius: 18, style: .continuous))
                    .animation(.none, value: message.content)
            }

            if !message.isStreaming {
                Text(message.timestamp.formatted(date: .omitted, time: .shortened))
                    .font(.caption2)
                    .foregroundStyle(.quaternary)
            }
        }
        .frame(maxWidth: 300, alignment: .leading)
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 16)
    }

    private var streamingIndicator: some View {
        HStack(spacing: 4) {
            ForEach(0..<3, id: \.self) { index in
                Circle()
                    .fill(AppTheme.gold.opacity(0.6))
                    .frame(width: 7, height: 7)
                    .offset(y: typingOffset(for: index))
                    .animation(
                        .easeInOut(duration: 0.5)
                        .repeatForever()
                        .delay(Double(index) * 0.15),
                        value: viewModel.isProcessing
                    )
            }
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 12)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(.rect(cornerRadius: 16))
    }

    private func typingOffset(for index: Int) -> CGFloat {
        viewModel.isProcessing ? -4 : 0
    }
}
