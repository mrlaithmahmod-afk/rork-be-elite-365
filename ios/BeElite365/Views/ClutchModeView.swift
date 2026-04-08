import SwiftUI
import SwiftData

struct ClutchModeView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @State private var phase: ClutchPhase = .ready
    @State private var timer: Timer?
    @State private var timeRemaining: Double = 30
    @State private var currentStep: Int = 0
    @State private var breathScale: CGFloat = 0.6

    private let steps: [(instruction: String, duration: Double, icon: String)] = [
        ("Exhale sharply. Release everything.", 5, "wind"),
        ("Drop your shoulders. Unclench your jaw.", 5, "figure.stand"),
        ("One deep breath in. Hold.", 5, "lungs"),
        ("Slow exhale. Feel the calm.", 5, "leaf"),
        ("One thought: what is my next action?", 5, "scope"),
        ("Commit. Execute. Go.", 5, "bolt"),
    ]

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                if phase == .ready {
                    readyView
                } else if phase == .active {
                    activeView
                } else {
                    completionView
                }
            }
            .background(Color.black)
            .navigationTitle("")
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
                ZStack {
                    Circle()
                        .fill(AppTheme.gold.opacity(0.08))
                        .frame(width: 120, height: 120)
                    Circle()
                        .fill(AppTheme.gold.opacity(0.15))
                        .frame(width: 80, height: 80)
                    Image(systemName: "bolt.fill")
                        .font(.system(size: 36))
                        .foregroundStyle(AppTheme.gold)
                }

                Text("CLUTCH MODE")
                    .font(.title2.weight(.black))
                    .tracking(3)

                Text("30-second emergency reset. Use before a penalty, free kick, key substitution, or any high-stakes moment.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }

            Spacer()

            Button {
                startClutch()
            } label: {
                Text("Activate")
                    .font(.body.weight(.bold))
                    .foregroundStyle(.black)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(AppTheme.goldGradient)
                    .clipShape(.rect(cornerRadius: 12))
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 16)
        }
    }

    private var activeView: some View {
        VStack(spacing: 0) {
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color.white.opacity(0.06))
                        .frame(height: 4)
                    Capsule()
                        .fill(AppTheme.gold)
                        .frame(width: max(0, geo.size.width * ((30 - timeRemaining) / 30)), height: 4)
                        .animation(.linear(duration: 0.1), value: timeRemaining)
                }
            }
            .frame(height: 4)
            .padding(.horizontal, 24)
            .padding(.top, 16)

            Spacer()

            VStack(spacing: 32) {
                ZStack {
                    Circle()
                        .fill(AppTheme.gold.opacity(0.06))
                        .frame(width: 180, height: 180)
                        .scaleEffect(breathScale)
                        .animation(.easeInOut(duration: 2).repeatForever(autoreverses: true), value: breathScale)

                    Image(systemName: steps[currentStep].icon)
                        .font(.system(size: 44))
                        .foregroundStyle(AppTheme.gold)
                        .contentTransition(.symbolEffect(.replace))
                }

                VStack(spacing: 8) {
                    Text(steps[currentStep].instruction)
                        .font(.title3.weight(.bold))
                        .multilineTextAlignment(.center)
                        .foregroundStyle(.white)
                        .padding(.horizontal, 32)
                        .contentTransition(.opacity)

                    Text("\(currentStep + 1)/\(steps.count)")
                        .font(.caption.weight(.bold).monospacedDigit())
                        .foregroundStyle(.secondary)
                }

                Text(String(format: "%.0f", timeRemaining))
                    .font(.system(size: 28, weight: .bold, design: .monospaced))
                    .foregroundStyle(AppTheme.gold.opacity(0.6))
                    .contentTransition(.numericText())
            }

            Spacer()
        }
    }

    private var completionView: some View {
        VStack(spacing: 32) {
            Spacer()

            VStack(spacing: 16) {
                Image(systemName: "bolt.fill")
                    .font(.system(size: 56))
                    .foregroundStyle(AppTheme.gold)

                Text("Locked In")
                    .font(.title.weight(.black))

                Text("You are reset. You are ready. Execute with full commitment.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }

            Spacer()

            Button {
                let completion = DrillCompletion(
                    drillID: "clutch-mode",
                    effectiveness: 5
                )
                modelContext.insert(completion)
                dismiss()
            } label: {
                Text("Go")
                    .font(.title3.weight(.black))
                    .foregroundStyle(.black)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(AppTheme.goldGradient)
                    .clipShape(.rect(cornerRadius: 12))
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 16)
            .sensoryFeedback(.impact(weight: .heavy), trigger: phase)
        }
    }

    private func startClutch() {
        phase = .active
        currentStep = 0
        timeRemaining = 30
        breathScale = 1.0

        let generator = UIImpactFeedbackGenerator(style: .heavy)
        generator.impactOccurred()

        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { t in
            timeRemaining -= 0.1
            let elapsed = 30 - timeRemaining
            let stepIndex = min(steps.count - 1, Int(elapsed / 5))
            if stepIndex != currentStep {
                currentStep = stepIndex
                let gen = UIImpactFeedbackGenerator(style: .medium)
                gen.impactOccurred()
            }
            if timeRemaining <= 0 {
                timeRemaining = 0
                t.invalidate()
                phase = .complete
            }
        }
    }

    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
}

nonisolated enum ClutchPhase: Sendable {
    case ready, active, complete
}
