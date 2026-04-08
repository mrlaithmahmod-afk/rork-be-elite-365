import SwiftUI
import SwiftData

struct CognitiveDefusionView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @State private var step: DefusionStep = .select
    @State private var customThought: String = ""
    @State private var selectedThought: String = ""
    @State private var defusedThought: String = ""
    @State private var reframe: String = ""
    @State private var nextAction: String = ""
    @State private var effectiveness: Int = 3

    private let commonThoughts = [
        "I'm going to mess up",
        "I'm not good enough",
        "Everyone is watching me fail",
        "I can't handle this pressure",
        "I always choke in big moments",
        "The coach doesn't rate me",
        "I'm going to lose my place",
        "I can't recover from that mistake"
    ]

    private let nextActions = [
        "Win the next duel",
        "Play a simple five-yard pass",
        "Hold my position",
        "Communicate with a teammate",
        "Sprint to recover",
        "Take a controlled first touch"
    ]

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                switch step {
                case .select: selectView
                case .defuse: defuseView
                case .reframe: reframeView
                case .action: actionView
                case .complete: completionView
                }
            }
            .background(Color(.systemBackground))
            .navigationTitle("Cognitive Defusion")
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

    private var selectView: some View {
        ScrollView {
            VStack(spacing: 24) {
                VStack(spacing: 12) {
                    Image(systemName: "thought.bubble")
                        .font(.system(size: 40))
                        .foregroundStyle(AppTheme.gold)

                    Text("Detach From the Thought")
                        .font(.title3.weight(.bold))

                    Text("Select a negative thought you are experiencing, or type your own. We will defuse its power over you.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 16)
                }
                .padding(.top, 8)

                VStack(alignment: .leading, spacing: 8) {
                    Text("COMMON THOUGHTS")
                        .font(.caption2.weight(.bold))
                        .foregroundStyle(.secondary)

                    ForEach(commonThoughts, id: \.self) { thought in
                        Button {
                            selectedThought = thought
                            generateDefusion()
                            withAnimation { step = .defuse }
                        } label: {
                            HStack(spacing: 10) {
                                Text(thought)
                                    .font(.subheadline)
                                    .foregroundStyle(.primary)
                                    .multilineTextAlignment(.leading)
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
                    Text("OR TYPE YOUR OWN")
                        .font(.caption2.weight(.bold))
                        .foregroundStyle(.secondary)

                    HStack(spacing: 10) {
                        TextField("", text: $customThought, prompt: Text("What thought is bothering you?").foregroundStyle(.white.opacity(0.3)))
                            .font(.subheadline)
                            .padding(12)
                            .background(Color(.secondarySystemGroupedBackground))
                            .clipShape(.rect(cornerRadius: 10))

                        Button {
                            selectedThought = customThought
                            generateDefusion()
                            withAnimation { step = .defuse }
                        } label: {
                            Image(systemName: "arrow.right.circle.fill")
                                .font(.title2)
                                .foregroundStyle(customThought.isEmpty ? .secondary : AppTheme.gold)
                        }
                        .disabled(customThought.trimmingCharacters(in: .whitespaces).isEmpty)
                    }
                }
            }
            .padding(.horizontal)
            .padding(.bottom, 24)
        }
    }

    private var defuseView: some View {
        VStack(spacing: 32) {
            Spacer()

            VStack(spacing: 20) {
                Text("YOUR THOUGHT")
                    .font(.caption.weight(.black))
                    .foregroundStyle(AppTheme.breakdown)
                    .tracking(2)

                Text("\"\(selectedThought)\"")
                    .font(.title3.weight(.semibold))
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.primary.opacity(0.6))
                    .padding(.horizontal, 24)

                Image(systemName: "arrow.down")
                    .font(.title3)
                    .foregroundStyle(.tertiary)

                Text("DEFUSED")
                    .font(.caption.weight(.black))
                    .foregroundStyle(AppTheme.gold)
                    .tracking(2)

                Text(defusedThought)
                    .font(.title3.weight(.semibold))
                    .multilineTextAlignment(.center)
                    .foregroundStyle(AppTheme.gold)
                    .padding(.horizontal, 24)
            }

            Text("By adding \"I notice I am having the thought that...\" you create distance between you and the thought. It loses its power.")
                .font(.caption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)

            Spacer()

            Button {
                withAnimation { step = .reframe }
            } label: {
                Text("Next: Reframe")
                    .font(.body.weight(.semibold))
                    .foregroundStyle(.black)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(AppTheme.gold)
                    .clipShape(.rect(cornerRadius: 12))
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 16)
            .sensoryFeedback(.impact(weight: .medium), trigger: step)
        }
    }

    private var reframeView: some View {
        VStack(spacing: 32) {
            Spacer()

            VStack(spacing: 20) {
                Text("REFRAME")
                    .font(.caption.weight(.black))
                    .foregroundStyle(Color(red: 0.30, green: 0.55, blue: 0.85))
                    .tracking(2)

                Text(reframe)
                    .font(.title3.weight(.semibold))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)

                Text("This is the truth-based alternative. Not positive thinking. Factual, controllable, actionable.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }

            Spacer()

            Button {
                withAnimation { step = .action }
            } label: {
                Text("Next: Choose Action")
                    .font(.body.weight(.semibold))
                    .foregroundStyle(.black)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(AppTheme.gold)
                    .clipShape(.rect(cornerRadius: 12))
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 16)
        }
    }

    private var actionView: some View {
        VStack(spacing: 24) {
            Spacer()

            VStack(spacing: 12) {
                Text("NEXT ACTION")
                    .font(.caption.weight(.black))
                    .foregroundStyle(Color(red: 0.25, green: 0.75, blue: 0.40))
                    .tracking(2)

                Text("What is the one thing you will do next?")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            VStack(spacing: 10) {
                ForEach(nextActions, id: \.self) { action in
                    Button {
                        nextAction = action
                        withAnimation { step = .complete }
                    } label: {
                        Text(action)
                            .font(.subheadline.weight(.medium))
                            .foregroundStyle(.primary)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(Color(.secondarySystemGroupedBackground))
                            .clipShape(.rect(cornerRadius: 12))
                    }
                    .sensoryFeedback(.selection, trigger: nextAction)
                }
            }
            .padding(.horizontal, 24)

            Spacer()
        }
    }

    private var completionView: some View {
        VStack(spacing: 32) {
            Spacer()

            VStack(spacing: 16) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 56))
                    .foregroundStyle(AppTheme.stable)

                Text("Thought Defused")
                    .font(.title2.weight(.bold))
            }

            VStack(alignment: .leading, spacing: 12) {
                summaryRow(label: "THOUGHT", value: selectedThought, color: .secondary)
                summaryRow(label: "DEFUSED", value: defusedThought, color: AppTheme.gold)
                summaryRow(label: "REFRAME", value: reframe, color: Color(red: 0.30, green: 0.55, blue: 0.85))
                summaryRow(label: "ACTION", value: nextAction, color: Color(red: 0.25, green: 0.75, blue: 0.40))
            }
            .padding(.horizontal, 24)

            VStack(spacing: 12) {
                Text("How effective was this?")
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
                    drillID: "cognitive-defusion",
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

    private func summaryRow(label: String, value: String, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(.caption2.weight(.bold))
                .foregroundStyle(color)
            Text(value)
                .font(.caption)
                .foregroundStyle(.secondary)
                .lineLimit(2)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .eliteCard(padding: 12)
    }

    private func generateDefusion() {
        let lower = selectedThought.lowercased()
        defusedThought = "I notice I am having the thought that \(lower.hasPrefix("i") ? lower : "I might \(lower)")"

        if lower.contains("mess up") || lower.contains("mistake") {
            reframe = "Mistakes are part of the game. My next action is what matters. I execute one thing at a time."
        } else if lower.contains("not good enough") || lower.contains("can't") {
            reframe = "My preparation is real. I have earned my place through work. I trust the process."
        } else if lower.contains("watching") || lower.contains("everyone") {
            reframe = "Nobody remembers the mistake. They remember the response. My response starts now."
        } else if lower.contains("pressure") || lower.contains("choke") {
            reframe = "Pressure is a privilege. My body is preparing to perform. I channel this energy into my next action."
        } else if lower.contains("coach") || lower.contains("place") {
            reframe = "I control my effort and preparation. Everything else is noise. Next session, full commitment."
        } else if lower.contains("recover") || lower.contains("injury") {
            reframe = "Recovery is part of the process. Each day of rehab is an investment in my return."
        } else {
            reframe = "This thought is not a fact. It is a feeling. I redirect my attention to what I can control right now."
        }
    }
}

nonisolated enum DefusionStep: Sendable {
    case select, defuse, reframe, action, complete
}
