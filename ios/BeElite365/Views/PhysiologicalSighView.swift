import SwiftUI
import SwiftData

struct PhysiologicalSighView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @State private var phase: SighPhase = .ready
    @State private var cyclesCompleted: Int = 0
    @State private var timer: Timer?
    @State private var phaseProgress: Double = 0
    @State private var preRating: Int = 0
    @State private var postRating: Int = 0
    @State private var showPostRating = false
    @State private var circleScale: CGFloat = 0.6

    private let totalCycles = 5

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
            .navigationTitle("Physiological Sigh")
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
                Image(systemName: "lungs.fill")
                    .font(.system(size: 48))
                    .foregroundStyle(AppTheme.gold)

                Text("Physiological Sigh")
                    .font(.title2.weight(.bold))

                Text("The fastest evidence-based calming technique. Double inhale through the nose, long exhale through the mouth. Reduces anxiety in seconds.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }

            VStack(alignment: .leading, spacing: 8) {
                stepPreview(number: "1", text: "Short inhale through nose", color: Color(red: 0.30, green: 0.55, blue: 0.85))
                stepPreview(number: "2", text: "Second inhale (top-up)", color: Color(red: 0.45, green: 0.65, blue: 0.90))
                stepPreview(number: "3", text: "Slow exhale through mouth", color: Color(red: 0.25, green: 0.75, blue: 0.40))
            }
            .padding(.horizontal, 24)

            VStack(spacing: 8) {
                Text("How anxious do you feel right now?")
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
                Text("Begin")
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
                    .frame(width: 220, height: 220)

                Circle()
                    .fill(phase.color.opacity(0.12))
                    .frame(width: 180, height: 180)
                    .scaleEffect(circleScale)
                    .animation(.easeInOut(duration: 0.4), value: circleScale)

                Circle()
                    .trim(from: 0, to: phaseProgress)
                    .stroke(phase.color, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                    .frame(width: 220, height: 220)
                    .rotationEffect(.degrees(-90))

                VStack(spacing: 8) {
                    Text(phase.instruction)
                        .font(.title3.weight(.bold))
                        .foregroundStyle(phase.color)

                    Text(phase.guidance)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .frame(width: 140)
                }
            }

            VStack(spacing: 8) {
                Text("Cycle \(cyclesCompleted + 1) of \(totalCycles)")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)

                HStack(spacing: 4) {
                    ForEach(0..<totalCycles, id: \.self) { i in
                        Circle()
                            .fill(i < cyclesCompleted ? AppTheme.gold : Color.white.opacity(0.1))
                            .frame(width: 8, height: 8)
                    }
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

                Text("Calm Restored")
                    .font(.title2.weight(.bold))

                Text("\(totalCycles) sighs completed")
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

                if postRating > 0 && preRating > 0 {
                    let improvement = postRating - preRating
                    if improvement > 0 {
                        Text("Anxiety reduced by \(improvement) points")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(AppTheme.stable)
                    }
                }
            }

            Spacer()

            Button {
                let completion = DrillCompletion(
                    drillID: "physiological-sigh",
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

    private func stepPreview(number: String, text: String, color: Color) -> some View {
        HStack(spacing: 12) {
            Text(number)
                .font(.caption.weight(.bold).monospacedDigit())
                .foregroundStyle(color)
                .frame(width: 24)
            Text(text)
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Spacer()
        }
        .eliteCard(padding: 12)
    }

    private var phaseDuration: Double {
        switch phase {
        case .ready: 0
        case .inhale1: 2
        case .inhale2: 1.5
        case .exhale: 6
        }
    }

    private func startBreathing() {
        phase = .inhale1
        phaseProgress = 0
        cyclesCompleted = 0
        circleScale = 0.6
        startPhaseTimer()
    }

    private func startPhaseTimer() {
        let duration = phaseDuration
        guard duration > 0 else { return }
        let interval: TimeInterval = 0.05
        var elapsed: TimeInterval = 0

        switch phase {
        case .inhale1, .inhale2:
            withAnimation(.easeInOut(duration: duration)) { circleScale = phase == .inhale1 ? 0.85 : 1.0 }
        case .exhale:
            withAnimation(.easeInOut(duration: duration)) { circleScale = 0.6 }
        case .ready: break
        }

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
        case .ready: break
        case .inhale1:
            phase = .inhale2
            phaseProgress = 0
            startPhaseTimer()
        case .inhale2:
            phase = .exhale
            phaseProgress = 0
            startPhaseTimer()
        case .exhale:
            cyclesCompleted += 1
            if cyclesCompleted >= totalCycles {
                phase = .ready
                showPostRating = true
            } else {
                phase = .inhale1
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

nonisolated enum SighPhase: Sendable {
    case ready, inhale1, inhale2, exhale

    var instruction: String {
        switch self {
        case .ready: "Ready"
        case .inhale1: "Inhale"
        case .inhale2: "Inhale Again"
        case .exhale: "Slow Exhale"
        }
    }

    var guidance: String {
        switch self {
        case .ready: ""
        case .inhale1: "Through your nose"
        case .inhale2: "Top-up breath through nose"
        case .exhale: "Long and slow through mouth"
        }
    }

    var color: Color {
        switch self {
        case .ready: .secondary
        case .inhale1: Color(red: 0.30, green: 0.55, blue: 0.85)
        case .inhale2: Color(red: 0.45, green: 0.65, blue: 0.90)
        case .exhale: Color(red: 0.25, green: 0.75, blue: 0.40)
        }
    }
}
