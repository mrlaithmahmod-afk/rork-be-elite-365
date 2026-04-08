import SwiftUI
import SwiftData

struct NextActionLockInView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @State private var phase: LockInPhase = .ready
    @State private var scenarioIndex: Int = 0
    @State private var timeRemaining: Double = 2.0
    @State private var timer: Timer?
    @State private var selectedAction: String = ""
    @State private var decisionTimes: [Double] = []
    @State private var lastScenarioTime: Date = .now
    @State private var timedOut = false
    @State private var effectiveness: Int = 3

    private let scenarios: [(situation: String, options: [String])] = [
        ("You lost possession", ["Press", "Recover", "Communicate"]),
        ("Teammate misplaced a pass", ["Cover space", "Shout instruction", "Hold position"]),
        ("You missed a chance", ["Reset position", "Stay composed", "Demand the ball"]),
        ("Opponent is running at you", ["Stay on feet", "Show inside", "Press hard"]),
        ("Free kick against you", ["Organise wall", "Mark runner", "Hold the line"]),
        ("Half-time, losing 1-0", ["Stay focused", "Increase tempo", "Stick to the plan"]),
        ("Coach shouts at you", ["Acknowledge", "Refocus on task", "Breathe and reset"]),
        ("Yellow card risk", ["Stay disciplined", "Reduce intensity", "Channel aggression"]),
        ("Injury scare, you feel a twinge", ["Stretch it out", "Signal to bench", "Play through smart"]),
        ("Last 5 minutes, winning by 1", ["Keep possession", "Stay compact", "Manage the clock"]),
    ]

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                switch phase {
                case .ready: readyView
                case .scenario: scenarioView
                case .committed: committedView
                case .complete: completionView
                }
            }
            .background(Color(.systemBackground))
            .navigationTitle("Next Action")
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
                Image(systemName: "bolt.circle.fill")
                    .font(.system(size: 48))
                    .foregroundStyle(AppTheme.gold)

                Text("Next Action Lock-In")
                    .font(.title2.weight(.bold))

                Text("A match situation appears. You have 2 seconds to decide your next action. No hesitation. Commit instantly.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }

            HStack(spacing: 24) {
                VStack(spacing: 4) {
                    Text("2s")
                        .font(.title3.weight(.bold))
                        .foregroundStyle(AppTheme.breakdown)
                    Text("Per Decision")
                        .font(.caption2.weight(.semibold))
                        .foregroundStyle(.secondary)
                }
                VStack(spacing: 4) {
                    Text("10")
                        .font(.title3.weight(.bold))
                        .foregroundStyle(AppTheme.gold)
                    Text("Scenarios")
                        .font(.caption2.weight(.semibold))
                        .foregroundStyle(.secondary)
                }
            }

            Spacer()

            Button {
                scenarioIndex = 0
                decisionTimes = []
                startScenario()
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

    private var scenarioView: some View {
        let scenario = scenarios[scenarioIndex]

        return VStack(spacing: 20) {
            VStack(spacing: 8) {
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule().fill(Color.white.opacity(0.08)).frame(height: 8)
                        Capsule().fill(timerColor)
                            .frame(width: max(0, geo.size.width * (timeRemaining / 2.0)), height: 8)
                            .animation(.linear(duration: 0.05), value: timeRemaining)
                    }
                }
                .frame(height: 8)
                .padding(.horizontal, 24)
                .padding(.top, 16)

                HStack {
                    Text("\(scenarioIndex + 1)/\(scenarios.count)")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)
                    Spacer()
                    Text(String(format: "%.1fs", timeRemaining))
                        .font(.system(size: 20, weight: .bold, design: .monospaced))
                        .foregroundStyle(timerColor)
                        .contentTransition(.numericText())
                }
                .padding(.horizontal, 24)
            }

            Spacer()

            Text(scenario.situation)
                .font(.title3.weight(.bold))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 24)

            Spacer()

            VStack(spacing: 10) {
                ForEach(scenario.options, id: \.self) { option in
                    Button {
                        selectAction(option)
                    } label: {
                        Text(option)
                            .font(.headline.weight(.semibold))
                            .foregroundStyle(.primary)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 18)
                            .background(Color(.secondarySystemGroupedBackground))
                            .clipShape(.rect(cornerRadius: 14))
                    }
                }
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 24)
        }
    }

    private var committedView: some View {
        VStack(spacing: 0) {
            Spacer()

            VStack(spacing: 16) {
                Image(systemName: timedOut ? "exclamationmark.triangle.fill" : "checkmark.seal.fill")
                    .font(.system(size: 48))
                    .foregroundStyle(timedOut ? AppTheme.breakdown : AppTheme.stable)

                Text(timedOut ? "Too slow." : "Commit. No hesitation.")
                    .font(.title2.weight(.bold))

                if !timedOut {
                    Text(selectedAction)
                        .font(.title3.weight(.semibold))
                        .foregroundStyle(AppTheme.gold)
                }
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

                Text("Drill Complete")
                    .font(.title2.weight(.bold))
            }

            HStack(spacing: 16) {
                let decided = decisionTimes.filter { $0 < 2.0 }.count
                statBox(value: "\(decided)/\(scenarios.count)", label: "Decided")
                if !decisionTimes.isEmpty {
                    let validTimes = decisionTimes.filter { $0 < 2.0 }
                    if !validTimes.isEmpty {
                        let avg = validTimes.reduce(0, +) / Double(validTimes.count)
                        statBox(value: String(format: "%.2fs", avg), label: "Avg Speed")
                    }
                }
            }
            .padding(.horizontal, 24)

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

            Spacer()

            Button {
                let completion = DrillCompletion(drillID: "next-action-lockin", effectiveness: effectiveness)
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

    private func statBox(value: String, label: String) -> some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.title3.weight(.bold))
                .foregroundStyle(AppTheme.gold)
            Text(label)
                .font(.caption2.weight(.semibold))
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .eliteCard()
    }

    private var timerColor: Color {
        if timeRemaining > 1.2 { return AppTheme.stable }
        if timeRemaining > 0.5 { return AppTheme.weakening }
        return AppTheme.breakdown
    }

    private func startScenario() {
        timeRemaining = 2.0
        selectedAction = ""
        timedOut = false
        lastScenarioTime = Date()
        phase = .scenario

        stopTimer()
        timer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { t in
            timeRemaining -= 0.05
            if timeRemaining <= 0 {
                timeRemaining = 0
                t.invalidate()
                timedOut = true
                decisionTimes.append(2.0)
                phase = .committed
                let generator = UINotificationFeedbackGenerator()
                generator.notificationOccurred(.error)
                advanceAfterDelay()
            }
        }
    }

    private func selectAction(_ action: String) {
        stopTimer()
        selectedAction = action
        timedOut = false
        let decisionTime = Date().timeIntervalSince(lastScenarioTime)
        decisionTimes.append(decisionTime)
        phase = .committed

        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()

        advanceAfterDelay()
    }

    private func advanceAfterDelay() {
        Task {
            try? await Task.sleep(for: .seconds(1.2))
            if scenarioIndex < scenarios.count - 1 {
                scenarioIndex += 1
                startScenario()
            } else {
                phase = .complete
            }
        }
    }

    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
}

nonisolated enum LockInPhase: Sendable {
    case ready, scenario, committed, complete
}
