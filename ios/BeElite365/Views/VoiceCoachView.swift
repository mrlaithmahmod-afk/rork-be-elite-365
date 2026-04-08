import SwiftUI

struct VoiceCoachView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Bindable var viewModel: CoachViewModel
    let speechService: SpeechService

    @State private var pulseScale: CGFloat = 1.0
    @State private var showTranscript: Bool = false

    private var stateLabel: String {
        if speechService.isRecording { return "Listening..." }
        if viewModel.isProcessing { return "Thinking..." }
        if speechService.isSpeaking { return "Speaking..." }
        return "Tap to talk"
    }

    private var lastCoachMessage: String? {
        viewModel.messages.last(where: { $0.role == .coach })?.content
    }

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(spacing: 0) {
                HStack {
                    Spacer()
                    Button {
                        speechService.stopSpeaking()
                        speechService.stopRecording()
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title2)
                            .foregroundStyle(.white.opacity(0.5))
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)

                Spacer()

                VStack(spacing: 24) {
                    ZStack {
                        Circle()
                            .fill(AppTheme.gold.opacity(0.08))
                            .frame(width: 200, height: 200)
                            .scaleEffect(pulseScale)

                        Circle()
                            .fill(AppTheme.gold.opacity(0.15))
                            .frame(width: 140, height: 140)
                            .scaleEffect(speechService.isRecording ? 1.1 : 1.0)
                            .animation(.easeInOut(duration: 0.4), value: speechService.isRecording)

                        Image(systemName: micIcon)
                            .font(.system(size: 44, weight: .medium))
                            .foregroundStyle(micColor)
                            .contentTransition(.symbolEffect(.replace))
                    }
                    .animation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true), value: pulseScale)
                    .onAppear { pulseScale = 1.15 }

                    Text(stateLabel)
                        .font(.headline.weight(.medium))
                        .foregroundStyle(.white.opacity(0.7))
                        .contentTransition(.numericText())
                        .animation(.easeInOut(duration: 0.2), value: stateLabel)

                    if speechService.isRecording && !speechService.transcribedText.isEmpty {
                        Text(speechService.transcribedText)
                            .font(.body)
                            .foregroundStyle(.white.opacity(0.9))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 32)
                            .transition(.opacity)
                    }
                }

                Spacer()

                if let lastMsg = lastCoachMessage, showTranscript {
                    ScrollView {
                        Text(lastMsg)
                            .font(.subheadline)
                            .foregroundStyle(.white.opacity(0.8))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 32)
                    }
                    .frame(maxHeight: 160)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }

                HStack(spacing: 40) {
                    Button {
                        withAnimation { showTranscript.toggle() }
                    } label: {
                        VStack(spacing: 4) {
                            Image(systemName: "text.quote")
                                .font(.title3)
                            Text("Transcript")
                                .font(.caption2)
                        }
                        .foregroundStyle(.white.opacity(0.5))
                    }

                    Button {
                        handleMicTap()
                    } label: {
                        Circle()
                            .fill(speechService.isRecording ? Color.red : AppTheme.gold)
                            .frame(width: 72, height: 72)
                            .overlay {
                                Image(systemName: speechService.isRecording ? "stop.fill" : "mic.fill")
                                    .font(.title2.weight(.semibold))
                                    .foregroundStyle(speechService.isRecording ? .white : .black)
                            }
                            .shadow(color: (speechService.isRecording ? Color.red : AppTheme.gold).opacity(0.4), radius: 12)
                    }
                    .sensoryFeedback(.impact(weight: .medium), trigger: speechService.isRecording)
                    .disabled(viewModel.isProcessing)

                    Button {
                        if speechService.isSpeaking {
                            speechService.stopSpeaking()
                        }
                    } label: {
                        VStack(spacing: 4) {
                            Image(systemName: speechService.isSpeaking ? "speaker.slash" : "speaker.wave.2")
                                .font(.title3)
                            Text(speechService.isSpeaking ? "Stop" : "Audio")
                                .font(.caption2)
                        }
                        .foregroundStyle(.white.opacity(0.5))
                    }
                }
                .padding(.bottom, 48)
            }
        }
        .preferredColorScheme(.dark)
        .onChange(of: speechService.isRecording) { wasRecording, isNowRecording in
            if wasRecording && !isNowRecording && !speechService.transcribedText.isEmpty {
                Task {
                    try? await Task.sleep(for: .milliseconds(300))
                    let text = speechService.transcribedText
                    guard !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
                    viewModel.sendVoiceMessage(text: text, context: modelContext, speechService: speechService)
                    withAnimation { showTranscript = true }
                }
            }
        }
    }

    private var micIcon: String {
        if speechService.isRecording { return "waveform" }
        if viewModel.isProcessing { return "ellipsis" }
        if speechService.isSpeaking { return "speaker.wave.2.fill" }
        return "mic.fill"
    }

    private var micColor: Color {
        if speechService.isRecording { return .red }
        if viewModel.isProcessing { return .white.opacity(0.4) }
        if speechService.isSpeaking { return AppTheme.gold }
        return AppTheme.gold
    }

    private func handleMicTap() {
        if speechService.isRecording {
            speechService.stopRecording()
        } else {
            speechService.stopSpeaking()
            speechService.startRecording()
        }
    }
}
