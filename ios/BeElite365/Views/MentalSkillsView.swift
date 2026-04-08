import SwiftUI
import SwiftData

struct MentalSkillsView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var selectedSection: ThinkingGymSection = .interactive
    @State private var selectedCategory: DrillCategory? = nil
    @State private var showDrillPlayer = false
    @State private var selectedDrill: Drill?
    @State private var showPhysiologicalSigh = false
    @State private var showCognitiveDefusion = false
    @State private var showVisualization = false
    @State private var showSelfTalkBuilder = false
    @State private var showEmotionalLabeling = false
    @State private var showPressureSimulator = false
    @State private var showConfidenceReplay = false
    @State private var showClutchMode = false
    @State private var showBreathing = false
    @State private var showResetGame = false
    @State private var showFocusDrill = false
    @State private var showThoughtInterrupt = false
    @State private var showFocusSnap = false
    @State private var showControlSort = false
    @State private var showClarityStack = false
    @State private var showPaywall = false
    @State private var profile: PlayerProfile?

    private var playerLevel: PlayingLevel { profile?.level ?? .academy }
    private var playerTier: SubscriptionTier { profile?.subscriptionTier ?? .free }

    private var playerGender: Gender { profile?.gender ?? .preferNotToSay }

    private var levelModules: [ThinkingGymModule] {
        LevelConfig.thinkingGymSections(for: playerLevel, tier: playerTier, gender: playerGender)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    sectionPicker

                    switch selectedSection {
                    case .interactive:
                        interactiveSection
                    case .drills:
                        drillsSection
                    case .pyramid:
                        ElitePyramidView()
                            .padding(.horizontal)
                    case .philosophy:
                        FootballersPyramidView()
                            .padding(.horizontal)
                    case .flow:
                        FlowTrainingView()
                            .padding(.horizontal)
                    case .goals:
                        GoalsView()
                            .padding(.horizontal)
                    case .plan:
                        MentalTrainingPlanView()
                            .padding(.horizontal)
                    }
                }
                .padding(.bottom, 24)
            }
            .background(Color(.systemBackground))
            .navigationTitle("Thinking Gym")
            .navigationDestination(for: UUID.self) { skillID in
                if let skill = MentalSkillData.skills.first(where: { $0.id == skillID }) {
                    SkillDetailView(skill: skill)
                }
            }
            .sheet(isPresented: $showDrillPlayer) {
                if let drill = selectedDrill {
                    DrillPlayerView(drill: drill)
                }
            }
            .sheet(isPresented: $showPhysiologicalSigh) { PhysiologicalSighView() }
            .sheet(isPresented: $showCognitiveDefusion) { CognitiveDefusionView() }
            .sheet(isPresented: $showVisualization) { PreMatchVisualizationView() }
            .sheet(isPresented: $showSelfTalkBuilder) { SelfTalkBuilderView() }
            .sheet(isPresented: $showEmotionalLabeling) { EmotionalLabelingView() }
            .sheet(isPresented: $showPressureSimulator) { PressureSimulatorView() }
            .sheet(isPresented: $showConfidenceReplay) { ConfidenceReplayView() }
            .sheet(isPresented: $showClutchMode) { ClutchModeView() }
            .sheet(isPresented: $showBreathing) { BreathingTrainerView() }
            .sheet(isPresented: $showResetGame) { ResetGameView() }
            .sheet(isPresented: $showFocusDrill) { FocusSwitchDrillView() }
            .sheet(isPresented: $showThoughtInterrupt) { ThoughtInterruptView() }
            .sheet(isPresented: $showFocusSnap) { FocusSnapView() }
            .sheet(isPresented: $showControlSort) { ControlSortView() }
            .sheet(isPresented: $showClarityStack) { MentalClarityStackView() }
            .sheet(isPresented: $showPaywall) { PaywallView() }
            .task {
                let desc = FetchDescriptor<PlayerProfile>(sortBy: [SortDescriptor(\.createdAt, order: .reverse)])
                profile = try? modelContext.fetch(desc).first
            }
        }
    }

    private var interactiveSection: some View {
        VStack(spacing: 20) {
            let grouped = Dictionary(grouping: levelModules, by: \.category)

            ForEach(ModuleCategory.allCases, id: \.self) { category in
                if let modules = grouped[category], !modules.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        sectionHeader(icon: category.icon, title: category.rawValue.uppercased())

                        if category == .decisionTraining {
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 12) {
                                    ForEach(modules) { mod in
                                        if mod.isLocked {
                                            lockedInteractiveCard(mod)
                                        } else {
                                            interactiveCard(title: mod.title, subtitle: mod.subtitle, icon: mod.icon, duration: "", color: AppTheme.gold) {
                                                handleModuleTap(mod)
                                            }
                                        }
                                    }
                                }
                                .contentMargins(.horizontal, 16)
                            }
                        } else {
                            VStack(spacing: 8) {
                                ForEach(modules) { mod in
                                    if mod.isLocked {
                                        lockedModuleRow(mod)
                                    } else {
                                        interactiveRow(title: mod.title, subtitle: mod.subtitle, icon: mod.icon, duration: "", rLabel: mod.category == .levelExclusive ? playerLevel.rawValue.uppercased() : mod.category.rawValue.uppercased(), color: mod.category == .levelExclusive ? AppTheme.gold : Color(red: 0.30, green: 0.55, blue: 0.85)) {
                                            handleModuleTap(mod)
                                        }
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                }
            }
        }
    }

    private func lockedInteractiveCard(_ mod: ThinkingGymModule) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: "lock.fill")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Spacer()
                LockedModuleOverlay(requiredTier: mod.requiredTier)
            }
            VStack(alignment: .leading, spacing: 2) {
                Text(mod.title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.secondary)
                Text(mod.subtitle)
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
                    .lineLimit(2)
            }
        }
        .frame(width: 150)
        .padding(14)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(.rect(cornerRadius: 12))
        .onTapGesture { showPaywall = true }
    }

    private func lockedModuleRow(_ mod: ThinkingGymModule) -> some View {
        Button {
            showPaywall = true
        } label: {
            HStack(spacing: 12) {
                Image(systemName: "lock.fill")
                    .font(.title3)
                    .foregroundStyle(.secondary)
                    .frame(width: 32)
                VStack(alignment: .leading, spacing: 4) {
                    Text(mod.title)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.secondary)
                    Text(mod.subtitle)
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                }
                Spacer()
                LockedModuleOverlay(requiredTier: mod.requiredTier)
            }
            .eliteCard(padding: 14)
        }
        .buttonStyle(.plain)
    }

    private func handleModuleTap(_ mod: ThinkingGymModule) {
        switch mod.id {
        case "reset-game": showResetGame = true
        case "focus-snap": showFocusSnap = true
        case "thought-interrupt": showThoughtInterrupt = true
        case "physiological-sigh": showPhysiologicalSigh = true
        case "box-breathing": showBreathing = true
        case "confidence-builder", "confidence-recall", "form-recovery": showConfidenceReplay = true
        case "simple-routine", "routine-rebuild": showBreathing = true
        case "beginner-self-talk": showSelfTalkBuilder = true
        case "coach-pressure-reset", "criticism-processing": showCognitiveDefusion = true
        case "selection-week", "elite-maintenance", "pressure-monitor": showPressureSimulator = true
        case "training-composure": showClutchMode = true
        case "consistency-engine": showFocusDrill = true
        case "mental-maintenance", "fixture-prep": showVisualization = true
        case "leadership-mode", "private-debrief": showEmotionalLabeling = true
        case "injury-return": showBreathing = true
        default: showResetGame = true
        }
    }

    private func sectionHeader(icon: String, title: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.caption)
                .foregroundStyle(AppTheme.gold)
            Text(title)
                .font(.caption.weight(.bold))
                .foregroundStyle(.secondary)
                .tracking(1)
        }
        .padding(.horizontal)
    }

    private func interactiveCard(title: String, subtitle: String, icon: String, duration: String, color: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Image(systemName: icon)
                        .font(.title3)
                        .foregroundStyle(color)
                    Spacer()
                    Text(duration)
                        .font(.caption2.weight(.bold))
                        .foregroundStyle(color)
                }
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.subheadline.weight(.semibold))
                    Text(subtitle)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                }
            }
            .frame(width: 150)
            .padding(14)
            .background(Color(.secondarySystemGroupedBackground))
            .clipShape(.rect(cornerRadius: 12))
        }
        .buttonStyle(.plain)
    }

    private func interactiveRow(title: String, subtitle: String, icon: String, duration: String, rLabel: String, color: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundStyle(color)
                    .frame(width: 32)

                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.primary)
                    HStack(spacing: 8) {
                        Text(rLabel)
                            .font(.caption2.weight(.bold))
                            .foregroundStyle(color)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(color.opacity(0.12))
                            .clipShape(Capsule())
                        Text(duration)
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                }

                Spacer()

                Image(systemName: "play.circle.fill")
                    .font(.title3)
                    .foregroundStyle(color.opacity(0.6))
            }
            .eliteCard(padding: 14)
        }
        .buttonStyle(.plain)
    }

    private var sectionPicker: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(ThinkingGymSection.allCases) { section in
                    Button {
                        withAnimation(.smooth(duration: 0.2)) {
                            selectedSection = section
                        }
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: section.icon)
                                .font(.caption2)
                            Text(section.rawValue)
                                .font(.caption.weight(.semibold))
                        }
                        .foregroundStyle(selectedSection == section ? .black : .white)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)
                        .background(selectedSection == section ? AppTheme.gold : Color(.secondarySystemGroupedBackground))
                        .clipShape(Capsule())
                    }
                }
            }
            .contentMargins(.horizontal, 16)
        }
    }

    private var drillsSection: some View {
        VStack(spacing: 20) {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    categoryChip(label: "All", isSelected: selectedCategory == nil) {
                        selectedCategory = nil
                    }
                    ForEach(DrillCategory.allCases) { cat in
                        categoryChip(label: cat.rawValue, isSelected: selectedCategory == cat) {
                            selectedCategory = cat
                        }
                    }
                }
                .contentMargins(.horizontal, 16)
            }

            ForEach(filteredCategories, id: \.self) { category in
                VStack(alignment: .leading, spacing: 12) {
                    HStack(spacing: 8) {
                        Image(systemName: category.icon)
                            .font(.caption)
                            .foregroundStyle(AppTheme.gold)
                        Text(category.rawValue.uppercased())
                            .font(.caption.weight(.bold))
                            .foregroundStyle(.secondary)
                    }
                    .padding(.horizontal)

                    ForEach(DrillLibrary.drills(for: category)) { drill in
                        drillRow(drill: drill)
                            .padding(.horizontal)
                    }
                }
            }

            if !MentalSkillData.skills.isEmpty {
                VStack(alignment: .leading, spacing: 12) {
                    HStack(spacing: 8) {
                        Rectangle()
                            .fill(AppTheme.gold)
                            .frame(width: 3, height: 16)
                        Text("MENTAL SKILLS")
                            .font(.caption.weight(.bold))
                            .foregroundStyle(.secondary)
                    }
                    .padding(.horizontal)

                    ForEach(MentalSkillData.skills) { skill in
                        NavigationLink(value: skill.id) {
                            skillRow(skill: skill)
                        }
                        .buttonStyle(.plain)
                        .padding(.horizontal)
                    }
                }
            }
        }
    }

    private var filteredCategories: [DrillCategory] {
        if let selected = selectedCategory {
            return [selected]
        }
        return DrillCategory.allCases
    }

    private func categoryChip(label: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(label)
                .font(.caption.weight(.semibold))
                .foregroundStyle(isSelected ? .black : .white)
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(isSelected ? AppTheme.gold : Color(.secondarySystemGroupedBackground))
                .clipShape(Capsule())
        }
    }

    private func drillRow(drill: Drill) -> some View {
        Button {
            selectedDrill = drill
            showDrillPlayer = true
        } label: {
            HStack(spacing: 12) {
                Image(systemName: drill.rStage.icon)
                    .font(.title3)
                    .foregroundStyle(AppTheme.gold)
                    .frame(width: 32)

                VStack(alignment: .leading, spacing: 4) {
                    Text(drill.name)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.primary)
                    HStack(spacing: 8) {
                        Text(drill.duration)
                            .font(.caption2.weight(.bold))
                            .foregroundStyle(AppTheme.gold)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(AppTheme.gold.opacity(0.12))
                            .clipShape(Capsule())
                        Text(drill.rStage.rawValue)
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                }

                Spacer()

                Image(systemName: "play.circle.fill")
                    .font(.title3)
                    .foregroundStyle(AppTheme.gold.opacity(0.6))
            }
            .eliteCard(padding: 14)
        }
        .buttonStyle(.plain)
    }

    private func skillRow(skill: MentalSkill) -> some View {
        HStack(spacing: 12) {
            Image(systemName: skill.rStage.icon)
                .font(.title3)
                .foregroundStyle(AppTheme.gold)
                .frame(width: 32)

            VStack(alignment: .leading, spacing: 4) {
                Text(skill.name)
                    .font(.subheadline.weight(.semibold))
                HStack(spacing: 8) {
                    Text(skill.rStage.rawValue)
                        .font(.caption2.weight(.bold))
                        .foregroundStyle(AppTheme.gold)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(AppTheme.gold.opacity(0.12))
                        .clipShape(Capsule())
                    Text(skill.principle.rawValue)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
        .eliteCard(padding: 14)
    }
}

nonisolated enum ThinkingGymSection: String, CaseIterable, Sendable, Identifiable {
    case interactive = "Training"
    case drills = "Drills"
    case pyramid = "Pyramid"
    case philosophy = "Philosophy"
    case flow = "Flow"
    case goals = "Goals"
    case plan = "Plan"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .interactive: "bolt.heart"
        case .drills: "figure.strengthtraining.traditional"
        case .pyramid: "triangle"
        case .philosophy: "building.columns"
        case .flow: "wind"
        case .goals: "target"
        case .plan: "calendar.badge.clock"
        }
    }
}
