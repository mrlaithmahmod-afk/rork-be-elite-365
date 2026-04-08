import SwiftUI
import SwiftData

struct FocusSwitchDrillView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @State private var drillState: FocusDrillState = .ready
    @State private var timeRemaining: Double = 30
    @State private var timer: Timer?
    @State private var currentPrompt: String = ""
    @State private var promptIndex: Int = 0
    @State private var tapsCompleted: Int = 0
    @State private var effectiveness: Int = 3

    private let prompts = [
        "Where is the ball?",
        "Where is your nearest teammate?",
        "Where is your marker?",
        "What space is available?",
        "Where should you be positioned?",
        "What is your next action?",
        "Scan left.",
        "Scan right.",
        "Check your shoulder.",
        "Where is the opposition pressing?",
        "What run can you make?",
        "Where is the goalkeeper?",
    ]

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                switch drillState {
                case .ready:
                    readyView
                case .active:
                    activeView
                case .complete:
                    completionView
                }
            }
            .background(Color(.systemBackground))
            .navigationTitle("Focus Switch")
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
                Image(systemName: "eye.trianglebadge.exclamationmark")
                    .font(.system(size: 48))
                    .foregroundStyle(AppTheme.gold)

                Text("Focus Switch Drill")
                    .font(.title2.weight(.bold))

                Text("Train your attention redirection. Prompts will appear rapidly. Tap each one to confirm you have processed it. The goal is speed and accuracy of attention shifts.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }

            VStack(spacing: 8) {
                HStack(spacing: 16) {
                    VStack(spacing: 4) {
                        Text("30s")
                            .font(.title3.weight(.bold))
                            .foregroundStyle(AppTheme.gold)
                        Text("Duration")
                            .font(.caption2.weight(.semibold))
                            .foregroundStyle(.secondary)
                    }

                    VStack(spacing: 4) {
                        Text("Rapid")
                            .font(.title3.weight(.bold))
                            .foregroundStyle(AppTheme.gold)
                        Text("Prompts")
                            .font(.caption2.weight(.semibold))
                            .foregroundStyle(.secondary)
                    }
                }
            }

            Spacer()

            Button {
                startDrill()
            } label: {
                Text("Start Drill")
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

    private var activeView: some View {
        VStack(spacing: 32) {
            VStack(spacing: 8) {
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(Color.white.opacity(0.08))
                            .frame(height: 6)
                        Capsule()
                            .fill(AppTheme.gold)
                            .frame(width: max(0, geo.size.width * (timeRemaining / 30)), height: 6)
                            .animation(.linear(duration: 0.1), value: timeRemaining)
                    }
                }
                .frame(height: 6)
                .padding(.horizontal, 24)
                .padding(.top, 16)

                Text(String(format: "%.0f", timeRemaining))
                    .font(.system(size: 20, weight: .bold, design: .monospaced))
                    .foregroundStyle(.secondary)
                    .contentTransition(.numericText())
            }

            Spacer()

            Button {
                tapsCompleted += 1
                advancePrompt()
            } label: {
                VStack(spacing: 16) {
                    Text(currentPrompt)
                        .font(.title2.weight(.bold))
                        .multilineTextAlignment(.center)
                        .foregroundStyle(.primary)

                    Text("TAP")
                        .font(.caption.weight(.black))
                        .foregroundStyle(AppTheme.gold)
                        .tracking(2)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 40)
                .background(Color(.secondarySystemGroupedBackground))
                .clipShape(.rect(cornerRadius: 20))
                .padding(.horizontal, 24)
            }
            .sensoryFeedback(.impact(weight: .light), trigger: tapsCompleted)

            Spacer()

            Text("\(tapsCompleted) switches")
                .font(.caption.weight(.bold).monospacedDigit())
                .foregroundStyle(AppTheme.gold)
                .padding(.bottom, 24)
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

                Text("\(tapsCompleted) attention switches in 30 seconds")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
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
                    drillID: "focus-switch-30s",
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
            .sensoryFeedback(.success, trigger: drillState)
        }
    }

    private func startDrill() {
        timeRemaining = 30
        tapsCompleted = 0
        promptIndex = 0
        currentPrompt = prompts[0]
        drillState = .active

        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { t in
            timeRemaining -= 0.1
            if timeRemaining <= 0 {
                timeRemaining = 0
                t.invalidate()
                drillState = .complete
            }
        }
    }

    private func advancePrompt() {
        promptIndex = (promptIndex + 1) % prompts.count
        currentPrompt = prompts[promptIndex]
    }

    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
}

nonisolated enum FocusDrillState: Sendable {
    case ready, active, complete
}
