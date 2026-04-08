import SwiftUI
import SwiftData

struct MentalClarityStackView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @State private var phase: ClarityPhase = .ready
    @State private var currentPromptIndex: Int = 0
    @State private var timeRemaining: Double = 5.0
    @State private var timer: Timer?
    @State private var answers: [String] = ["", "", ""]
    @State private var effectiveness: Int = 3

    private let prompts = [
        "What matters today?",
        "What is your role?",
        "What is your first action?"
    ]

    private let optionSets: [[String]] = [
        ["Composure", "Effort", "Discipline", "Communication", "Winning duels", "Staying sharp"],
        ["Defend the space", "Create chances", "Control the tempo", "Win the ball", "Lead the line", "Organise"],
        ["Strong first touch", "Win the first header", "Positive pass", "Sprint to position", "Communicate early", "Stay compact"]
    ]

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                switch phase {
                case .ready: readyView
                case .answering: answeringView
                case .complete: completionView
                }
            }
            .background(Color(.systemBackground))
            .navigationTitle("Clarity Stack")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { stopTimer(); dismiss() }
                        .foregroundStyle(.secondary)
                }
            }
        }
        .presentationDetents([.large])
        .onDisappear { stopTimer() }
    }

    private var readyView: some View {
        VStack(spacing: 32) {
            Spacer()

            VStack(spacing: 16) {
                Image(systemName: "list.bullet.clipboard")
                    .font(.system(size: 48))
                    .foregroundStyle(AppTheme.gold)

                Text("Mental Clarity Stack")
                    .font(.title2.weight(.bold))

                Text("Three rapid prompts. Five seconds each. Lock in your focus before you step on the pitch.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }

            VStack(alignment: .leading, spacing: 10) {
                ForEach(Array(prompts.enumerated()), id: \.offset) { index, prompt in
                    HStack(spacing: 12) {
                        Text("\(index + 1)")
                            .font(.caption.weight(.black).monospacedDigit())
                            .foregroundStyle(AppTheme.gold)
                            .frame(width: 24)
                        Text(prompt)
                            .font(.subheadline.weight(.medium))
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .padding(.horizontal, 40)

            Spacer()

            Button {
                currentPromptIndex = 0
                answers = ["", "", ""]
                startPrompt()
            } label: {
                Text("Begin")
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

    private var answeringView: some View {
        let options = optionSets[currentPromptIndex]

        return VStack(spacing: 20) {
            VStack(spacing: 8) {
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule().fill(Color.white.opacity(0.08)).frame(height: 8)
                        Capsule().fill(timerColor)
                            .frame(width: max(0, geo.size.width * (timeRemaining / 5.0)), height: 8)
                            .animation(.linear(duration: 0.05), value: timeRemaining)
                    }
                }
                .frame(height: 8)
                .padding(.horizontal, 24)
                .padding(.top, 16)

                HStack {
                    Text("\(currentPromptIndex + 1)/3")
                        .font(.caption.weight(.bold).monospacedDigit())
                        .foregroundStyle(.secondary)
                    Spacer()
                    Text(String(format: "%.1fs", timeRemaining))
                        .font(.system(size: 18, weight: .bold, design: .monospaced))
                        .foregroundStyle(timerColor)
                        .contentTransition(.numericText())
                }
                .padding(.horizontal, 24)
            }

            Spacer()

            Text(prompts[currentPromptIndex])
                .font(.title2.weight(.bold))
                .multilineTextAlignment(.center)

            Spacer()

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                ForEach(options, id: \.self) { option in
                    Button {
                        selectAnswer(option)
                    } label: {
                        Text(option)
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(.primary)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 18)
                            .background(Color(.secondarySystemGroupedBackground))
                            .clipShape(.rect(cornerRadius: 14))
                    }
                    .sensoryFeedback(.impact(weight: .medium), trigger: answers[currentPromptIndex])
                }
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 24)
        }
    }

    private var completionView: some View {
        VStack(spacing: 32) {
            Spacer()

            VStack(spacing: 16) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 56))
                    .foregroundStyle(AppTheme.stable)

                Text("Locked In")
                    .font(.title2.weight(.bold))
            }

            VStack(alignment: .leading, spacing: 10) {
                ForEach(Array(prompts.enumerated()), id: \.offset) { index, prompt in
                    HStack(spacing: 10) {
                        Rectangle()
                            .fill(colorForIndex(index))
                            .frame(width: 3, height: 28)
                        VStack(alignment: .leading, spacing: 2) {
                            Text(prompt.uppercased())
                                .font(.caption2.weight(.bold))
                                .foregroundStyle(colorForIndex(index))
                            Text(answers[index].isEmpty ? "Timed out" : answers[index])
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(answers[index].isEmpty ? .secondary : .primary)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .eliteCard(padding: 12)
                }
            }
            .padding(.horizontal, 24)

            VStack(spacing: 10) {
                Text("How clear do you feel?")
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

            Spacer()

            Button {
                let completion = DrillCompletion(drillID: "clarity-stack", effectiveness: effectiveness)
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

    private func colorForIndex(_ index: Int) -> Color {
        switch index {
        case 0: Color(red: 0.85, green: 0.35, blue: 0.30)
        case 1: Color(red: 0.30, green: 0.55, blue: 0.85)
        default: Color(red: 0.25, green: 0.75, blue: 0.40)
        }
    }

    private var timerColor: Color {
        if timeRemaining > 3 { return AppTheme.stable }
        if timeRemaining > 1.5 { return AppTheme.weakening }
        return AppTheme.breakdown
    }

    private func startPrompt() {
        timeRemaining = 5.0
        phase = .answering
        stopTimer()
        timer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { t in
            timeRemaining -= 0.05
            if timeRemaining <= 0 {
                timeRemaining = 0
                t.invalidate()
                advancePrompt()
            }
        }
    }

    private func selectAnswer(_ answer: String) {
        stopTimer()
        answers[currentPromptIndex] = answer
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
        advancePrompt()
    }

    private func advancePrompt() {
        if currentPromptIndex < prompts.count - 1 {
            currentPromptIndex += 1
            startPrompt()
        } else {
            phase = .complete
        }
    }

    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
}

nonisolated enum ClarityPhase: Sendable {
    case ready, answering, complete
}
