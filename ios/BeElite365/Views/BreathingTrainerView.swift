import SwiftUI
import SwiftData

struct BreathingTrainerView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @State private var phase: BreathPhase = .ready
    @State private var cyclesCompleted: Int = 0
    @State private var timer: Timer?
    @State private var phaseProgress: Double = 0
    @State private var preRating: Int = 0
    @State private var postRating: Int = 0
    @State private var showPostRating = false
    @State private var selectedProtocol: BreathProtocol = .calm

    let totalCycles = 3

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                if showPostRating {
                    completionView
                } else if phase == .ready {
                    readyView
                } else {
                    activeView
                }
            }
            .background(Color(.systemBackground))
            .navigationTitle("Breathing Trainer")
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
                Image(systemName: "wind")
                    .font(.system(size: 48))
                    .foregroundStyle(AppTheme.gold)

                Text("Controlled Breathing")
                    .font(.title2.weight(.bold))

                Text("Activate your parasympathetic nervous system to restore decision-making clarity.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }

            VStack(spacing: 12) {
                ForEach(BreathProtocol.allCases) { proto in
                    Button {
                        selectedProtocol = proto
                    } label: {
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(proto.name)
                                    .font(.subheadline.weight(.semibold))
                                    .foregroundStyle(selectedProtocol == proto ? .black : .primary)
                                Text(proto.detail)
                                    .font(.caption)
                                    .foregroundStyle(selectedProtocol == proto ? .black.opacity(0.7) : .secondary)
                            }
                            Spacer()
                            if selectedProtocol == proto {
                                Image(systemName: "checkmark")
                                    .font(.caption.weight(.bold))
                                    .foregroundStyle(.black)
                            }
                        }
                        .padding(14)
                        .background(selectedProtocol == proto ? AppTheme.gold : Color(.secondarySystemGroupedBackground))
                        .clipShape(.rect(cornerRadius: 12))
                    }
                }
            }
            .padding(.horizontal, 24)

            VStack(spacing: 8) {
                Text("How are you feeling right now?")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
                HStack(spacing: 8) {
                    ForEach(1...5, id: \.self) { value in
                        Button {
                            preRating = value
                        } label: {
                            Text("\(value)")
                                .font(.subheadline.weight(.bold))
                                .foregroundStyle(value <= preRating ? .black : .white)
                                .frame(width: 44, height: 44)
                                .background(value <= preRating ? AppTheme.gold : Color(.secondarySystemGroupedBackground))
                                .clipShape(Circle())
                        }
                    }
                }
            }

            Spacer()

            Button {
                startBreathing()
            } label: {
                Text("Press Start")
                    .font(.body.weight(.semibold))
                    .foregroundStyle(.black)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(preRating > 0 ? AppTheme.gold : AppTheme.gold.opacity(0.3))
                    .clipShape(.rect(cornerRadius: 12))
            }
            .disabled(preRating == 0)
            .padding(.horizontal, 24)
            .padding(.bottom, 16)
        }
    }

    private var activeView: some View {
        VStack(spacing: 40) {
            Spacer()

            ZStack {
                Circle()
                    .stroke(Color.white.opacity(0.06), lineWidth: 4)
                    .frame(width: 200, height: 200)

                Circle()
                    .trim(from: 0, to: phaseProgress)
                    .stroke(phase.color, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                    .frame(width: 200, height: 200)
                    .rotationEffect(.degrees(-90))
                    .animation(.linear(duration: 0.1), value: phaseProgress)

                Circle()
                    .fill(phase.color.opacity(phase == .inhale ? 0.15 + phaseProgress * 0.15 : 0.30 - phaseProgress * 0.15))
                    .frame(width: 160, height: 160)
                    .scaleEffect(phase == .inhale ? 0.8 + phaseProgress * 0.2 : 1.0 - phaseProgress * 0.2)
                    .animation(.easeInOut(duration: 0.3), value: phaseProgress)

                VStack(spacing: 8) {
                    Text(phase.instruction)
                        .font(.title3.weight(.bold))
                        .foregroundStyle(phase.color)

                    Text("\(Int(ceil(phaseDuration - phaseProgress * phaseDuration)))")
                        .font(.system(size: 36, weight: .bold, design: .monospaced))
                        .foregroundStyle(.white)
                        .contentTransition(.numericText())
                }
            }

            VStack(spacing: 8) {
                Text("Cycle \(cyclesCompleted + 1) of \(totalCycles)")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)

                Text(selectedProtocol.name)
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
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

                Text("Reset Complete")
                    .font(.title2.weight(.bold))

                Text("\(totalCycles) cycles completed")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            VStack(spacing: 12) {
                Text("How do you feel now?")
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(.secondary)

                HStack(spacing: 8) {
                    ForEach(1...5, id: \.self) { value in
                        Button {
                            postRating = value
                        } label: {
                            Text("\(value)")
                                .font(.subheadline.weight(.bold))
                                .foregroundStyle(value <= postRating ? .black : .white)
                                .frame(width: 44, height: 44)
                                .background(value <= postRating ? AppTheme.gold : Color(.secondarySystemGroupedBackground))
                                .clipShape(Circle())
                        }
                    }
                }
            }

            Spacer()

            Button {
                let completion = DrillCompletion(
                    drillID: "breathing-\(selectedProtocol.rawValue)",
                    effectiveness: postRating
                )
                modelContext.insert(completion)
                dismiss()
            } label: {
                Text("Done")
                    .font(.body.weight(.semibold))
                    .foregroundStyle(.black)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(postRating > 0 ? AppTheme.gold : AppTheme.gold.opacity(0.3))
                    .clipShape(.rect(cornerRadius: 12))
            }
            .disabled(postRating == 0)
            .padding(.horizontal, 24)
            .padding(.bottom, 16)
            .sensoryFeedback(.success, trigger: postRating)
        }
    }

    private var phaseDuration: Double {
        switch phase {
        case .ready: return 0
        case .inhale: return selectedProtocol.inhale
        case .hold: return selectedProtocol.hold
        case .exhale: return selectedProtocol.exhale
        }
    }

    private func startBreathing() {
        phase = .inhale
        phaseProgress = 0
        cyclesCompleted = 0
        startPhaseTimer()
    }

    private func startPhaseTimer() {
        let duration = phaseDuration
        guard duration > 0 else {
            advancePhase()
            return
        }
        let interval: TimeInterval = 0.05
        var elapsed: TimeInterval = 0

        stopTimer()
        timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { t in
            elapsed += interval
            phaseProgress = min(1.0, elapsed / duration)
            if elapsed >= duration {
                t.invalidate()
                advancePhase()
            }
        }
    }

    private func advancePhase() {
        switch phase {
        case .ready:
            break
        case .inhale:
            if selectedProtocol.hold > 0 {
                phase = .hold
            } else {
                phase = .exhale
            }
            phaseProgress = 0
            startPhaseTimer()
        case .hold:
            phase = .exhale
            phaseProgress = 0
            startPhaseTimer()
        case .exhale:
            cyclesCompleted += 1
            if cyclesCompleted >= totalCycles {
                phase = .ready
                showPostRating = true
            } else {
                phase = .inhale
                phaseProgress = 0
                startPhaseTimer()
            }
        }
    }

    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
}

nonisolated enum BreathPhase: Sendable {
    case ready, inhale, hold, exhale

    var instruction: String {
        switch self {
        case .ready: "Ready"
        case .inhale: "Inhale"
        case .hold: "Hold"
        case .exhale: "Exhale"
        }
    }

    var color: Color {
        switch self {
        case .ready: .secondary
        case .inhale: Color(red: 0.30, green: 0.55, blue: 0.85)
        case .hold: AppTheme.gold
        case .exhale: Color(red: 0.25, green: 0.75, blue: 0.40)
        }
    }
}

nonisolated enum BreathProtocol: String, CaseIterable, Sendable, Identifiable {
    case calm = "calm"
    case box = "box"
    case matchday = "matchday"

    var id: String { rawValue }

    var name: String {
        switch self {
        case .calm: "Calm (4-2-6)"
        case .box: "Box Breathing (4-4-4-4)"
        case .matchday: "Matchday Quick Reset"
        }
    }

    var detail: String {
        switch self {
        case .calm: "Deep calm reset. Best for post-match or training."
        case .box: "Balanced regulation. Good for any situation."
        case .matchday: "Fast 2-cycle reset. Use on the pitch."
        }
    }

    var inhale: Double {
        switch self {
        case .calm: 4
        case .box: 4
        case .matchday: 3
        }
    }

    var hold: Double {
        switch self {
        case .calm: 2
        case .box: 4
        case .matchday: 0
        }
    }

    var exhale: Double {
        switch self {
        case .calm: 6
        case .box: 4
        case .matchday: 5
        }
    }
}
