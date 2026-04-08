import SwiftUI
import SwiftData

struct ControlSortView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @State private var phase: ControlSortPhase = .ready
    @State private var currentIndex: Int = 0
    @State private var correctCount: Int = 0
    @State private var dragOffset: CGFloat = 0
    @State private var showFeedback = false
    @State private var lastCorrect = false
    @State private var effectiveness: Int = 3

    private let statements: [(text: String, controllable: Bool)] = [
        ("My next movement", true),
        ("Coach's opinion", false),
        ("My body language", true),
        ("Crowd noise", false),
        ("My effort level", true),
        ("Last mistake", false),
        ("My communication", true),
        ("Referee decisions", false),
        ("My positioning", true),
        ("Opponent's skill", false),
        ("My first touch", true),
        ("Weather conditions", false),
        ("My preparation", true),
        ("Teammate errors", false),
        ("My breathing", true),
        ("Score line", false),
    ]

    private var shuffled: [(text: String, controllable: Bool)] {
        statements
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                switch phase {
                case .ready: readyView
                case .active: activeView
                case .complete: completionView
                }
            }
            .background(Color(.systemBackground))
            .navigationTitle("Control Sort")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                        .foregroundStyle(.secondary)
                }
            }
        }
        .presentationDetents([.large])
    }

    private var readyView: some View {
        VStack(spacing: 32) {
            Spacer()

            VStack(spacing: 16) {
                Image(systemName: "arrow.left.arrow.right")
                    .font(.system(size: 48))
                    .foregroundStyle(AppTheme.gold)

                Text("Control Sort")
                    .font(.title2.weight(.bold))

                Text("Statements appear. Swipe RIGHT if you can control it. Swipe LEFT if you cannot. Train your brain to instantly filter controllables.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }

            HStack(spacing: 32) {
                VStack(spacing: 6) {
                    Image(systemName: "arrow.left")
                        .font(.title3.weight(.bold))
                        .foregroundStyle(AppTheme.breakdown)
                    Text("No Control")
                        .font(.caption2.weight(.bold))
                        .foregroundStyle(.secondary)
                }
                VStack(spacing: 6) {
                    Image(systemName: "arrow.right")
                        .font(.title3.weight(.bold))
                        .foregroundStyle(AppTheme.stable)
                    Text("Control")
                        .font(.caption2.weight(.bold))
                        .foregroundStyle(.secondary)
                }
            }

            Spacer()

            Button {
                currentIndex = 0
                correctCount = 0
                phase = .active
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

    private var activeView: some View {
        let item = statements[currentIndex]

        return VStack(spacing: 20) {
            HStack {
                Text("\(currentIndex + 1)/\(statements.count)")
                    .font(.caption.weight(.bold).monospacedDigit())
                    .foregroundStyle(.secondary)
                Spacer()
                Text("\(correctCount) correct")
                    .font(.caption.weight(.bold).monospacedDigit())
                    .foregroundStyle(AppTheme.gold)
            }
            .padding(.horizontal, 24)
            .padding(.top, 16)

            HStack {
                Text("NO CONTROL")
                    .font(.caption2.weight(.black))
                    .foregroundStyle(dragOffset < -30 ? AppTheme.breakdown : .secondary.opacity(0.3))
                    .tracking(1)
                Spacer()
                Text("CONTROL")
                    .font(.caption2.weight(.black))
                    .foregroundStyle(dragOffset > 30 ? AppTheme.stable : .secondary.opacity(0.3))
                    .tracking(1)
            }
            .padding(.horizontal, 24)

            Spacer()

            if showFeedback {
                VStack(spacing: 12) {
                    Image(systemName: lastCorrect ? "checkmark.circle.fill" : "xmark.circle.fill")
                        .font(.system(size: 48))
                        .foregroundStyle(lastCorrect ? AppTheme.stable : AppTheme.breakdown)
                    Text(lastCorrect ? "Correct" : "Incorrect")
                        .font(.title3.weight(.bold))
                }
                .transition(.scale.combined(with: .opacity))
            } else {
                Text(item.text)
                    .font(.title2.weight(.bold))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 32)
                    .frame(maxWidth: .infinity)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color(.secondarySystemGroupedBackground))
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .strokeBorder(dragColor.opacity(0.4), lineWidth: 2)
                            )
                    )
                    .padding(.horizontal, 24)
                    .offset(x: dragOffset)
                    .rotationEffect(.degrees(Double(dragOffset) / 20))
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                dragOffset = value.translation.width
                            }
                            .onEnded { value in
                                let threshold: CGFloat = 80
                                if value.translation.width > threshold {
                                    handleSwipe(controllable: true)
                                } else if value.translation.width < -threshold {
                                    handleSwipe(controllable: false)
                                } else {
                                    withAnimation(.spring(response: 0.3)) { dragOffset = 0 }
                                }
                            }
                    )
            }

            Spacer()

            if !showFeedback {
                HStack(spacing: 40) {
                    Button {
                        handleSwipe(controllable: false)
                    } label: {
                        Image(systemName: "xmark")
                            .font(.title2.weight(.bold))
                            .foregroundStyle(.white)
                            .frame(width: 64, height: 64)
                            .background(AppTheme.breakdown)
                            .clipShape(Circle())
                    }

                    Button {
                        handleSwipe(controllable: true)
                    } label: {
                        Image(systemName: "checkmark")
                            .font(.title2.weight(.bold))
                            .foregroundStyle(.white)
                            .frame(width: 64, height: 64)
                            .background(AppTheme.stable)
                            .clipShape(Circle())
                    }
                }
                .padding(.bottom, 32)
            }
        }
    }

    private var completionView: some View {
        VStack(spacing: 32) {
            Spacer()

            VStack(spacing: 12) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 56))
                    .foregroundStyle(AppTheme.stable)

                Text("Sort Complete")
                    .font(.title2.weight(.bold))

                Text("\(correctCount)/\(statements.count) correct")
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(AppTheme.gold)

                let percentage = Double(correctCount) / Double(statements.count) * 100
                Text(percentage >= 80 ? "Sharp filter. You know what matters." : "Keep practising. Filtering improves with reps.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }

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
                let completion = DrillCompletion(drillID: "control-sort", effectiveness: effectiveness)
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

    private var dragColor: Color {
        if dragOffset > 30 { return AppTheme.stable }
        if dragOffset < -30 { return AppTheme.breakdown }
        return .clear
    }

    private func handleSwipe(controllable: Bool) {
        let item = statements[currentIndex]
        let isCorrect = item.controllable == controllable
        if isCorrect { correctCount += 1 }
        lastCorrect = isCorrect

        let generator = UIImpactFeedbackGenerator(style: isCorrect ? .light : .rigid)
        generator.impactOccurred()

        withAnimation(.spring(response: 0.3)) {
            dragOffset = controllable ? 300 : -300
        }

        Task {
            try? await Task.sleep(for: .milliseconds(200))
            withAnimation(.easeInOut(duration: 0.2)) {
                showFeedback = true
            }
            try? await Task.sleep(for: .milliseconds(600))
            withAnimation(.easeInOut(duration: 0.2)) {
                showFeedback = false
                dragOffset = 0
            }
            try? await Task.sleep(for: .milliseconds(100))
            if currentIndex < statements.count - 1 {
                currentIndex += 1
            } else {
                phase = .complete
            }
        }
    }
}

nonisolated enum ControlSortPhase: Sendable {
    case ready, active, complete
}
