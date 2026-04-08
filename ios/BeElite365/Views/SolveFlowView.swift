import SwiftUI
import SwiftData

struct SolveFlowView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel = SolveViewModel()
    @State private var completedCard: SolutionCard?

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule().fill(Color.white.opacity(0.08)).frame(height: 3)
                        Capsule().fill(AppTheme.gold)
                            .frame(width: geo.size.width * viewModel.progress, height: 3)
                            .animation(.smooth(duration: 0.3), value: viewModel.progress)
                    }
                }
                .frame(height: 3)
                .padding(.horizontal, 24)
                .padding(.top, 12)

                Group {
                    if let card = completedCard {
                        completionView(card: card)
                    } else {
                        stepContent
                            .id(viewModel.currentStep)
                            .transition(.opacity)
                            .animation(.smooth(duration: 0.25), value: viewModel.currentStep)
                    }
                }
                .frame(maxHeight: .infinity)

                if completedCard == nil {
                    HStack(spacing: 16) {
                        if viewModel.currentStep > 0 {
                            Button {
                                viewModel.previousStep()
                            } label: {
                                Text("Back")
                                    .font(.body.weight(.medium))
                                    .foregroundStyle(.secondary)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 16)
                            }
                        }
                        Button {
                            if viewModel.currentStep == viewModel.totalSteps - 1 {
                                completedCard = viewModel.saveSolutionCard(context: modelContext)
                            } else {
                                viewModel.nextStep()
                            }
                        } label: {
                            Text(viewModel.currentStep == viewModel.totalSteps - 1 ? "Generate Card" : "Continue")
                                .font(.body.weight(.semibold))
                                .foregroundStyle(.black)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(viewModel.canProceed ? AppTheme.gold : AppTheme.gold.opacity(0.3))
                                .clipShape(.rect(cornerRadius: 12))
                        }
                        .disabled(!viewModel.canProceed)
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 16)
                }
            }
            .background(Color(.systemBackground))
            .preferredColorScheme(.dark)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                        .foregroundStyle(.secondary)
                }
            }
        }
    }

    @ViewBuilder
    private var stepContent: some View {
        switch viewModel.currentStep {
        case 0: situationStep
        case 1: emotionStep
        case 2: triangleStep
        case 3: skippedRStep
        case 4: guidedResetStep
        case 5: guidedRegroupStep
        case 6: refocusStep
        case 7: reviewStep
        default: EmptyView()
        }
    }

    private var situationStep: some View {
        flowContainer(title: "What happened?", subtitle: "Identify the specific situation.") {
            VStack(spacing: 10) {
                ForEach(SituationType.allCases) { situation in
                    flowSelectionRow(title: situation.rawValue, isSelected: viewModel.selectedSituation == situation) {
                        viewModel.selectedSituation = situation
                    }
                }
            }
        }
    }

    private var emotionStep: some View {
        flowContainer(title: "How did you feel?", subtitle: "Name the primary emotion.") {
            VStack(spacing: 10) {
                ForEach(EmotionType.allCases) { emotion in
                    flowSelectionRow(title: emotion.rawValue, isSelected: viewModel.selectedEmotion == emotion) {
                        viewModel.selectedEmotion = emotion
                    }
                }

                VStack(spacing: 8) {
                    Text("Intensity: \(Int(viewModel.emotionIntensity))")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(AppTheme.gold)
                    Slider(value: $viewModel.emotionIntensity, in: 1...10, step: 1)
                        .tint(AppTheme.gold)
                }
                .padding(.top, 8)
            }
        }
    }

    private var triangleStep: some View {
        flowContainer(title: "Which part of your game was affected?", subtitle: "Identify the triangle breakdown.") {
            VStack(spacing: 12) {
                ForEach(TriangleSide.allCases) { side in
                    Button {
                        viewModel.selectedTriangleSide = side
                    } label: {
                        HStack(spacing: 12) {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(side.rawValue)
                                    .font(.subheadline.weight(.semibold))
                                    .foregroundStyle(viewModel.selectedTriangleSide == side ? .black : .white)
                                Text(sideDescription(side))
                                    .font(.caption)
                                    .foregroundStyle(viewModel.selectedTriangleSide == side ? .black.opacity(0.7) : .secondary)
                            }
                            Spacer()
                        }
                        .padding(14)
                        .background(viewModel.selectedTriangleSide == side ? AppTheme.gold : Color(.secondarySystemGroupedBackground))
                        .clipShape(.rect(cornerRadius: 12))
                    }
                }
            }
        }
    }

    private var skippedRStep: some View {
        flowContainer(title: "Which R did you skip?", subtitle: "Which stage of the response sequence did you miss?") {
            VStack(spacing: 12) {
                ForEach(RStage.allCases) { stage in
                    Button {
                        viewModel.selectedSkippedR = stage
                    } label: {
                        HStack(spacing: 12) {
                            Image(systemName: stage.icon)
                                .font(.title3)
                                .foregroundStyle(viewModel.selectedSkippedR == stage ? .black : AppTheme.gold)
                                .frame(width: 32)
                            VStack(alignment: .leading, spacing: 2) {
                                Text(stage.rawValue)
                                    .font(.subheadline.weight(.semibold))
                                    .foregroundStyle(viewModel.selectedSkippedR == stage ? .black : .white)
                                Text(stage.detail)
                                    .font(.caption)
                                    .foregroundStyle(viewModel.selectedSkippedR == stage ? .black.opacity(0.7) : .secondary)
                            }
                            Spacer()
                        }
                        .padding(14)
                        .background(viewModel.selectedSkippedR == stage ? AppTheme.gold : Color(.secondarySystemGroupedBackground))
                        .clipShape(.rect(cornerRadius: 12))
                    }
                }
            }
        }
    }

    private var guidedResetStep: some View {
        flowContainer(title: "Reset", subtitle: "Break emotional momentum. Release the previous moment.") {
            VStack(spacing: 32) {
                BreathingCircle()
                    .frame(height: 180)

                VStack(spacing: 8) {
                    Text("Controlled breathing reset")
                        .font(.subheadline.weight(.semibold))
                    Text("Inhale 4 seconds. Hold 2 seconds. Exhale 6 seconds.\nRepeat three times. Let the moment pass.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }

                Button {
                    viewModel.resetComplete = true
                } label: {
                    Text(viewModel.resetComplete ? "Reset Complete" : "I Have Reset")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(viewModel.resetComplete ? .black : AppTheme.gold)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 12)
                        .background(viewModel.resetComplete ? AppTheme.gold : Color(.secondarySystemGroupedBackground))
                        .clipShape(Capsule())
                }
                .sensoryFeedback(.success, trigger: viewModel.resetComplete)
            }
        }
    }

    private var guidedRegroupStep: some View {
        flowContainer(title: "Regroup", subtitle: "What is still in your control right now?") {
            VStack(spacing: 10) {
                ForEach(viewModel.controllableItems, id: \.self) { item in
                    flowSelectionRow(title: item, isSelected: viewModel.selectedControllables.contains(item)) {
                        if viewModel.selectedControllables.contains(item) {
                            viewModel.selectedControllables.remove(item)
                        } else {
                            viewModel.selectedControllables.insert(item)
                        }
                    }
                }
            }
        }
    }

    private var refocusStep: some View {
        flowContainer(title: "Refocus", subtitle: "Define your next specific action.") {
            VStack(spacing: 20) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("NEXT ACTION")
                        .font(.caption2.weight(.bold))
                        .foregroundStyle(.secondary)
                    TextField("", text: $viewModel.refocusAction, prompt: Text("e.g. Win my next header").foregroundStyle(.white.opacity(0.3)))
                        .font(.body)
                        .padding(14)
                        .background(Color(.secondarySystemGroupedBackground))
                        .clipShape(.rect(cornerRadius: 10))
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text("IF / THEN SCRIPT")
                        .font(.caption2.weight(.bold))
                        .foregroundStyle(.secondary)
                    TextField("", text: $viewModel.ifThenTrigger, prompt: Text("If... (trigger)").foregroundStyle(.white.opacity(0.3)))
                        .font(.body)
                        .padding(14)
                        .background(Color(.secondarySystemGroupedBackground))
                        .clipShape(.rect(cornerRadius: 10))
                    TextField("", text: $viewModel.ifThenResponse, prompt: Text("Then I will... (response)").foregroundStyle(.white.opacity(0.3)))
                        .font(.body)
                        .padding(14)
                        .background(Color(.secondarySystemGroupedBackground))
                        .clipShape(.rect(cornerRadius: 10))
                }
            }
        }
    }

    private var reviewStep: some View {
        flowContainer(title: "Review", subtitle: "Your solution card is ready to be generated.") {
            VStack(alignment: .leading, spacing: 12) {
                reviewRow("Situation", viewModel.selectedSituation?.rawValue ?? "")
                reviewRow("Emotion", "\(viewModel.selectedEmotion?.rawValue ?? "") (\(Int(viewModel.emotionIntensity))/10)")
                reviewRow("Breakdown", viewModel.selectedTriangleSide?.rawValue ?? "")
                reviewRow("Skipped R", viewModel.selectedSkippedR?.rawValue ?? "")
                reviewRow("Refocus Action", viewModel.refocusAction)
                if !viewModel.ifThenTrigger.isEmpty {
                    reviewRow("If/Then", "If \(viewModel.ifThenTrigger), then \(viewModel.ifThenResponse)")
                }
            }
        }
    }

    private func completionView(card: SolutionCard) -> some View {
        ScrollView {
            VStack(spacing: 24) {
                VStack(spacing: 8) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 48))
                        .foregroundStyle(AppTheme.stable)
                    Text("Solution Card Saved")
                        .font(.title3.weight(.bold))
                }
                .padding(.top, 20)

                SolutionCardDetailView(card: card)

                Button {
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
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 24)
        }
    }

    private func flowContainer<Content: View>(title: String, subtitle: String, @ViewBuilder content: () -> Content) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                VStack(alignment: .leading, spacing: 6) {
                    Text(title)
                        .font(.title2.weight(.bold))
                    Text(subtitle)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                content()
            }
            .padding(.horizontal, 24)
            .padding(.top, 24)
        }
        .scrollDismissesKeyboard(.interactively)
    }

    private func flowSelectionRow(title: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack {
                Text(title)
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(isSelected ? .black : .white)
                Spacer()
                if isSelected {
                    Image(systemName: "checkmark")
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(.black)
                }
            }
            .padding(14)
            .background(isSelected ? AppTheme.gold : Color(.secondarySystemGroupedBackground))
            .clipShape(.rect(cornerRadius: 10))
        }
    }

    private func reviewRow(_ label: String, _ value: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(label.uppercased())
                .font(.caption2.weight(.bold))
                .foregroundStyle(.secondary)
            Text(value)
                .font(.subheadline)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .eliteCard(padding: 12)
    }

    private func sideDescription(_ side: TriangleSide) -> String {
        switch side {
        case .mentalPreparation: "Your readiness, mindset, and emotional state before action."
        case .practice: "The quality and intent of your preparation and training."
        case .performance: "Your execution, decisions, and output under match conditions."
        }
    }
}

struct BreathingCircle: View {
    @State private var isExpanded = false

    var body: some View {
        ZStack {
            Circle()
                .fill(AppTheme.gold.opacity(0.08))
                .scaleEffect(isExpanded ? 1.3 : 0.5)

            Circle()
                .fill(AppTheme.gold.opacity(0.15))
                .scaleEffect(isExpanded ? 1.0 : 0.4)

            Circle()
                .stroke(AppTheme.gold.opacity(0.4), lineWidth: 1.5)
                .scaleEffect(isExpanded ? 1.0 : 0.4)

            Text(isExpanded ? "Release" : "Breathe")
                .font(.subheadline.weight(.medium))
                .foregroundStyle(AppTheme.gold)
        }
        .animation(.easeInOut(duration: 4).repeatForever(autoreverses: true), value: isExpanded)
        .onAppear { isExpanded = true }
    }
}
