import SwiftUI
import SwiftData

struct FocusSnapView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @State private var phase: FocusSnapPhase = .ready
    @State private var timeRemaining: Double = 30
    @State private var timer: Timer?
    @State private var currentDirection: FocusDirection = .up
    @State private var score: Int = 0
    @State private var totalAttempts: Int = 0
    @State private var reactionTimes: [Double] = []
    @State private var lastPromptTime: Date = .now
    @State private var selectedFocus: String = ""
    @State private var effectiveness: Int = 3
    @State private var showResult = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                switch phase {
                case .ready: readyView
                case .active: activeView
                case .focusQuestion: focusQuestionView
                case .complete: completionView
                }
            }
            .background(Color(.systemBackground))
            .navigationTitle("Focus Snap")
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
                Image(systemName: "eye.circle.fill")
                    .font(.system(size: 48))
                    .foregroundStyle(AppTheme.gold)

                Text("Focus Snap")
                    .font(.title2.weight(.bold))

                Text("Arrows appear rapidly. Tap the matching direction as fast as you can. Train your reaction speed and attention sharpness.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }

            HStack(spacing: 24) {
                VStack(spacing: 4) {
                    Text("30s")
                        .font(.title3.weight(.bold))
                        .foregroundStyle(AppTheme.gold)
                    Text("Duration")
                        .font(.caption2.weight(.semibold))
                        .foregroundStyle(.secondary)
                }
                VStack(spacing: 4) {
                    Text("Fast")
                        .font(.title3.weight(.bold))
                        .foregroundStyle(AppTheme.gold)
                    Text("Reactions")
                        .font(.caption2.weight(.semibold))
                        .foregroundStyle(.secondary)
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
        VStack(spacing: 16) {
            VStack(spacing: 8) {
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule().fill(Color.white.opacity(0.08)).frame(height: 6)
                        Capsule().fill(AppTheme.gold)
                            .frame(width: max(0, geo.size.width * (timeRemaining / 30)), height: 6)
                            .animation(.linear(duration: 0.1), value: timeRemaining)
                    }
                }
                .frame(height: 6)
                .padding(.horizontal, 24)
                .padding(.top, 16)

                HStack {
                    Text("\(score) correct")
                        .font(.caption.weight(.bold).monospacedDigit())
                        .foregroundStyle(AppTheme.gold)
                    Spacer()
                    Text(String(format: "%.0fs", timeRemaining))
                        .font(.system(size: 18, weight: .bold, design: .monospaced))
                        .foregroundStyle(.secondary)
                        .contentTransition(.numericText())
                }
                .padding(.horizontal, 24)
            }

            Spacer()

            Image(systemName: currentDirection.arrowIcon)
                .font(.system(size: 80, weight: .bold))
                .foregroundStyle(AppTheme.gold)
                .contentTransition(.symbolEffect(.replace))

            Spacer()

            let columns = [GridItem(.flexible()), GridItem(.flexible())]
            LazyVGrid(columns: columns, spacing: 12) {
                ForEach(FocusDirection.allCases) { dir in
                    Button {
                        handleTap(dir)
                    } label: {
                        Image(systemName: dir.arrowIcon)
                            .font(.title.weight(.bold))
                            .foregroundStyle(.primary)
                            .frame(maxWidth: .infinity)
                            .frame(height: 70)
                            .background(showResult && dir == currentDirection ? AppTheme.stable.opacity(0.2) : Color(.secondarySystemGroupedBackground))
                            .clipShape(.rect(cornerRadius: 16))
                    }
                }
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 24)
        }
    }

    private var focusQuestionView: some View {
        VStack(spacing: 24) {
            Spacer()

            VStack(spacing: 16) {
                Text("FINAL CHECK")
                    .font(.caption.weight(.black))
                    .foregroundStyle(AppTheme.gold)
                    .tracking(2)

                Text("Where should your\nfocus be?")
                    .font(.title2.weight(.bold))
                    .multilineTextAlignment(.center)
            }

            let focusOptions = ["Ball", "Space", "Player"]
            VStack(spacing: 10) {
                ForEach(focusOptions, id: \.self) { option in
                    Button {
                        selectedFocus = option
                        withAnimation { phase = .complete }
                    } label: {
                        Text(option)
                            .font(.headline.weight(.semibold))
                            .foregroundStyle(.primary)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 18)
                            .background(Color(.secondarySystemGroupedBackground))
                            .clipShape(.rect(cornerRadius: 14))
                    }
                    .sensoryFeedback(.selection, trigger: selectedFocus)
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
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 56))
                    .foregroundStyle(AppTheme.stable)

                Text("Drill Complete")
                    .font(.title2.weight(.bold))
            }

            HStack(spacing: 16) {
                statBox(value: "\(score)/\(totalAttempts)", label: "Accuracy")
                if !reactionTimes.isEmpty {
                    let avg = reactionTimes.reduce(0, +) / Double(reactionTimes.count)
                    statBox(value: String(format: "%.2fs", avg), label: "Avg Speed")
                }
                statBox(value: selectedFocus, label: "Focus")
            }
            .padding(.horizontal, 24)

            effectivenessRating

            Spacer()

            Button {
                let completion = DrillCompletion(drillID: "focus-snap", effectiveness: effectiveness)
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

    private var effectivenessRating: some View {
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
    }

    private func startDrill() {
        timeRemaining = 30
        score = 0
        totalAttempts = 0
        reactionTimes = []
        currentDirection = FocusDirection.allCases.randomElement() ?? .up
        lastPromptTime = Date()
        phase = .active

        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { t in
            timeRemaining -= 0.1
            if timeRemaining <= 0 {
                timeRemaining = 0
                t.invalidate()
                phase = .focusQuestion
            }
        }
    }

    private func handleTap(_ direction: FocusDirection) {
        totalAttempts += 1
        let reactionTime = Date().timeIntervalSince(lastPromptTime)
        reactionTimes.append(reactionTime)

        if direction == currentDirection {
            score += 1
        }

        let generator = UIImpactFeedbackGenerator(style: direction == currentDirection ? .light : .rigid)
        generator.impactOccurred()

        showResult = true
        Task {
            try? await Task.sleep(for: .milliseconds(150))
            showResult = false
            currentDirection = FocusDirection.allCases.randomElement() ?? .up
            lastPromptTime = Date()
        }
    }

    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
}

nonisolated enum FocusSnapPhase: Sendable {
    case ready, active, focusQuestion, complete
}

nonisolated enum FocusDirection: String, CaseIterable, Sendable, Identifiable {
    case up, down, left, right

    var id: String { rawValue }

    var arrowIcon: String {
        switch self {
        case .up: "arrow.up"
        case .down: "arrow.down"
        case .left: "arrow.left"
        case .right: "arrow.right"
        }
    }
}
