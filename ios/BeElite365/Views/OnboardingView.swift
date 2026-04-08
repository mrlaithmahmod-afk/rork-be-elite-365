import SwiftUI
import SwiftData

struct OnboardingView: View {
    @Environment(\.modelContext) private var modelContext
    let onComplete: () -> Void
    @State private var viewModel = OnboardingViewModel()
    @State private var showResult = false

    var body: some View {
        VStack(spacing: 0) {
            VStack(spacing: 8) {
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(Color.white.opacity(0.08))
                            .frame(height: 3)
                        Capsule()
                            .fill(AppTheme.gold)
                            .frame(width: geo.size.width * viewModel.progress, height: 3)
                            .animation(.smooth(duration: 0.3), value: viewModel.progress)
                    }
                }
                .frame(height: 3)

                Text("STEP \(viewModel.currentStep + 1) OF \(viewModel.totalSteps)")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(.horizontal, 24)
            .padding(.top, 20)

            Group {
                switch viewModel.currentStep {
                case 0: nameStep
                case 1: genderStep
                case 2: ageBandStep
                case 3: levelStep
                case 4: positionStep
                case 5: primaryGoalStep
                case 6: currentIssuesStep
                case 7: pressureMomentStep
                case 8: mistakeResponseStep
                case 9: selfTalkStep
                case 10: confidenceDependencyStep
                case 11: emotionalControlStep
                case 12: focusStep
                case 13: disciplineStep
                case 14: decisionPointStep
                default: EmptyView()
                }
            }
            .frame(maxHeight: .infinity)
            .id(viewModel.currentStep)
            .transition(.asymmetric(
                insertion: .move(edge: .trailing).combined(with: .opacity),
                removal: .move(edge: .leading).combined(with: .opacity)
            ))
            .animation(.smooth(duration: 0.3), value: viewModel.currentStep)

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
                    if viewModel.isLastStep {
                        viewModel.generateProfile(context: modelContext)
                        showResult = true
                    } else {
                        viewModel.nextStep()
                    }
                } label: {
                    Text(viewModel.isLastStep ? "Generate Profile" : "Continue")
                        .font(.body.weight(.semibold))
                        .foregroundStyle(.black)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(viewModel.canProceed ? AppTheme.gold : AppTheme.gold.opacity(0.3))
                        .clipShape(.rect(cornerRadius: 12))
                }
                .disabled(!viewModel.canProceed)
                .sensoryFeedback(.selection, trigger: viewModel.currentStep)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 16)
        }
        .background(Color(.systemBackground))
        .preferredColorScheme(.dark)
        .fullScreenCover(isPresented: $showResult) {
            ProfileResultView(onBegin: onComplete)
        }
    }

    private var nameStep: some View {
        questionContainer(title: "What should we call you?", subtitle: "First name is fine.") {
            TextField("", text: $viewModel.name, prompt: Text("Your name").foregroundStyle(.white.opacity(0.3)))
                .font(.title2.weight(.medium))
                .foregroundStyle(.white)
                .padding(16)
                .background(Color(.secondarySystemGroupedBackground))
                .clipShape(.rect(cornerRadius: 12))
        }
    }

    private var genderStep: some View {
        questionContainer(title: "How do you identify?", subtitle: "This helps personalise your experience.") {
            VStack(spacing: 10) {
                ForEach(Gender.allCases) { gender in
                    selectionRow(title: gender.rawValue, isSelected: viewModel.selectedGender == gender) {
                        viewModel.selectedGender = gender
                    }
                }
            }
        }
    }

    private var ageBandStep: some View {
        questionContainer(title: "What is your age group?", subtitle: "This helps us tailor the experience appropriately.") {
            VStack(spacing: 10) {
                ForEach(AgeBand.allCases) { band in
                    selectionRow(title: band.rawValue, isSelected: viewModel.selectedAgeBand == band) {
                        viewModel.selectedAgeBand = band
                    }
                }
            }
        }
    }

    private var levelStep: some View {
        questionContainer(title: "What level do you play at?", subtitle: "Current competitive level.") {
            VStack(spacing: 10) {
                ForEach(PlayingLevel.allCases) { level in
                    selectionRow(title: level.rawValue, isSelected: viewModel.selectedLevel == level) {
                        viewModel.selectedLevel = level
                    }
                }
            }
        }
    }

    private var positionStep: some View {
        questionContainer(title: "What position do you play?", subtitle: "Tap your position on the pitch.") {
            PositionPickerView(selectedPosition: $viewModel.selectedPosition)
        }
    }

    private var primaryGoalStep: some View {
        questionContainer(title: "What is your primary goal?", subtitle: "Pick one.") {
            VStack(spacing: 10) {
                ForEach(PrimaryGoal.allCases) { goal in
                    selectionRow(title: goal.rawValue, isSelected: viewModel.selectedPrimaryGoal == goal) {
                        viewModel.selectedPrimaryGoal = goal
                    }
                }
            }
        }
    }

    private var currentIssuesStep: some View {
        questionContainer(title: "Your biggest current issues?", subtitle: "Pick up to 2.") {
            VStack(spacing: 10) {
                ForEach(CurrentIssue.allCases) { issue in
                    let isSelected = viewModel.selectedCurrentIssues.contains(issue)
                    selectionRow(title: issue.rawValue, isSelected: isSelected) {
                        if isSelected {
                            viewModel.selectedCurrentIssues.remove(issue)
                        } else if viewModel.selectedCurrentIssues.count < 2 {
                            viewModel.selectedCurrentIssues.insert(issue)
                        }
                    }
                }
            }
        }
    }

    private var pressureMomentStep: some View {
        questionContainer(title: "When do you feel the most pressure?", subtitle: "Pick one.") {
            VStack(spacing: 10) {
                ForEach(PressureMoment.allCases) { moment in
                    selectionRow(title: moment.rawValue, isSelected: viewModel.selectedPressureMoment == moment) {
                        viewModel.selectedPressureMoment = moment
                    }
                }
            }
        }
    }

    private var mistakeResponseStep: some View {
        questionContainer(title: "How do you respond after a mistake?", subtitle: "Be honest. This builds your profile.") {
            VStack(spacing: 10) {
                ForEach(MistakeResponse.allCases) { response in
                    selectionRow(title: response.rawValue, isSelected: viewModel.selectedMistakeResponse == response) {
                        viewModel.selectedMistakeResponse = response
                    }
                }
            }
        }
    }

    private var selfTalkStep: some View {
        questionContainer(title: "How would you describe your self-talk?", subtitle: "Your internal dialogue during matches.") {
            VStack(spacing: 10) {
                ForEach(SelfTalkStyle.allCases) { style in
                    selectionRow(title: style.rawValue, isSelected: viewModel.selectedSelfTalkStyle == style) {
                        viewModel.selectedSelfTalkStyle = style
                    }
                }
            }
        }
    }

    private var confidenceDependencyStep: some View {
        questionContainer(title: "What does your confidence depend on?", subtitle: "Pick one.") {
            VStack(spacing: 10) {
                ForEach(ConfidenceDependency.allCases) { dep in
                    selectionRow(title: dep.rawValue, isSelected: viewModel.selectedConfidenceDependency == dep) {
                        viewModel.selectedConfidenceDependency = dep
                    }
                }
            }
        }
    }

    private var emotionalControlStep: some View {
        questionContainer(title: "Rate your emotional control", subtitle: "1 = emotions dictate actions, 10 = full regulation under pressure.") {
            sliderControl(value: $viewModel.emotionalControlScore)
        }
    }

    private var focusStep: some View {
        questionContainer(title: "Rate your focus consistency", subtitle: "1 = easily distracted, 10 = locked in throughout a full match.") {
            sliderControl(value: $viewModel.focusConsistencyScore)
        }
    }

    private var disciplineStep: some View {
        questionContainer(title: "What is your current routine like?", subtitle: "Your daily mental performance discipline.") {
            VStack(spacing: 10) {
                ForEach(DisciplineBaseline.allCases) { baseline in
                    selectionRow(title: baseline.rawValue, isSelected: viewModel.selectedDisciplineBaseline == baseline) {
                        viewModel.selectedDisciplineBaseline = baseline
                    }
                }
            }
        }
    }

    private var decisionPointStep: some View {
        questionContainer(title: "When it goes wrong, what do you usually do?", subtitle: "Choose it, or change it.") {
            VStack(spacing: 10) {
                ForEach(DecisionPointHabit.allCases) { habit in
                    selectionRow(title: habit.rawValue, isSelected: viewModel.selectedDecisionPointHabit == habit) {
                        viewModel.selectedDecisionPointHabit = habit
                    }
                }
            }
        }
    }

    private func questionContainer<Content: View>(title: String, subtitle: String, @ViewBuilder content: () -> Content) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                VStack(alignment: .leading, spacing: 8) {
                    Text(title)
                        .font(.title2.weight(.bold))
                    Text(subtitle)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                content()
            }
            .padding(.horizontal, 24)
            .padding(.top, 32)
        }
        .scrollDismissesKeyboard(.interactively)
    }

    private func selectionRow(title: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
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
            .padding(16)
            .background(isSelected ? AppTheme.gold : Color(.secondarySystemGroupedBackground))
            .clipShape(.rect(cornerRadius: 12))
        }
    }

    private func sliderControl(value: Binding<Double>) -> some View {
        VStack(spacing: 20) {
            Text("\(Int(value.wrappedValue))")
                .font(.system(size: 64, weight: .bold, design: .default))
                .foregroundStyle(AppTheme.gold)
                .contentTransition(.numericText())
                .animation(.snappy, value: value.wrappedValue)

            Slider(value: value, in: 1...10, step: 1)
                .tint(AppTheme.gold)

            HStack {
                Text("Low")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Spacer()
                Text("High")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.top, 20)
    }
}

struct ProfileResultView: View {
    @Environment(\.modelContext) private var modelContext
    let onBegin: () -> Void
    @State private var profile: PlayerProfile?
    @State private var appeared = false

    var body: some View {
        ScrollView {
            VStack(spacing: 32) {
                VStack(spacing: 8) {
                    Text("PERFORMANCE PROFILE")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(AppTheme.gold)
                        .tracking(2)
                    if let profile {
                        Text(profile.name)
                            .font(.largeTitle.weight(.bold))
                    }
                }
                .padding(.top, 40)
                .opacity(appeared ? 1 : 0)
                .offset(y: appeared ? 0 : 20)

                if let profile {
                    PerformanceTriangleView(
                        mentalPrep: profile.mentalPrepScore,
                        practice: profile.practiceScore,
                        performance: profile.performanceScore
                    )
                    .opacity(appeared ? 1 : 0)

                    VStack(spacing: 12) {
                        profileRow(label: "YOU TEND TO SKIP", value: profile.defaultSkippedR.rawValue, icon: profile.defaultSkippedR.icon)
                        profileRow(label: "ENERGY STATE", value: profile.currentEnergyLoop.rawValue, icon: profile.currentEnergyLoop == .positive ? "arrow.up.right" : "arrow.down.right")
                        profileRow(label: "TRAINING FOCUS", value: profile.trainingFocusArea.shortName, icon: "target")
                        profileRow(label: "POSITION", value: profile.position.displayName, icon: "sportscourt")
                    }
                    .opacity(appeared ? 1 : 0)
                    .offset(y: appeared ? 0 : 20)

                    VStack(alignment: .leading, spacing: 8) {
                        Text("7-DAY FOCUS PLAN")
                            .font(.caption.weight(.bold))
                            .foregroundStyle(AppTheme.gold)
                        Text("Your first week will focus on \(profile.trainingFocusArea.shortName) through targeted \(profile.defaultSkippedR.rawValue) drills. Complete one drill daily to build your baseline.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .lineSpacing(2)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .eliteCard()
                    .opacity(appeared ? 1 : 0)
                }

                Button(action: onBegin) {
                    Text("Enter Control Room")
                        .font(.body.weight(.semibold))
                        .foregroundStyle(.black)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(AppTheme.gold)
                        .clipShape(.rect(cornerRadius: 12))
                }
                .padding(.top, 8)
                .opacity(appeared ? 1 : 0)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 32)
        }
        .background(Color(.systemBackground))
        .preferredColorScheme(.dark)
        .task {
            let desc = FetchDescriptor<PlayerProfile>(sortBy: [SortDescriptor(\.createdAt, order: .reverse)])
            profile = try? modelContext.fetch(desc).first
            withAnimation(.smooth(duration: 0.6)) { appeared = true }
        }
    }

    private func profileRow(label: String, value: String, icon: String) -> some View {
        HStack {
            Image(systemName: icon)
                .font(.body.weight(.medium))
                .foregroundStyle(AppTheme.gold)
                .frame(width: 32)
            VStack(alignment: .leading, spacing: 2) {
                Text(label)
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(.secondary)
                Text(value)
                    .font(.subheadline.weight(.semibold))
            }
            Spacer()
        }
        .eliteCard()
    }
}
