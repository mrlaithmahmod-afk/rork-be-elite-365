import SwiftUI
import SwiftData

struct PreMatchVisualizationView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @State private var phase: VisualizationPhase = .ready
    @State private var phaseIndex: Int = 0
    @State private var timer: Timer?
    @State private var progress: Double = 0
    @State private var effectiveness: Int = 3

    private let phases: [(title: String, instruction: String, duration: Double, icon: String)] = [
        ("Settle", "Close your eyes. Take two slow breaths. Let everything else fade.", 8, "wind"),
        ("See the Pitch", "Visualise the pitch. The surface, the lines, the atmosphere. You are there.", 10, "sportscourt"),
        ("First Touch", "See the ball coming to you. Feel the weight of it. See your first touch — clean, controlled.", 12, "hand.point.up"),
        ("First Pass", "Visualise your first pass. See where it goes. See the weight. Perfect execution.", 12, "arrow.right"),
        ("Composure", "See yourself under pressure. A defender closing in. You are calm. You make the right decision.", 12, "shield.checkered"),
        ("Confidence", "Feel the confidence in your body. You have prepared. You are ready. Carry this into the match.", 10, "bolt.heart"),
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
            .background(Color(.systemBackground))
            .navigationTitle("Pre-Match Visualisation")
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
                Image(systemName: "eye.circle")
                    .font(.system(size: 48))
                    .foregroundStyle(AppTheme.gold)

                Text("Pre-Match Visualisation")
                    .font(.title2.weight(.bold))

                Text("A guided 2-minute mental rehearsal. See your first touch, your first pass, and your composure under pressure. Build confidence before you step onto the pitch.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }

            VStack(spacing: 8) {
                HStack(spacing: 16) {
                    VStack(spacing: 4) {
                        Text("~2 min")
                            .font(.title3.weight(.bold))
                            .foregroundStyle(AppTheme.gold)
                        Text("Duration")
                            .font(.caption2.weight(.semibold))
                            .foregroundStyle(.secondary)
                    }
                    VStack(spacing: 4) {
                        Text("6")
                            .font(.title3.weight(.bold))
                            .foregroundStyle(AppTheme.gold)
                        Text("Scenes")
                            .font(.caption2.weight(.semibold))
                            .foregroundStyle(.secondary)
                    }
                }
            }

            Spacer()

            Button {
                phase = .active
                phaseIndex = 0
                progress = 0
                startPhaseTimer()
            } label: {
                Text("Begin Visualisation")
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
        VStack(spacing: 0) {
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color.white.opacity(0.06))
                        .frame(height: 4)
                    Capsule()
                        .fill(AppTheme.gold)
                        .frame(width: geo.size.width * overallProgress, height: 4)
                        .animation(.linear(duration: 0.2), value: overallProgress)
                }
            }
            .frame(height: 4)
            .padding(.horizontal, 24)
            .padding(.top, 16)

            Spacer()

            VStack(spacing: 24) {
                let current = phases[phaseIndex]

                Image(systemName: current.icon)
                    .font(.system(size: 44))
                    .foregroundStyle(AppTheme.gold)
                    .contentTransition(.symbolEffect(.replace))

                Text(current.title.uppercased())
                    .font(.caption.weight(.black))
                    .foregroundStyle(AppTheme.gold)
                    .tracking(2)

                Text(current.instruction)
                    .font(.title3.weight(.medium))
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.primary.opacity(0.85))
                    .padding(.horizontal, 32)
                    .contentTransition(.opacity)

                ZStack {
                    Circle()
                        .stroke(Color.white.opacity(0.06), lineWidth: 3)
                        .frame(width: 80, height: 80)
                    Circle()
                        .trim(from: 0, to: progress)
                        .stroke(AppTheme.gold, style: StrokeStyle(lineWidth: 3, lineCap: .round))
                        .frame(width: 80, height: 80)
                        .rotationEffect(.degrees(-90))

                    Text("\(phaseIndex + 1)/\(phases.count)")
                        .font(.caption.weight(.bold).monospacedDigit())
                        .foregroundStyle(.secondary)
                }
            }

            Spacer()

            Button {
                advancePhase()
            } label: {
                Text(phaseIndex < phases.count - 1 ? "Next" : "Finish")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(AppTheme.gold)
            }
            .padding(.bottom, 32)
        }
    }

    private var completionView: some View {
        VStack(spacing: 32) {
            Spacer()

            VStack(spacing: 12) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 56))
                    .foregroundStyle(AppTheme.stable)

                Text("Visualisation Complete")
                    .font(.title2.weight(.bold))

                Text("You have mentally rehearsed your performance. Carry this confidence onto the pitch.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)
            }

            VStack(spacing: 12) {
                Text("How ready do you feel?")
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
                    drillID: "prematch-visualisation",
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

    private var overallProgress: Double {
        let totalPhases = Double(phases.count)
        let base = Double(phaseIndex) / totalPhases
        let phaseContribution = progress / totalPhases
        return base + phaseContribution
    }

    private func startPhaseTimer() {
        let duration = phases[phaseIndex].duration
        let interval: TimeInterval = 0.05
        var elapsed: TimeInterval = 0

        stopTimer()
        timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { t in
            elapsed += interval
            progress = min(1.0, elapsed / duration)
            if elapsed >= duration {
                t.invalidate()
                advancePhase()
            }
        }
    }

    private func advancePhase() {
        stopTimer()
        if phaseIndex < phases.count - 1 {
            phaseIndex += 1
            progress = 0
            startPhaseTimer()
        } else {
            phase = .complete
        }
    }

    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
}

nonisolated enum VisualizationPhase: Sendable {
    case ready, active, complete
}
