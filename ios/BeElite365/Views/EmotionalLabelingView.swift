import SwiftUI
import SwiftData

struct EmotionalLabelingView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @State private var step: LabelingStep = .select
    @State private var selectedEmotion: EmotionLabel?
    @State private var intensity: Double = 5
    @State private var effectiveness: Int = 3

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                switch step {
                case .select: selectView
                case .label: labelView
                case .reframe: reframeStepView
                case .complete: completionView
                }
            }
            .background(Color(.systemBackground))
            .navigationTitle("Emotional Labeling")
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
                    Image(systemName: "heart.text.square")
                        .font(.system(size: 40))
                        .foregroundStyle(AppTheme.gold)

                    Text("Name the Feeling")
                        .font(.title2.weight(.bold))

                    Text("Research shows that naming an emotion reduces its intensity by up to 50%. Select what you are feeling right now.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 16)
                }
                .padding(.top, 8)

                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                    ForEach(EmotionLabel.allCases) { emotion in
                        Button {
                            selectedEmotion = emotion
                            withAnimation { step = .label }
                        } label: {
                            VStack(spacing: 8) {
                                Image(systemName: emotion.icon)
                                    .font(.title2)
                                    .foregroundStyle(emotion.color)
                                Text(emotion.rawValue)
                                    .font(.subheadline.weight(.semibold))
                                    .foregroundStyle(.primary)
                                Text(emotion.description)
                                    .font(.caption2)
                                    .foregroundStyle(.secondary)
                                    .lineLimit(2)
                                    .multilineTextAlignment(.center)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .padding(.horizontal, 8)
                            .background(Color(.secondarySystemGroupedBackground))
                            .clipShape(.rect(cornerRadius: 12))
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal)
            }
            .padding(.bottom, 24)
        }
    }

    private var labelView: some View {
        VStack(spacing: 32) {
            Spacer()

            if let emotion = selectedEmotion {
                VStack(spacing: 16) {
                    Image(systemName: emotion.icon)
                        .font(.system(size: 56))
                        .foregroundStyle(emotion.color)

                    Text("You are feeling \(emotion.rawValue.lowercased())")
                        .font(.title3.weight(.bold))

                    Text(emotion.explanation)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                }

                VStack(spacing: 8) {
                    Text("How intense is it? (\(Int(intensity))/10)")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)

                    Slider(value: $intensity, in: 1...10, step: 1)
                        .tint(emotion.color)
                        .padding(.horizontal, 32)
                }
            }

            Spacer()

            Button {
                withAnimation { step = .reframe }
            } label: {
                Text("Understand It")
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

    private var reframeStepView: some View {
        VStack(spacing: 32) {
            Spacer()

            if let emotion = selectedEmotion {
                VStack(spacing: 20) {
                    Text("REFRAME")
                        .font(.caption.weight(.black))
                        .foregroundStyle(AppTheme.gold)
                        .tracking(2)

                    Text(emotion.reframe)
                        .font(.title3.weight(.medium))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 24)

                    Divider()
                        .padding(.horizontal, 40)

                    VStack(spacing: 8) {
                        Text("YOUR NEXT MOVE")
                            .font(.caption2.weight(.bold))
                            .foregroundStyle(.secondary)
                        Text(emotion.nextMove)
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(Color(red: 0.25, green: 0.75, blue: 0.40))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 24)
                    }
                }
            }

            Spacer()

            Button {
                withAnimation { step = .complete }
            } label: {
                Text("Got It")
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

    private var completionView: some View {
        VStack(spacing: 32) {
            Spacer()

            VStack(spacing: 12) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 56))
                    .foregroundStyle(AppTheme.stable)

                Text("Emotion Processed")
                    .font(.title2.weight(.bold))

                if let emotion = selectedEmotion {
                    Text("You named \(emotion.rawValue.lowercased()) at intensity \(Int(intensity)). By labeling it, you reduced its control over your performance.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 24)
                }
            }

            VStack(spacing: 12) {
                Text("How helpful was this?")
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
                    drillID: "emotional-labeling",
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
}

nonisolated enum LabelingStep: Sendable {
    case select, label, reframe, complete
}

nonisolated enum EmotionLabel: String, CaseIterable, Sendable, Identifiable {
    case anxious = "Anxious"
    case frustrated = "Frustrated"
    case angry = "Angry"
    case pressured = "Pressured"
    case defeated = "Defeated"
    case embarrassed = "Embarrassed"
    case doubtful = "Doubtful"
    case overwhelmed = "Overwhelmed"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .anxious: "waveform.path"
        case .frustrated: "bolt.slash"
        case .angry: "flame"
        case .pressured: "arrow.down.to.line"
        case .defeated: "arrow.down"
        case .embarrassed: "eye.slash"
        case .doubtful: "questionmark.circle"
        case .overwhelmed: "tornado"
        }
    }

    var color: Color {
        switch self {
        case .anxious: Color(red: 0.30, green: 0.55, blue: 0.85)
        case .frustrated: Color(red: 0.85, green: 0.55, blue: 0.20)
        case .angry: Color(red: 0.90, green: 0.22, blue: 0.21)
        case .pressured: Color(red: 0.65, green: 0.30, blue: 0.75)
        case .defeated: Color(red: 0.45, green: 0.45, blue: 0.50)
        case .embarrassed: Color(red: 0.85, green: 0.35, blue: 0.55)
        case .doubtful: Color(red: 0.50, green: 0.50, blue: 0.60)
        case .overwhelmed: Color(red: 0.75, green: 0.35, blue: 0.30)
        }
    }

    var description: String {
        switch self {
        case .anxious: "Nerves or worry"
        case .frustrated: "Things not going to plan"
        case .angry: "Intense reaction"
        case .pressured: "Weight of expectation"
        case .defeated: "Feeling beaten"
        case .embarrassed: "Self-conscious"
        case .doubtful: "Questioning ability"
        case .overwhelmed: "Too much at once"
        }
    }

    var explanation: String {
        switch self {
        case .anxious: "Anxiety is your body preparing to perform. It is not weakness. It is readiness misinterpreted. The same chemicals that create anxiety also create excitement."
        case .frustrated: "Frustration means you care about the outcome. That is a strength. The key is directing that energy into controllable actions rather than letting it consume focus."
        case .angry: "Anger is energy. It is not inherently bad. The question is: do you control it, or does it control you? Channeled correctly, it fuels effort."
        case .pressured: "Pressure is a privilege. It means you are in a position that matters. The goal is not to remove pressure but to perform within it."
        case .defeated: "Feeling defeated is temporary. It is a response to a moment, not a reflection of your ability. One action can shift the momentum."
        case .embarrassed: "Embarrassment is rooted in what others think. On the pitch, only your next action matters. Nobody remembers the mistake. They remember the response."
        case .doubtful: "Doubt is a thought, not a fact. Your preparation is real. Your ability is evidence-based. Doubt shrinks when you commit to one action."
        case .overwhelmed: "Overwhelm comes from trying to process everything at once. Narrow your focus to one thing. One action. One moment. That is all that exists."
        }
    }

    var reframe: String {
        switch self {
        case .anxious: "My body is ready. I am prepared. I channel this energy into sharp, decisive actions."
        case .frustrated: "I care about this. That is my fuel. I direct it into effort and composure."
        case .angry: "I notice the anger. I own it. I use it to sprint harder, compete fiercer, within control."
        case .pressured: "Pressure is where I grow. I simplify. One task. Full commitment."
        case .defeated: "This moment does not define me. My response does. One action to shift the tide."
        case .embarrassed: "Nobody cares about the last play. They care about the next one. I move forward."
        case .doubtful: "Doubt is a visitor. My preparation is the landlord. I trust the work I have done."
        case .overwhelmed: "I narrow my world to one action. Everything else can wait. One thing, done well."
        }
    }

    var nextMove: String {
        switch self {
        case .anxious: "Take one controlled breath. Then commit to your first touch."
        case .frustrated: "Choose the simplest next action. Execute it with full intent."
        case .angry: "Channel it. Sprint to recover. Win the next ball. Controlled aggression."
        case .pressured: "Simplify. What is the one thing you need to do right now?"
        case .defeated: "Small win. A five-yard pass. A recovery run. Stack from there."
        case .embarrassed: "Look up. Find a teammate. Communicate. Action dissolves embarrassment."
        case .doubtful: "Commit to the next action with zero hesitation. Confidence follows action."
        case .overwhelmed: "Pick one thing. Ignore everything else for 30 seconds. Execute."
        }
    }
}
