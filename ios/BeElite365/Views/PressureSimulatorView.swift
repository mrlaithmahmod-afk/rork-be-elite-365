import SwiftUI
import SwiftData

struct PressureSimulatorView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @State private var phase: PressureSimPhase = .ready
    @State private var scenarioIndex: Int = 0
    @State private var timer: Timer?
    @State private var timeRemaining: Double = 15
    @State private var selectedResponse: String?
    @State private var responseTimes: [Double] = []
    @State private var effectiveness: Int = 3

    private let scenarios: [(situation: String, options: [String], optimal: String)] = [
        (
            situation: "85th minute. You are 1-0 up. The ball comes to you in your own half under pressure.",
            options: ["Play it long and safe", "Find a short pass to feet", "Take a touch and drive forward", "Pass back to the keeper"],
            optimal: "Find a short pass to feet"
        ),
        (
            situation: "You just gave the ball away and the opposition nearly scored. The crowd groans.",
            options: ["Try a spectacular pass to make up for it", "Play simple for the next 5 minutes", "Shout at the teammate who did not cover", "Sprint to recover position"],
            optimal: "Play simple for the next 5 minutes"
        ),
        (
            situation: "Penalty. Cup final. Thousands watching. You step up to take it.",
            options: ["Change your mind at the last second", "Pick your spot and commit fully", "Blast it as hard as possible", "Wait for the keeper to move"],
            optimal: "Pick your spot and commit fully"
        ),
        (
            situation: "The coach screams at you from the touchline after a mistake. Your confidence drops.",
            options: ["Argue back with the coach", "Hide from the ball for 10 minutes", "Take a breath and focus on next action", "Try something risky to prove a point"],
            optimal: "Take a breath and focus on next action"
        ),
        (
            situation: "You come on as a sub with 20 minutes left. The team is losing 2-1.",
            options: ["Try to do everything yourself", "Stick to your role and do it well", "Play it safe and avoid mistakes", "Get frustrated if it does not go well immediately"],
            optimal: "Stick to your role and do it well"
        ),
    ]

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                switch phase {
                case .ready: readyView
                case .scenario: scenarioView
                case .complete: completionView
                }
            }
            .background(Color(.systemBackground))
            .navigationTitle("Pressure Simulator")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") {
                        stopTimer()
                        dismiss()
                    }
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
                Image(systemName: "bolt.shield")
                    .font(.system(size: 48))
                    .foregroundStyle(AppTheme.gold)

                Text("Pressure Simulator")
                    .font(.title2.weight(.bold))

                Text("High-pressure match scenarios will appear. You have 15 seconds to choose the best response. Train your decision-making under time pressure.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }

            VStack(spacing: 8) {
                HStack(spacing: 16) {
                    VStack(spacing: 4) {
                        Text("\(scenarios.count)")
                            .font(.title3.weight(.bold))
                            .foregroundStyle(AppTheme.gold)
                        Text("Scenarios")
                            .font(.caption2.weight(.semibold))
                            .foregroundStyle(.secondary)
                    }
                    VStack(spacing: 4) {
                        Text("15s")
                            .font(.title3.weight(.bold))
                            .foregroundStyle(AppTheme.gold)
                        Text("Per Decision")
                            .font(.caption2.weight(.semibold))
                            .foregroundStyle(.secondary)
                    }
                }
            }

            Spacer()

            Button {
                scenarioIndex = 0
                responseTimes = []
                phase = .scenario
                startScenarioTimer()
            } label: {
                Text("Begin Simulation")
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

    private var scenarioView: some View {
        let scenario = scenarios[scenarioIndex]

        return VStack(spacing: 20) {
            VStack(spacing: 8) {
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(Color.white.opacity(0.08))
                            .frame(height: 6)
                        Capsule()
                            .fill(timerColor)
                            .frame(width: max(0, geo.size.width * (timeRemaining / 15)), height: 6)
                            .animation(.linear(duration: 0.1), value: timeRemaining)
                    }
                }
                .frame(height: 6)
                .padding(.horizontal, 24)
                .padding(.top, 16)

                HStack {
                    Text("Scenario \(scenarioIndex + 1)/\(scenarios.count)")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)
                    Spacer()
                    Text(String(format: "%.0fs", timeRemaining))
                        .font(.system(size: 18, weight: .bold, design: .monospaced))
                        .foregroundStyle(timerColor)
                        .contentTransition(.numericText())
                }
                .padding(.horizontal, 24)
            }

            VStack(spacing: 12) {
                Text("SITUATION")
                    .font(.caption.weight(.black))
                    .foregroundStyle(AppTheme.gold)
                    .tracking(2)

                Text(scenario.situation)
                    .font(.subheadline.weight(.medium))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 16)
            }
            .padding(.top, 8)

            VStack(spacing: 10) {
                ForEach(scenario.options, id: \.self) { option in
                    Button {
                        selectResponse(option)
                    } label: {
                        HStack {
                            Text(option)
                                .font(.subheadline)
                                .foregroundStyle(.primary)
                                .multilineTextAlignment(.leading)
                            Spacer()
                            if selectedResponse == option {
                                Image(systemName: option == scenario.optimal ? "checkmark.circle.fill" : "xmark.circle.fill")
                                    .foregroundStyle(option == scenario.optimal ? AppTheme.stable : AppTheme.breakdown)
                            }
                        }
                        .padding(14)
                        .background(responseBackground(option, optimal: scenario.optimal))
                        .clipShape(.rect(cornerRadius: 12))
                    }
                    .buttonStyle(.plain)
                    .disabled(selectedResponse != nil)
                }
            }
            .padding(.horizontal, 24)

            if let selected = selectedResponse {
                VStack(spacing: 4) {
                    Text(selected == scenario.optimal ? "Correct decision." : "Better option: \(scenario.optimal)")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(selected == scenario.optimal ? AppTheme.stable : AppTheme.weakening)
                }
                .transition(.opacity)
            }

            Spacer()
        }
    }

    private var completionView: some View {
        VStack(spacing: 32) {
            Spacer()

            VStack(spacing: 12) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 56))
                    .foregroundStyle(AppTheme.stable)

                Text("Simulation Complete")
                    .font(.title2.weight(.bold))

                let correctCount = responseTimes.filter { $0 >= 0 }.count
                Text("\(correctCount)/\(scenarios.count) optimal decisions")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                if !responseTimes.isEmpty {
                    let avgTime = responseTimes.map { abs($0) }.reduce(0, +) / Double(responseTimes.count)
                    Text(String(format: "Average response: %.1fs", avgTime))
                        .font(.caption.weight(.bold).monospacedDigit())
                        .foregroundStyle(AppTheme.gold)
                }
            }

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
                    drillID: "pressure-simulator",
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

    private var timerColor: Color {
        if timeRemaining > 8 { return AppTheme.stable }
        if timeRemaining > 4 { return AppTheme.weakening }
        return AppTheme.breakdown
    }

    private func responseBackground(_ option: String, optimal: String) -> Color {
        guard let selected = selectedResponse else {
            return Color(.secondarySystemGroupedBackground)
        }
        if option == optimal { return AppTheme.stable.opacity(0.15) }
        if option == selected { return AppTheme.breakdown.opacity(0.15) }
        return Color(.secondarySystemGroupedBackground)
    }

    private func selectResponse(_ option: String) {
        stopTimer()
        selectedResponse = option
        let responseTime = 15 - timeRemaining
        let isCorrect = option == scenarios[scenarioIndex].optimal
        responseTimes.append(isCorrect ? responseTime : -responseTime)

        let generator = UIImpactFeedbackGenerator(style: isCorrect ? .light : .medium)
        generator.impactOccurred()

        Task {
            try? await Task.sleep(for: .seconds(2))
            advanceScenario()
        }
    }

    private func advanceScenario() {
        selectedResponse = nil
        if scenarioIndex < scenarios.count - 1 {
            scenarioIndex += 1
            timeRemaining = 15
            startScenarioTimer()
        } else {
            phase = .complete
        }
    }

    private func startScenarioTimer() {
        timeRemaining = 15
        stopTimer()
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { t in
            timeRemaining -= 0.1
            if timeRemaining <= 0 {
                timeRemaining = 0
                t.invalidate()
                responseTimes.append(-15)
                advanceScenario()
            }
        }
    }

    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
}

nonisolated enum PressureSimPhase: Sendable {
    case ready, scenario, complete
}
