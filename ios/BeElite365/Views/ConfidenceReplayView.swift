import SwiftUI
import SwiftData

struct ConfidenceReplayView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @State private var step: ReplayStep = .recall
    @State private var selectedMemory: String = ""
    @State private var customMemory: String = ""
    @State private var sensoryDetail: String = ""
    @State private var bodyFeeling: String = ""
    @State private var effectiveness: Int = 3

    private let memoryPrompts = [
        "A goal or assist I scored",
        "A crucial tackle or save",
        "A match where I was unstoppable",
        "A moment the crowd cheered for me",
        "A training session where everything clicked",
        "A time I recovered from a mistake brilliantly",
        "A time I led the team through pressure",
        "A personal best performance"
    ]

    private let sensoryOptions = [
        "I could hear the crowd",
        "I felt the ball perfectly on my foot",
        "My teammates celebrated with me",
        "The coach acknowledged my performance",
        "I felt completely in control",
        "Time seemed to slow down",
        "Every decision was automatic",
        "My body felt light and powerful"
    ]

    private let bodyFeelings = [
        "Powerful and explosive",
        "Calm and composed",
        "Sharp and focused",
        "Light and free",
        "Confident and decisive",
        "Resilient and unbreakable"
    ]

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                switch step {
                case .recall: recallView
                case .sensory: sensoryView
                case .body: bodyView
                case .anchor: anchorView
                case .complete: completionView
                }
            }
            .background(Color(.systemBackground))
            .navigationTitle("Confidence Replay")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                        .foregroundStyle(.secondary)
                }
            }
        }
        .presentationDetents([.large])
    }

    private var recallView: some View {
        ScrollView {
            VStack(spacing: 24) {
                VStack(spacing: 12) {
                    Image(systemName: "play.circle")
                        .font(.system(size: 40))
                        .foregroundStyle(AppTheme.gold)

                    Text("Replay Your Best")
                        .font(.title2.weight(.bold))

                    Text("Relive a moment when you performed at your best. Mentally replay it to rebuild confidence from real evidence.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 16)
                }
                .padding(.top, 8)

                VStack(alignment: .leading, spacing: 8) {
                    Text("CHOOSE A MEMORY")
                        .font(.caption2.weight(.bold))
                        .foregroundStyle(.secondary)

                    ForEach(memoryPrompts, id: \.self) { prompt in
                        Button {
                            selectedMemory = prompt
                            withAnimation { step = .sensory }
                        } label: {
                            HStack {
                                Text(prompt)
                                    .font(.subheadline)
                                    .foregroundStyle(.primary)
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .font(.caption2)
                                    .foregroundStyle(.tertiary)
                            }
                            .padding(14)
                            .background(Color(.secondarySystemGroupedBackground))
                            .clipShape(.rect(cornerRadius: 12))
                        }
                        .buttonStyle(.plain)
                    }
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text("OR DESCRIBE YOUR OWN")
                        .font(.caption2.weight(.bold))
                        .foregroundStyle(.secondary)

                    HStack(spacing: 10) {
                        TextField("", text: $customMemory, prompt: Text("My best moment was...").foregroundStyle(.white.opacity(0.3)))
                            .font(.subheadline)
                            .padding(12)
                            .background(Color(.secondarySystemGroupedBackground))
                            .clipShape(.rect(cornerRadius: 10))

                        Button {
                            selectedMemory = customMemory
                            withAnimation { step = .sensory }
                        } label: {
                            Image(systemName: "arrow.right.circle.fill")
                                .font(.title2)
                                .foregroundStyle(customMemory.isEmpty ? .secondary : AppTheme.gold)
                        }
                        .disabled(customMemory.trimmingCharacters(in: .whitespaces).isEmpty)
                    }
                }
            }
            .padding(.horizontal)
            .padding(.bottom, 24)
        }
    }

    private var sensoryView: some View {
        ScrollView {
            VStack(spacing: 24) {
                VStack(spacing: 12) {
                    Image(systemName: "waveform")
                        .font(.system(size: 40))
                        .foregroundStyle(Color(red: 0.30, green: 0.55, blue: 0.85))

                    Text("Add Sensory Detail")
                        .font(.title2.weight(.bold))

                    Text("Close your eyes. Replay the moment. What did you see, hear, and feel?")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 8)

                VStack(alignment: .leading, spacing: 4) {
                    Text("YOUR MEMORY")
                        .font(.caption2.weight(.bold))
                        .foregroundStyle(.secondary)
                    Text(selectedMemory)
                        .font(.caption)
                        .foregroundStyle(AppTheme.gold)
                        .padding(10)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(AppTheme.gold.opacity(0.06))
                        .clipShape(.rect(cornerRadius: 8))
                }

                VStack(spacing: 8) {
                    ForEach(sensoryOptions, id: \.self) { option in
                        Button {
                            sensoryDetail = option
                            withAnimation { step = .body }
                        } label: {
                            HStack {
                                Text(option)
                                    .font(.subheadline)
                                    .foregroundStyle(.primary)
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .font(.caption2)
                                    .foregroundStyle(.tertiary)
                            }
                            .padding(14)
                            .background(Color(.secondarySystemGroupedBackground))
                            .clipShape(.rect(cornerRadius: 12))
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .padding(.horizontal)
            .padding(.bottom, 24)
        }
    }

    private var bodyView: some View {
        VStack(spacing: 32) {
            Spacer()

            VStack(spacing: 16) {
                Image(systemName: "figure.stand")
                    .font(.system(size: 40))
                    .foregroundStyle(Color(red: 0.25, green: 0.75, blue: 0.40))

                Text("How Did Your Body Feel?")
                    .font(.title2.weight(.bold))

                Text("Remember the physical sensation of confidence in that moment.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)
            }

            VStack(spacing: 10) {
                ForEach(bodyFeelings, id: \.self) { feeling in
                    Button {
                        bodyFeeling = feeling
                        withAnimation { step = .anchor }
                    } label: {
                        Text(feeling)
                            .font(.subheadline.weight(.medium))
                            .foregroundStyle(.primary)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(Color(.secondarySystemGroupedBackground))
                            .clipShape(.rect(cornerRadius: 12))
                    }
                    .sensoryFeedback(.selection, trigger: bodyFeeling)
                }
            }
            .padding(.horizontal, 24)

            Spacer()
        }
    }

    private var anchorView: some View {
        VStack(spacing: 32) {
            Spacer()

            VStack(spacing: 20) {
                Image(systemName: "bolt.heart.fill")
                    .font(.system(size: 56))
                    .foregroundStyle(AppTheme.gold)

                Text("Anchor This Feeling")
                    .font(.title2.weight(.bold))

                Text("Hold this feeling for 10 seconds. Let it fill your body. This is real confidence built from real evidence.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)

                VStack(alignment: .leading, spacing: 10) {
                    replayCard(label: "MEMORY", text: selectedMemory, color: AppTheme.gold)
                    replayCard(label: "SENSORY", text: sensoryDetail, color: Color(red: 0.30, green: 0.55, blue: 0.85))
                    replayCard(label: "BODY", text: bodyFeeling, color: Color(red: 0.25, green: 0.75, blue: 0.40))
                }
                .padding(.horizontal, 24)
            }

            Spacer()

            Button {
                withAnimation { step = .complete }
            } label: {
                Text("I Feel It")
                    .font(.body.weight(.semibold))
                    .foregroundStyle(.black)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(AppTheme.gold)
                    .clipShape(.rect(cornerRadius: 12))
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 16)
            .sensoryFeedback(.impact(weight: .heavy), trigger: step)
        }
    }

    private var completionView: some View {
        VStack(spacing: 32) {
            Spacer()

            VStack(spacing: 12) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 56))
                    .foregroundStyle(AppTheme.stable)

                Text("Confidence Restored")
                    .font(.title2.weight(.bold))

                Text("Carry this feeling into your next performance. Your best moments are proof of what you are capable of.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)
            }

            VStack(spacing: 12) {
                Text("How confident do you feel now?")
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(.secondary)

                HStack(spacing: 8) {
                    ForEach(1...5, id: \.self) { value in
                        Button {
                            effectiveness = value
                        } label: {
                            Text("\(value)")
                                .font(.subheadline.weight(.bold))
                                .foregroundStyle(value <= effectiveness ? .black : .white)
                                .frame(width: 44, height: 44)
                                .background(value <= effectiveness ? AppTheme.gold : Color(.secondarySystemGroupedBackground))
                                .clipShape(Circle())
                        }
                    }
                }
            }

            Spacer()

            Button {
                let completion = DrillCompletion(
                    drillID: "confidence-replay",
                    effectiveness: effectiveness
                )
                modelContext.insert(completion)
                dismiss()
            } label: {
                Text("Done")
                    .font(.body.weight(.semibold))
                    .foregroundStyle(.black)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(AppTheme.gold)
                    .clipShape(.rect(cornerRadius: 12))
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 16)
            .sensoryFeedback(.success, trigger: effectiveness)
        }
    }

    private func replayCard(label: String, text: String, color: Color) -> some View {
        HStack(spacing: 10) {
            Rectangle()
                .fill(color)
                .frame(width: 3)
            VStack(alignment: .leading, spacing: 2) {
                Text(label)
                    .font(.caption2.weight(.bold))
                    .foregroundStyle(color)
                Text(text)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(.rect(cornerRadius: 10))
    }
}

nonisolated enum ReplayStep: Sendable {
    case recall, sensory, body, anchor, complete
}
