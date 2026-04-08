import SwiftUI
import SwiftData

struct MatchDayModeView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @State private var step: MatchDayStep = .arousalSelect
    @State private var arousalState: ArousalState = .wired
    @State private var anchorWord: String = ""
    @State private var breathPhase: BreathPhase = .ready
    @State private var phaseProgress: Double = 0
    @State private var cyclesCompleted: Int = 0
    @State private var timer: Timer?
    @State private var rehearseStep: Int = 0
    @State private var rehearseTimer: Timer?
    @State private var rehearseProgress: Double = 0
    @State private var showLockScreen: Bool = false
    @State private var savedSession: MatchDaySession?
    @State private var previousSelfMessage: String = ""

    let match: MatchEvent?

    private let totalBreathCycles = 3
    private let rehearseActions = [
        "Your first touch. Feel the ball arrive. Clean, composed, exactly where you want it.",
        "Your first press. Aggressive. Body shape perfect. You set the tone.",
        "Your first pass. Sharp. Precise. You're in the game. You belong here."
    ]
    private let rehearseDuration: Double = 30

    var body: some View {
        if showLockScreen {
            matchDayLockScreen
        } else {
            NavigationStack {
                VStack(spacing: 0) {
                    stepIndicator

                    Group {
                        switch step {
                        case .arousalSelect:
                            arousalSelectView
                        case .regulate:
                            regulateView
                        case .rehearse:
                            rehearseView
                        case .anchor:
                            anchorView
                        }
                    }
                    .frame(maxHeight: .infinity)
                    .id(step)
                    .transition(.opacity)
                    .animation(.smooth(duration: 0.3), value: step)
                }
                .background(Color(.systemBackground))
                .navigationTitle("Match Day Lock-In")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Close") {
                            stopAllTimers()
                            dismiss()
                        }
                        .foregroundStyle(.secondary)
                    }
                }
                .task { loadPreviousSelfMessage() }
            }
            .presentationDetents([.large])
            .onDisappear { stopAllTimers() }
        }
    }

    private var stepIndicator: some View {
        HStack(spacing: 4) {
            ForEach(MatchDayStep.allCases, id: \.self) { s in
                Capsule()
                    .fill(s.rawValue <= step.rawValue ? AppTheme.gold : Color.white.opacity(0.08))
                    .frame(height: 3)
            }
        }
        .padding(.horizontal, 24)
        .padding(.top, 8)
    }

    private var arousalSelectView: some View {
        VStack(spacing: 32) {
            Spacer()

            VStack(spacing: 12) {
                Image(systemName: "brain.head.profile")
                    .font(.system(size: 44))
                    .foregroundStyle(AppTheme.gold)

                Text("How are you feeling?")
                    .font(.title2.weight(.bold))

                Text("This determines your breathing pattern.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            VStack(spacing: 12) {
                ForEach(ArousalState.allCases) { state in
                    Button {
                        arousalState = state
                    } label: {
                        HStack(spacing: 14) {
                            Image(systemName: state.icon)
                                .font(.title3)
                                .foregroundStyle(arousalState == state ? .black : AppTheme.gold)
                                .frame(width: 28)

                            VStack(alignment: .leading, spacing: 3) {
                                Text(state.rawValue)
                                    .font(.subheadline.weight(.semibold))
                                    .foregroundStyle(arousalState == state ? .black : .primary)
                                Text(state.breathingPattern)
                                    .font(.caption)
                                    .foregroundStyle(arousalState == state ? .black.opacity(0.7) : .secondary)
                            }

                            Spacer()

                            if arousalState == state {
                                Image(systemName: "checkmark")
                                    .font(.caption.weight(.bold))
                                    .foregroundStyle(.black)
                            }
                        }
                        .padding(16)
                        .background(arousalState == state ? AppTheme.gold : Color(.secondarySystemGroupedBackground))
                        .clipShape(.rect(cornerRadius: 12))
                    }
                }
            }
            .padding(.horizontal, 24)

            if !previousSelfMessage.isEmpty {
                VStack(spacing: 8) {
                    Text("FROM YOUR LAST DEBRIEF")
                        .font(.caption2.weight(.bold))
                        .foregroundStyle(.secondary)
                        .tracking(0.5)

                    Text("\"\(previousSelfMessage)\"")
                        .font(.subheadline.italic())
                        .foregroundStyle(AppTheme.gold)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                }
                .padding(.top, 8)
            }

            Spacer()

            Button {
                step = .regulate
                startBreathing()
            } label: {
                Text("Begin Lock-In")
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

    private var regulateView: some View {
        VStack(spacing: 40) {
            Spacer()

            VStack(spacing: 8) {
                Text("REGULATE")
                    .font(.caption.weight(.black))
                    .foregroundStyle(AppTheme.gold)
                    .tracking(2)

                Text(arousalState == .wired ? "Calm your system" : "Activate your system")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            ZStack {
                Circle()
                    .stroke(Color.white.opacity(0.06), lineWidth: 4)
                    .frame(width: 200, height: 200)

                Circle()
                    .trim(from: 0, to: phaseProgress)
                    .stroke(breathPhase.color, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                    .frame(width: 200, height: 200)
                    .rotationEffect(.degrees(-90))
                    .animation(.linear(duration: 0.1), value: phaseProgress)

                Circle()
                    .fill(breathPhase.color.opacity(breathPhase == .inhale ? 0.15 + phaseProgress * 0.15 : 0.30 - phaseProgress * 0.15))
                    .frame(width: 160, height: 160)
                    .scaleEffect(breathPhase == .inhale ? 0.8 + phaseProgress * 0.2 : 1.0 - phaseProgress * 0.2)
                    .animation(.easeInOut(duration: 0.3), value: phaseProgress)

                VStack(spacing: 8) {
                    Text(breathPhase.instruction)
                        .font(.title3.weight(.bold))
                        .foregroundStyle(breathPhase.color)

                    Text("\(Int(ceil(currentPhaseDuration - phaseProgress * currentPhaseDuration)))")
                        .font(.system(size: 36, weight: .bold, design: .monospaced))
                        .foregroundStyle(.white)
                        .contentTransition(.numericText())
                }
            }

            Text("Cycle \(min(cyclesCompleted + 1, totalBreathCycles)) of \(totalBreathCycles)")
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)

            Spacer()
        }
    }

    private var rehearseView: some View {
        VStack(spacing: 32) {
            Spacer()

            VStack(spacing: 8) {
                Text("REHEARSE")
                    .font(.caption.weight(.black))
                    .foregroundStyle(AppTheme.gold)
                    .tracking(2)

                Text("Close your eyes. Feel each action.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            ZStack {
                Circle()
                    .stroke(Color.white.opacity(0.06), lineWidth: 3)
                    .frame(width: 180, height: 180)

                Circle()
                    .trim(from: 0, to: rehearseProgress)
                    .stroke(AppTheme.gold, style: StrokeStyle(lineWidth: 3, lineCap: .round))
                    .frame(width: 180, height: 180)
                    .rotationEffect(.degrees(-90))
                    .animation(.linear(duration: 0.1), value: rehearseProgress)

                VStack(spacing: 6) {
                    Text("\(rehearseStep + 1)")
                        .font(.system(size: 42, weight: .bold, design: .monospaced))
                        .foregroundStyle(AppTheme.gold)
                    Text("of 3")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)
                }
            }

            Text(rehearseActions[min(rehearseStep, rehearseActions.count - 1)])
                .font(.body.weight(.medium))
                .foregroundStyle(.primary)
                .multilineTextAlignment(.center)
                .lineSpacing(4)
                .padding(.horizontal, 40)
                .id(rehearseStep)
                .transition(.opacity)
                .animation(.smooth(duration: 0.4), value: rehearseStep)

            Spacer()
        }
    }

    private var anchorView: some View {
        VStack(spacing: 32) {
            Spacer()

            VStack(spacing: 8) {
                Text("ANCHOR")
                    .font(.caption.weight(.black))
                    .foregroundStyle(AppTheme.gold)
                    .tracking(2)

                Text("Your focus word. The last thing before the pitch.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }

            VStack(spacing: 16) {
                TextField("", text: $anchorWord, prompt: Text("e.g. Composed").foregroundStyle(.white.opacity(0.2)))
                    .font(.system(size: 32, weight: .bold))
                    .multilineTextAlignment(.center)
                    .padding(.vertical, 20)
                    .background(Color(.secondarySystemGroupedBackground))
                    .clipShape(.rect(cornerRadius: 16))
                    .padding(.horizontal, 32)

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(["Composed", "Aggressive", "First to everything", "Fearless", "Controlled", "Relentless"], id: \.self) { suggestion in
                            Button {
                                anchorWord = suggestion
                            } label: {
                                Text(suggestion)
                                    .font(.caption.weight(.semibold))
                                    .foregroundStyle(anchorWord == suggestion ? .black : .primary)
                                    .padding(.horizontal, 14)
                                    .padding(.vertical, 8)
                                    .background(anchorWord == suggestion ? AppTheme.gold : Color(.secondarySystemGroupedBackground))
                                    .clipShape(Capsule())
                            }
                        }
                    }
                    .contentMargins(.horizontal, 32)
                }
            }

            Spacer()

            Button {
                saveSession()
                showLockScreen = true
            } label: {
                Text("Lock In")
                    .font(.body.weight(.bold))
                    .foregroundStyle(.black)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(anchorWord.isEmpty ? AppTheme.gold.opacity(0.3) : AppTheme.gold)
                    .clipShape(.rect(cornerRadius: 12))
            }
            .disabled(anchorWord.isEmpty)
            .padding(.horizontal, 24)
            .padding(.bottom, 16)
            .sensoryFeedback(.success, trigger: showLockScreen)
        }
    }

    private var matchDayLockScreen: some View {
        VStack(spacing: 0) {
            Spacer()

            VStack(spacing: 24) {
                Text(anchorWord.uppercased())
                    .font(.system(size: 44, weight: .black))
                    .foregroundStyle(AppTheme.gold)
                    .tracking(4)
                    .multilineTextAlignment(.center)

                if let match {
                    VStack(spacing: 6) {
                        if !match.opponent.isEmpty {
                            Text("vs \(match.opponent)")
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(.secondary)
                        }
                        Text(match.date.formatted(date: .omitted, time: .shortened))
                            .font(.caption.weight(.bold).monospacedDigit())
                            .foregroundStyle(.tertiary)
                    }
                }
            }

            Spacer()

            VStack(spacing: 16) {
                Text("Put the phone down. You're ready.")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Button {
                    dismiss()
                } label: {
                    Text("Exit")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)
                        .padding(.horizontal, 32)
                        .padding(.vertical, 10)
                        .background(Color(.secondarySystemGroupedBackground))
                        .clipShape(Capsule())
                }
            }
            .padding(.bottom, 40)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black)
        .statusBarHidden()
    }

    private var breathInhale: Double {
        arousalState == .wired ? 4 : 4
    }
    private var breathHold: Double {
        arousalState == .wired ? 7 : 4
    }
    private var breathExhale: Double {
        arousalState == .wired ? 8 : 4
    }

    private var currentPhaseDuration: Double {
        switch breathPhase {
        case .ready: 0
        case .inhale: breathInhale
        case .hold: breathHold
        case .exhale: breathExhale
        }
    }

    private func startBreathing() {
        breathPhase = .inhale
        phaseProgress = 0
        cyclesCompleted = 0
        startPhaseTimer()
    }

    private func startPhaseTimer() {
        let duration = currentPhaseDuration
        guard duration > 0 else {
            advanceBreathPhase()
            return
        }
        let interval: TimeInterval = 0.05
        var elapsed: TimeInterval = 0

        stopBreathTimer()
        timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { t in
            elapsed += interval
            phaseProgress = min(1.0, elapsed / duration)
            if elapsed >= duration {
                t.invalidate()
                advanceBreathPhase()
            }
        }
    }

    private func advanceBreathPhase() {
        switch breathPhase {
        case .ready:
            break
        case .inhale:
            if breathHold > 0 {
                breathPhase = .hold
            } else {
                breathPhase = .exhale
            }
            phaseProgress = 0
            startPhaseTimer()
        case .hold:
            breathPhase = .exhale
            phaseProgress = 0
            startPhaseTimer()
        case .exhale:
            cyclesCompleted += 1
            if cyclesCompleted >= totalBreathCycles {
                stopBreathTimer()
                step = .rehearse
                startRehearseSequence()
            } else {
                breathPhase = .inhale
                phaseProgress = 0
                startPhaseTimer()
            }
        }
    }

    private func startRehearseSequence() {
        rehearseStep = 0
        rehearseProgress = 0
        let interval: TimeInterval = 0.05
        var elapsed: TimeInterval = 0
        let totalDuration = rehearseDuration * Double(rehearseActions.count)

        rehearseTimer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { t in
            elapsed += interval
            let currentActionIndex = min(Int(elapsed / rehearseDuration), rehearseActions.count - 1)
            if currentActionIndex != rehearseStep {
                rehearseStep = currentActionIndex
            }
            let actionElapsed = elapsed - Double(currentActionIndex) * rehearseDuration
            rehearseProgress = min(1.0, actionElapsed / rehearseDuration)

            if elapsed >= totalDuration {
                t.invalidate()
                step = .anchor
            }
        }
    }

    private func stopBreathTimer() {
        timer?.invalidate()
        timer = nil
    }

    private func stopAllTimers() {
        timer?.invalidate()
        timer = nil
        rehearseTimer?.invalidate()
        rehearseTimer = nil
    }

    private func saveSession() {
        let session = MatchDaySession(
            matchEventID: match?.id,
            arousalState: arousalState,
            anchorWord: anchorWord
        )
        session.regulateDurationSeconds = totalBreathCycles * Int(breathInhale + breathHold + breathExhale)
        session.rehearseCompleted = true
        session.anchorCompleted = true
        session.sequenceCompleted = true
        modelContext.insert(session)
        savedSession = session

        if let match {
            match.preMatchCompleted = true
        }
    }

    private func loadPreviousSelfMessage() {
        let desc = FetchDescriptor<PostGameDebrief>(sortBy: [SortDescriptor(\.date, order: .reverse)])
        if let latest = try? modelContext.fetch(desc).first, !latest.selfMessageForNextMatch.isEmpty {
            previousSelfMessage = latest.selfMessageForNextMatch
        }
    }
}

nonisolated enum MatchDayStep: Int, CaseIterable, Sendable {
    case arousalSelect = 0
    case regulate = 1
    case rehearse = 2
    case anchor = 3
}
