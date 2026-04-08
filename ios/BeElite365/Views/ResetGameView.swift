import SwiftUI
import SwiftData

struct ResetGameView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @State private var gamePhase: ResetGamePhase = .ready
    @State private var timeRemaining: Double = 10
    @State private var timer: Timer?
    @State private var selectedControllable: String?
    @State private var selectedRefocusCue: String?
    @State private var breathComplete = false
    @State private var effectiveness: Int = 3
    @State private var completionTime: Double = 0
    @State private var phaseFlash = false

    private let controllables = [
        "My effort", "My positioning", "My body language",
        "My next decision", "My first touch", "My communication"
    ]

    private let refocusCues = [
        "Win the next duel", "Play the simple pass", "Hold my position",
        "Sprint back", "First touch, clean", "Communicate early"
    ]

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                switch gamePhase {
                case .ready:
                    readyView
                case .reset:
                    resetPhaseView
                case .regroup:
                    regroupPhaseView
                case .refocus:
                    refocusPhaseView
                case .complete:
                    completionView
                }
            }
            .background(Color(.systemBackground))
            .navigationTitle("10-Second Reset")
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
                Image(systemName: "timer")
                    .font(.system(size: 48))
                    .foregroundStyle(AppTheme.gold)

                Text("10-Second Recovery")
                    .font(.title2.weight(.bold))

                Text("Train your brain to recover from a mistake in 10 seconds. Tap through Reset, Regroup, Refocus as fast as you can.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }

            VStack(alignment: .leading, spacing: 12) {
                phasePreview(seconds: "0-3s", label: "RESET", detail: "Breath + release", color: Color(red: 0.85, green: 0.35, blue: 0.30))
                phasePreview(seconds: "3-7s", label: "REGROUP", detail: "Choose controllable", color: Color(red: 0.30, green: 0.55, blue: 0.85))
                phasePreview(seconds: "7-10s", label: "REFOCUS", detail: "Select next action", color: Color(red: 0.25, green: 0.75, blue: 0.40))
            }
            .padding(.horizontal, 24)

            Spacer()

            Button {
                startGame()
            } label: {
                Text("Start")
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

    private var resetPhaseView: some View {
        VStack(spacing: 32) {
            timerBar

            Spacer()

            VStack(spacing: 16) {
                Text("RESET")
                    .font(.title3.weight(.black))
                    .foregroundStyle(Color(red: 0.85, green: 0.35, blue: 0.30))
                    .tracking(3)

                Text("Release the mistake")
                    .font(.title2.weight(.bold))
                    .multilineTextAlignment(.center)

                Button {
                    breathComplete = true
                    phaseFlash = true
                    withAnimation(.easeInOut(duration: 0.15)) { gamePhase = .regroup }
                } label: {
                    Text("TAP")
                        .font(.title2.weight(.black))
                        .foregroundStyle(.black)
                        .tracking(2)
                        .frame(width: 140, height: 140)
                        .background(Color(red: 0.85, green: 0.35, blue: 0.30))
                        .clipShape(Circle())
                }
                .sensoryFeedback(.impact(weight: .heavy), trigger: breathComplete)
            }

            Spacer()
        }
    }

    private var regroupPhaseView: some View {
        VStack(spacing: 24) {
            timerBar

            Text("REGROUP")
                .font(.title3.weight(.black))
                .foregroundStyle(Color(red: 0.30, green: 0.55, blue: 0.85))
                .tracking(3)
                .padding(.top, 16)

            Text("Choose your focus")
                .font(.title2.weight(.bold))

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                ForEach(controllables, id: \.self) { item in
                    Button {
                        selectedControllable = item
                        withAnimation(.easeInOut(duration: 0.15)) { gamePhase = .refocus }
                    } label: {
                        Text(item)
                            .font(.subheadline.weight(.medium))
                            .foregroundStyle(.primary)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color(.secondarySystemGroupedBackground))
                            .clipShape(.rect(cornerRadius: 12))
                    }
                    .sensoryFeedback(.selection, trigger: selectedControllable)
                }
            }
            .padding(.horizontal, 24)

            Spacer()
        }
    }

    private var refocusPhaseView: some View {
        VStack(spacing: 24) {
            timerBar

            Text("REFOCUS")
                .font(.title3.weight(.black))
                .foregroundStyle(Color(red: 0.25, green: 0.75, blue: 0.40))
                .tracking(3)
                .padding(.top, 16)

            Text("Commit now")
                .font(.title2.weight(.bold))

            VStack(spacing: 10) {
                ForEach(refocusCues, id: \.self) { cue in
                    Button {
                        selectedRefocusCue = cue
                        stopTimer()
                        completionTime = 10 - timeRemaining
                        withAnimation(.easeInOut(duration: 0.15)) { gamePhase = .complete }
                    } label: {
                        Text(cue)
                            .font(.subheadline.weight(.medium))
                            .foregroundStyle(.primary)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(Color(.secondarySystemGroupedBackground))
                            .clipShape(.rect(cornerRadius: 12))
                    }
                    .sensoryFeedback(.success, trigger: selectedRefocusCue)
                }
            }
            .padding(.horizontal, 24)

            Spacer()
        }
    }

    private var completionView: some View {
        VStack(spacing: 32) {
            Spacer()

            VStack(spacing: 12) {
                Image(systemName: completionTime <= 10 ? "checkmark.circle.fill" : "exclamationmark.circle.fill")
                    .font(.system(size: 56))
                    .foregroundStyle(completionTime <= 10 ? AppTheme.stable : AppTheme.weakening)

                Text(completionTime <= 10 ? "Reset Complete" : "Over Time")
                    .font(.title2.weight(.bold))

                Text(String(format: "%.1f seconds", completionTime))
                    .font(.title3.weight(.bold).monospacedDigit())
                    .foregroundStyle(AppTheme.gold)
            }

            VStack(alignment: .leading, spacing: 8) {
                resultRow(label: "CONTROLLABLE", value: selectedControllable ?? "-")
                resultRow(label: "NEXT ACTION", value: selectedRefocusCue ?? "-")
            }
            .padding(.horizontal, 24)

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
                    drillID: "reset-game-10s",
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
        }
    }

    private var timerBar: some View {
        VStack(spacing: 8) {
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color.white.opacity(0.08))
                        .frame(height: 6)
                    Capsule()
                        .fill(timerColor)
                        .frame(width: max(0, geo.size.width * (timeRemaining / 10)), height: 6)
                        .animation(.linear(duration: 0.1), value: timeRemaining)
                }
            }
            .frame(height: 6)
            .padding(.horizontal, 24)
            .padding(.top, 16)

            Text(String(format: "%.1f", timeRemaining))
                .font(.system(size: 24, weight: .bold, design: .monospaced))
                .foregroundStyle(timerColor)
                .contentTransition(.numericText())
        }
    }

    private var timerColor: Color {
        if timeRemaining > 5 { return AppTheme.stable }
        if timeRemaining > 2 { return AppTheme.weakening }
        return AppTheme.breakdown
    }

    private func phasePreview(seconds: String, label: String, detail: String, color: Color) -> some View {
        HStack(spacing: 12) {
            Text(seconds)
                .font(.caption.weight(.bold).monospacedDigit())
                .foregroundStyle(color)
                .frame(width: 40)
            VStack(alignment: .leading, spacing: 2) {
                Text(label)
                    .font(.caption.weight(.bold))
                    .foregroundStyle(color)
                Text(detail)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
        }
        .eliteCard(padding: 12)
    }

    private func resultRow(label: String, value: String) -> some View {
        HStack {
            Text(label)
                .font(.caption2.weight(.bold))
                .foregroundStyle(.secondary)
            Spacer()
            Text(value)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(AppTheme.gold)
        }
        .eliteCard(padding: 12)
    }

    private func startGame() {
        timeRemaining = 10
        gamePhase = .reset
        breathComplete = false
        selectedControllable = nil
        selectedRefocusCue = nil

        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { t in
            timeRemaining -= 0.1
            if timeRemaining <= 0 {
                timeRemaining = 0
                t.invalidate()
                if gamePhase != .complete {
                    completionTime = 10
                    gamePhase = .complete
                }
            }
        }
    }

    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
}

nonisolated enum ResetGamePhase: Sendable {
    case ready, reset, regroup, refocus, complete
}
