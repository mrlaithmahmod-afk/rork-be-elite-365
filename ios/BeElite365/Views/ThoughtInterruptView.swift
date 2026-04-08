import SwiftUI
import SwiftData

struct ThoughtInterruptView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @State private var phase: ThoughtInterruptPhase = .select
    @State private var selectedThought: String = ""
    @State private var noticeConfirmed = false
    @State private var realityConfirmed = false
    @State private var selectedAction: String = ""
    @State private var effectiveness: Int = 3
    @State private var pulseScale: CGFloat = 1.0

    private let thoughts = [
        "I'm nervous",
        "I'll mess up",
        "Too much pressure",
        "I'm not ready",
        "They're better than me",
        "I can't handle this",
        "Everyone's watching",
        "I'll let the team down"
    ]

    private let actions = [
        "Positioning",
        "Scanning",
        "Next pass",
        "Communication",
        "First touch",
        "Movement"
    ]

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                switch phase {
                case .select: selectView
                case .notice: noticeView
                case .reality: realityView
                case .action: actionView
                case .complete: completionView
                }
            }
            .background(Color(.systemBackground))
            .navigationTitle("Thought Interrupt")
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
        VStack(spacing: 24) {
            Spacer()

            VStack(spacing: 16) {
                Image(systemName: "xmark.octagon")
                    .font(.system(size: 48))
                    .foregroundStyle(Color(red: 0.85, green: 0.35, blue: 0.30))

                Text("Stop the Thought")
                    .font(.title2.weight(.bold))

                Text("Select the thought that is running through your head right now.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                ForEach(thoughts, id: \.self) { thought in
                    Button {
                        selectedThought = thought
                        withAnimation(.easeInOut(duration: 0.3)) { phase = .notice }
                    } label: {
                        Text(thought)
                            .font(.subheadline.weight(.medium))
                            .foregroundStyle(.primary)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color(.secondarySystemGroupedBackground))
                            .clipShape(.rect(cornerRadius: 12))
                    }
                    .sensoryFeedback(.impact(weight: .light), trigger: selectedThought)
                }
            }
            .padding(.horizontal, 24)

            Spacer()
        }
    }

    private var noticeView: some View {
        VStack(spacing: 0) {
            Spacer()

            VStack(spacing: 24) {
                Text("STEP 1")
                    .font(.caption2.weight(.black))
                    .foregroundStyle(Color(red: 0.85, green: 0.35, blue: 0.30))
                    .tracking(2)

                Text("I notice this thought")
                    .font(.title2.weight(.bold))

                Text("\"\(selectedThought)\"")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .italic()

                Button {
                    noticeConfirmed = true
                    withAnimation(.easeInOut(duration: 0.3)) { phase = .reality }
                } label: {
                    Text("I notice it")
                        .font(.title3.weight(.bold))
                        .foregroundStyle(.black)
                        .frame(width: 160, height: 160)
                        .background(
                            Circle()
                                .fill(Color(red: 0.85, green: 0.35, blue: 0.30))
                                .scaleEffect(pulseScale)
                        )
                        .clipShape(Circle())
                }
                .sensoryFeedback(.impact(weight: .heavy), trigger: noticeConfirmed)
                .onAppear {
                    withAnimation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true)) {
                        pulseScale = 1.08
                    }
                }
            }

            Spacer()
        }
    }

    private var realityView: some View {
        VStack(spacing: 0) {
            Spacer()

            VStack(spacing: 24) {
                Text("STEP 2")
                    .font(.caption2.weight(.black))
                    .foregroundStyle(Color(red: 0.30, green: 0.55, blue: 0.85))
                    .tracking(2)

                Text("This is a thought,\nnot reality")
                    .font(.title2.weight(.bold))
                    .multilineTextAlignment(.center)

                Text("Thoughts are not facts. They are noise.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                Button {
                    realityConfirmed = true
                    withAnimation(.easeInOut(duration: 0.3)) { phase = .action }
                } label: {
                    Text("I accept this")
                        .font(.title3.weight(.bold))
                        .foregroundStyle(.black)
                        .frame(width: 160, height: 160)
                        .background(Color(red: 0.30, green: 0.55, blue: 0.85))
                        .clipShape(Circle())
                }
                .sensoryFeedback(.impact(weight: .heavy), trigger: realityConfirmed)
            }

            Spacer()
        }
    }

    private var actionView: some View {
        VStack(spacing: 24) {
            Spacer()

            VStack(spacing: 16) {
                Text("STEP 3")
                    .font(.caption2.weight(.black))
                    .foregroundStyle(Color(red: 0.25, green: 0.75, blue: 0.40))
                    .tracking(2)

                Text("What matters\nright now?")
                    .font(.title2.weight(.bold))
                    .multilineTextAlignment(.center)
            }

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                ForEach(actions, id: \.self) { action in
                    Button {
                        selectedAction = action
                        withAnimation(.easeInOut(duration: 0.3)) { phase = .complete }
                    } label: {
                        Text(action)
                            .font(.headline.weight(.semibold))
                            .foregroundStyle(.primary)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 20)
                            .background(Color(.secondarySystemGroupedBackground))
                            .clipShape(.rect(cornerRadius: 14))
                    }
                    .sensoryFeedback(.impact(weight: .medium), trigger: selectedAction)
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

                Text("Thought Interrupted")
                    .font(.title2.weight(.bold))

                Text("You chose: \(selectedAction)")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(AppTheme.gold)
            }

            VStack(alignment: .leading, spacing: 8) {
                resultLabel(stage: "NOTICED", text: selectedThought, color: Color(red: 0.85, green: 0.35, blue: 0.30))
                resultLabel(stage: "SEPARATED", text: "This is a thought, not reality", color: Color(red: 0.30, green: 0.55, blue: 0.85))
                resultLabel(stage: "REDIRECTED", text: selectedAction, color: Color(red: 0.25, green: 0.75, blue: 0.40))
            }
            .padding(.horizontal, 24)

            effectivenessRating

            Spacer()

            Button {
                let completion = DrillCompletion(drillID: "thought-interrupt", effectiveness: effectiveness)
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
            .sensoryFeedback(.success, trigger: phase)
        }
    }

    private func resultLabel(stage: String, text: String, color: Color) -> some View {
        HStack(spacing: 10) {
            Rectangle().fill(color).frame(width: 3, height: 28)
            VStack(alignment: .leading, spacing: 2) {
                Text(stage)
                    .font(.caption2.weight(.bold))
                    .foregroundStyle(color)
                Text(text)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .eliteCard(padding: 12)
    }

    private var effectivenessRating: some View {
        VStack(spacing: 10) {
            Text("How effective was this?")
                .font(.subheadline.weight(.medium))
                .foregroundStyle(.secondary)
            HStack(spacing: 8) {
                ForEach(1...5, id: \.self) { value in
                    Button { effectiveness = value } label: {
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
    }
}

nonisolated enum ThoughtInterruptPhase: Sendable {
    case select, notice, reality, action, complete
}
