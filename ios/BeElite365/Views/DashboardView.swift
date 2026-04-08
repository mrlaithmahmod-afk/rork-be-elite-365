import SwiftUI
import SwiftData

struct DashboardView: View {
    @Environment(\.modelContext) private var modelContext
    @Binding var selectedTab: AppTab
    @State private var viewModel = DashboardViewModel()
    @State private var showPaywall = false
    @State private var showPreMatch = false
    @State private var showPostMatch = false
    @State private var showDrillPlayer = false
    @State private var showCheckIn = false
    @State private var showRecoveryDrill = false
    @State private var showBreathing = false
    @State private var showResetGame = false
    @State private var showFocusDrill = false
    @State private var showClutchMode = false
    @State private var showPhysiologicalSigh = false
    @State private var showCognitiveDefusion = false
    @State private var showVisualization = false
    @State private var showConfidenceReplay = false
    @State private var showPressureSimulator = false
    @State private var showThoughtInterrupt = false
    @State private var showFocusSnap = false
    @State private var showPressureNormaliser = false
    @State private var showNextActionLockIn = false
    @State private var showControlSort = false
    @State private var showClarityStack = false
    @State private var showMatchDayMode = false
    @State private var showPostGameDebrief = false
    @State private var showConfidenceVault = false

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                if !viewModel.playerName.isEmpty {
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Welcome back,")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                            Text(viewModel.playerName)
                                .font(.title3.weight(.bold))
                        }
                        Spacer()
                        VStack(alignment: .trailing, spacing: 2) {
                            Text(Date.now.formatted(.dateTime.weekday(.wide)))
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(AppTheme.gold)
                            if let profile = viewModel.profile {
                                HStack(spacing: 4) {
                                    Image(systemName: levelIcon(profile.level))
                                        .font(.system(size: 9))
                                    Text(profile.level.rawValue)
                                        .font(.caption2.weight(.semibold))
                                }
                                .foregroundStyle(AppTheme.gold.opacity(0.7))
                            }
                        }
                    }
                    .padding(.horizontal, 4)
                }

                if let profile = viewModel.profile, profile.subscriptionTier == .free {
                    freeUserBanner
                }

                if GenderExperience.profile(for: viewModel.playerGender).showAffirmationCard {
                    affirmationCard
                }

                if GenderExperience.profile(for: viewModel.playerGender).showMotivationalQuote {
                    motivationalQuoteCard
                }

                PerformanceTriangleView(
                    mentalPrep: viewModel.currentMentalPrep,
                    practice: viewModel.currentPractice,
                    performance: viewModel.currentPerformance,
                    energyLoop: viewModel.currentEnergyLoop
                )

                HStack(spacing: 10) {
                    stateCard(
                        label: "CURRENT STATE",
                        value: viewModel.currentRStage.rawValue,
                        icon: viewModel.currentRStage.icon,
                        color: AppTheme.gold
                    )
                    stateCard(
                        label: "ENERGY FLOW",
                        value: viewModel.currentEnergyLoop == .positive ? "Positive" : viewModel.currentEnergyLoop == .negative ? "Negative" : "Neutral",
                        icon: viewModel.currentEnergyLoop == .positive ? "arrow.up.right" : viewModel.currentEnergyLoop == .negative ? "arrow.down.right" : "equal",
                        color: viewModel.currentEnergyLoop == .positive ? AppTheme.stable : viewModel.currentEnergyLoop == .negative ? AppTheme.breakdown : .secondary
                    )
                }

                ConfidenceIndicatorView(state: viewModel.confidenceState) {
                    showRecoveryDrill = true
                }

                if !viewModel.dailyTasks.isEmpty {
                    dailyTasksSection
                }

                Button {
                    switch viewModel.currentRStage {
                    case .reset: showPreMatch = true
                    case .regroup: selectedTab = .solve
                    case .refocus: selectedTab = .skills
                    }
                } label: {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(viewModel.primaryActionTitle)
                                .font(.headline.weight(.bold))
                                .foregroundStyle(.black)
                            Text(viewModel.primaryActionSubtitle)
                                .font(.caption)
                                .foregroundStyle(.black.opacity(0.7))
                                .lineLimit(2)
                        }
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.body.weight(.semibold))
                            .foregroundStyle(.black.opacity(0.6))
                    }
                    .padding(16)
                    .background(AppTheme.goldGradient)
                    .clipShape(.rect(cornerRadius: 12))
                }

                if let drill = viewModel.recommendedDrill {
                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            Text("TODAY'S DRILL")
                                .font(.caption.weight(.bold))
                                .foregroundStyle(.secondary)
                            Spacer()
                            Text(drill.duration)
                                .font(.caption2.weight(.semibold))
                                .foregroundStyle(AppTheme.gold)
                        }

                        Text(drill.name)
                            .font(.subheadline.weight(.semibold))

                        Text(drill.whyItWorks)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .lineLimit(2)

                        Button {
                            showDrillPlayer = true
                        } label: {
                            Text("Start")
                                .font(.caption.weight(.bold))
                                .foregroundStyle(.black)
                                .padding(.horizontal, 24)
                                .padding(.vertical, 10)
                                .background(AppTheme.gold)
                                .clipShape(Capsule())
                        }
                    }
                    .eliteCard()
                }

                if let match = viewModel.upcomingMatch {
                    nextMatchCard(match)
                }

                confidenceVaultCard

                interactiveDrillsSection

                clarityStackPrompt

                MatchCalendarView()
                    .eliteCard()

                VStack(alignment: .leading, spacing: 12) {
                    Text("QUICK ACCESS")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(.secondary)

                    let columns = [GridItem(.flexible(), spacing: 10), GridItem(.flexible(), spacing: 10)]
                    LazyVGrid(columns: columns, spacing: 10) {
                        quickAccessButton(title: "Match Day", subtitle: "Lock-In", icon: "lock.shield") {
                            showMatchDayMode = true
                        }
                        quickAccessButton(title: "Debrief", subtitle: "Post-Game", icon: "text.badge.checkmark") {
                            showPostGameDebrief = true
                        }
                        quickAccessButton(title: "Vault", subtitle: "Evidence", icon: "lock.shield.fill") {
                            showConfidenceVault = true
                        }
                        quickAccessButton(title: "Pre-Match", subtitle: "Reset", icon: "figure.run") {
                            showPreMatch = true
                        }
                        quickAccessButton(title: "Post-Match", subtitle: "Review", icon: "checkmark.circle") {
                            showPostMatch = true
                        }
                        quickAccessButton(title: "Solve", subtitle: "Problem", icon: "brain") {
                            selectedTab = .solve
                        }
                        quickAccessButton(title: "Daily", subtitle: "Check-In", icon: "square.and.pencil") {
                            showCheckIn = true
                        }
                    }
                }
            }
            .padding(.horizontal)
            .padding(.bottom, 24)
        }
        .background(Color(.systemBackground))
        .navigationTitle("Control Room")
        .sheet(isPresented: $showPreMatch) {
            PreMatchResetView()
        }
        .sheet(isPresented: $showPostMatch) {
            PostMatchReviewView()
        }
        .sheet(isPresented: $showDrillPlayer) {
            if let drill = viewModel.recommendedDrill {
                DrillPlayerView(drill: drill)
            }
        }
        .sheet(isPresented: $showCheckIn) {
            DailyCheckInView()
        }
        .sheet(isPresented: $showRecoveryDrill) {
            RecoveryDrillSheet(confidenceState: viewModel.confidenceState)
        }
        .sheet(isPresented: $showBreathing) {
            BreathingTrainerView()
        }
        .sheet(isPresented: $showResetGame) {
            ResetGameView()
        }
        .sheet(isPresented: $showFocusDrill) {
            FocusSwitchDrillView()
        }
        .sheet(isPresented: $showClutchMode) {
            ClutchModeView()
        }
        .sheet(isPresented: $showPhysiologicalSigh) {
            PhysiologicalSighView()
        }
        .sheet(isPresented: $showCognitiveDefusion) {
            CognitiveDefusionView()
        }
        .sheet(isPresented: $showVisualization) {
            PreMatchVisualizationView()
        }
        .sheet(isPresented: $showConfidenceReplay) {
            ConfidenceReplayView()
        }
        .sheet(isPresented: $showPressureSimulator) {
            PressureSimulatorView()
        }
        .sheet(isPresented: $showThoughtInterrupt) {
            ThoughtInterruptView()
        }
        .sheet(isPresented: $showFocusSnap) {
            FocusSnapView()
        }
        .sheet(isPresented: $showPressureNormaliser) {
            PressureNormaliserView()
        }
        .sheet(isPresented: $showNextActionLockIn) {
            NextActionLockInView()
        }
        .sheet(isPresented: $showControlSort) {
            ControlSortView()
        }
        .sheet(isPresented: $showClarityStack) {
            MentalClarityStackView()
        }
        .sheet(isPresented: $showPaywall) {
            PaywallView()
        }
        .fullScreenCover(isPresented: $showMatchDayMode) {
            MatchDayModeView(match: viewModel.upcomingMatch)
        }
        .sheet(isPresented: $showPostGameDebrief) {
            PostGameDebriefView(match: viewModel.upcomingMatch)
        }
        .sheet(isPresented: $showConfidenceVault) {
            ConfidenceVaultView()
        }
        .task { viewModel.loadData(context: modelContext) }
        .refreshable { viewModel.loadData(context: modelContext) }
    }

    private var freeUserBanner: some View {
        Button {
            showPaywall = true
        } label: {
            HStack(spacing: 12) {
                Image(systemName: "crown")
                    .font(.title3)
                    .foregroundStyle(AppTheme.gold)
                VStack(alignment: .leading, spacing: 2) {
                    Text("Unlock your full potential")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.primary)
                    Text("Upgrade to access unlimited coaching, drills, and insights.")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }
            .padding(14)
            .background(
                LinearGradient(
                    colors: [AppTheme.gold.opacity(0.08), AppTheme.gold.opacity(0.02)],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .strokeBorder(AppTheme.gold.opacity(0.2), lineWidth: 1)
            )
            .clipShape(.rect(cornerRadius: 12))
        }
        .buttonStyle(.plain)
    }

    private func levelIcon(_ level: PlayingLevel) -> String {
        switch level {
        case .grassroots: "leaf.fill"
        case .academy: "graduationcap.fill"
        case .semiPro: "gearshape.fill"
        case .professional: "crown.fill"
        }
    }

    private var dailyTasksSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("TODAY'S PLAN")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(.secondary)
                    .tracking(1)
                Spacer()
                let completed = viewModel.completedTaskIDs.count
                let total = viewModel.dailyTasks.count
                Text("\(completed)/\(total)")
                    .font(.caption.weight(.bold).monospacedDigit())
                    .foregroundStyle(AppTheme.gold)
            }

            ForEach(viewModel.dailyTasks) { task in
                let isCompleted = viewModel.completedTaskIDs.contains(task.id)
                Button {
                    handleTaskTap(task)
                } label: {
                    HStack(spacing: 12) {
                        Image(systemName: isCompleted ? "checkmark.circle.fill" : task.icon)
                            .font(.title3)
                            .foregroundStyle(isCompleted ? AppTheme.stable : AppTheme.gold)
                            .frame(width: 28)

                        VStack(alignment: .leading, spacing: 3) {
                            Text(task.title)
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(isCompleted ? .secondary : .primary)
                                .strikethrough(isCompleted)
                            Text(task.reason)
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                                .lineLimit(2)
                        }

                        Spacer()

                        if !isCompleted {
                            Image(systemName: "chevron.right")
                                .font(.caption2)
                                .foregroundStyle(.tertiary)
                        }
                    }
                    .padding(12)
                    .background(Color(.secondarySystemGroupedBackground))
                    .clipShape(.rect(cornerRadius: 10))
                }
                .buttonStyle(.plain)
                .disabled(isCompleted)
            }
        }
    }

    private var interactiveDrillsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("INTERACTIVE TRAINING")
                .font(.caption.weight(.bold))
                .foregroundStyle(.secondary)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    interactiveDrillCard(
                        title: "10s Reset",
                        subtitle: "Mistake recovery",
                        icon: "timer",
                        duration: "10 sec"
                    ) {
                        showResetGame = true
                    }

                    interactiveDrillCard(
                        title: "Focus Snap",
                        subtitle: "Reaction speed",
                        icon: "eye.circle.fill",
                        duration: "30 sec"
                    ) {
                        showFocusSnap = true
                    }

                    interactiveDrillCard(
                        title: "Thought Stop",
                        subtitle: "Anti-overthinking",
                        icon: "xmark.octagon",
                        duration: "1 min"
                    ) {
                        showThoughtInterrupt = true
                    }

                    interactiveDrillCard(
                        title: "Next Action",
                        subtitle: "2s decisions",
                        icon: "bolt.circle.fill",
                        duration: "2 min"
                    ) {
                        showNextActionLockIn = true
                    }

                    interactiveDrillCard(
                        title: "Control Sort",
                        subtitle: "Swipe to filter",
                        icon: "arrow.left.arrow.right",
                        duration: "2 min"
                    ) {
                        showControlSort = true
                    }

                    interactiveDrillCard(
                        title: "Pressure",
                        subtitle: "Normalise it",
                        icon: "waveform.path.ecg",
                        duration: "60 sec"
                    ) {
                        showPressureNormaliser = true
                    }

                    interactiveDrillCard(
                        title: "Clutch",
                        subtitle: "30s emergency",
                        icon: "bolt.fill",
                        duration: "30 sec"
                    ) {
                        showClutchMode = true
                    }

                    interactiveDrillCard(
                        title: "Replay",
                        subtitle: "Best moments",
                        icon: "play.circle",
                        duration: "3 min"
                    ) {
                        showConfidenceReplay = true
                    }

                    interactiveDrillCard(
                        title: "Simulator",
                        subtitle: "Match pressure",
                        icon: "bolt.shield",
                        duration: "3 min"
                    ) {
                        showPressureSimulator = true
                    }
                }
                .contentMargins(.horizontal, 0)
            }
        }
    }

    private func nextMatchCard(_ match: MatchEvent) -> some View {
        let hoursUntil = Calendar.current.dateComponents([.hour], from: Date(), to: match.date)
        let hours = hoursUntil.hour ?? 0
        let isMatchDay = hours <= 24 && hours >= 0

        return VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("NEXT MATCH")
                    .font(.caption2.weight(.bold))
                    .foregroundStyle(.secondary)
                    .tracking(1)
                Spacer()
                if isMatchDay {
                    Text("MATCH DAY")
                        .font(.caption2.weight(.black))
                        .foregroundStyle(AppTheme.gold)
                        .tracking(0.5)
                }
            }

            HStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(match.opponent.isEmpty ? "Match" : "vs \(match.opponent)")
                        .font(.headline.weight(.bold))
                    HStack(spacing: 8) {
                        Text(match.date.formatted(.dateTime.weekday(.wide).day().month(.abbreviated)))
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text(match.date.formatted(date: .omitted, time: .shortened))
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(AppTheme.gold)
                    }
                }

                Spacer()

                if hours > 0 {
                    VStack(spacing: 2) {
                        Text("\(hours)h")
                            .font(.title2.weight(.bold).monospacedDigit())
                            .foregroundStyle(isMatchDay ? AppTheme.gold : .secondary)
                        Text("to go")
                            .font(.caption2.weight(.semibold))
                            .foregroundStyle(.secondary)
                    }
                }
            }

            if isMatchDay {
                HStack(spacing: 8) {
                    if !match.preMatchCompleted {
                        Button {
                            showMatchDayMode = true
                        } label: {
                            HStack(spacing: 6) {
                                Image(systemName: "lock.shield")
                                    .font(.caption2.weight(.semibold))
                                Text("Lock-In")
                                    .font(.caption.weight(.bold))
                            }
                            .foregroundStyle(.black)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(AppTheme.gold)
                            .clipShape(Capsule())
                        }
                    }

                    if !match.postMatchCompleted && match.date < Date() {
                        Button {
                            showPostGameDebrief = true
                        } label: {
                            HStack(spacing: 6) {
                                Image(systemName: "text.badge.checkmark")
                                    .font(.caption2.weight(.semibold))
                                Text("Debrief")
                                    .font(.caption.weight(.bold))
                            }
                            .foregroundStyle(.primary)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(Color(.secondarySystemGroupedBackground))
                            .clipShape(Capsule())
                        }
                    }
                }
            }
        }
        .eliteCard()
    }

    private func interactiveDrillCard(title: String, subtitle: String, icon: String, duration: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Image(systemName: icon)
                        .font(.title3)
                        .foregroundStyle(AppTheme.gold)
                    Spacer()
                    Text(duration)
                        .font(.caption2.weight(.bold))
                        .foregroundStyle(AppTheme.gold)
                }
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.subheadline.weight(.semibold))
                    Text(subtitle)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }
            .frame(width: 140)
            .padding(14)
            .background(Color(.secondarySystemGroupedBackground))
            .clipShape(.rect(cornerRadius: 12))
        }
        .buttonStyle(.plain)
    }

    private var affirmationCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "sparkles")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(Color(red: 0.85, green: 0.55, blue: 0.65))
                Text("TODAY'S AFFIRMATION")
                    .font(.caption2.weight(.bold))
                    .foregroundStyle(.secondary)
                    .tracking(1)
            }

            Text(GenderExperience.todayAffirmation(for: viewModel.playerGender))
                .font(.subheadline.weight(.medium))
                .lineSpacing(3)
                .foregroundStyle(.primary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(
            LinearGradient(
                colors: [
                    Color(red: 0.85, green: 0.55, blue: 0.65).opacity(0.08),
                    Color(red: 0.85, green: 0.68, blue: 0.22).opacity(0.05)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .strokeBorder(
                    LinearGradient(
                        colors: [Color(red: 0.85, green: 0.55, blue: 0.65).opacity(0.2), AppTheme.gold.opacity(0.1)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
        )
        .clipShape(.rect(cornerRadius: 12))
    }

    private var motivationalQuoteCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "flame.fill")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(AppTheme.gold)
                Text("TODAY'S MOTIVATION")
                    .font(.caption2.weight(.bold))
                    .foregroundStyle(.secondary)
                    .tracking(1)
            }

            Text(GenderExperience.todayMotivationalQuote(for: viewModel.playerGender))
                .font(.subheadline.weight(.semibold))
                .lineSpacing(3)
                .foregroundStyle(.primary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(
            LinearGradient(
                colors: [
                    AppTheme.gold.opacity(0.1),
                    Color(red: 0.95, green: 0.45, blue: 0.2).opacity(0.06)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .strokeBorder(
                    LinearGradient(
                        colors: [AppTheme.gold.opacity(0.25), Color(red: 0.95, green: 0.45, blue: 0.2).opacity(0.1)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
        )
        .clipShape(.rect(cornerRadius: 12))
    }

    private var confidenceVaultCard: some View {
        Button {
            showConfidenceVault = true
        } label: {
            HStack(spacing: 14) {
                ZStack {
                    Circle()
                        .fill(AppTheme.gold.opacity(0.1))
                        .frame(width: 36, height: 36)
                    Image(systemName: "lock.shield")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(AppTheme.gold)
                }

                VStack(alignment: .leading, spacing: 3) {
                    Text("Confidence Vault")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.primary)
                    Text("Your private evidence bank")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }
            .padding(14)
            .background(
                LinearGradient(
                    colors: [AppTheme.gold.opacity(0.06), Color(.secondarySystemGroupedBackground)],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .strokeBorder(AppTheme.gold.opacity(0.12), lineWidth: 1)
            )
            .clipShape(.rect(cornerRadius: 12))
        }
        .buttonStyle(.plain)
    }

    private var clarityStackPrompt: some View {
        Button {
            showClarityStack = true
        } label: {
            HStack(spacing: 14) {
                Image(systemName: "list.bullet.clipboard")
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(AppTheme.gold)
                    .frame(width: 32)

                VStack(alignment: .leading, spacing: 3) {
                    Text("Mental Clarity Stack")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.primary)
                    Text("3 prompts. 5 seconds each. Lock in your focus.")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }

                Spacer()

                Text("15s")
                    .font(.caption2.weight(.bold))
                    .foregroundStyle(AppTheme.gold)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(AppTheme.gold.opacity(0.12))
                    .clipShape(Capsule())
            }
            .eliteCard(padding: 14)
        }
        .buttonStyle(.plain)
    }

    private func handleTaskTap(_ task: DailyTask) {
        switch task.taskType {
        case .breathing:
            showBreathing = true
        case .checkIn:
            showCheckIn = true
        case .solve:
            selectedTab = .solve
        case .drill, .regroup, .refocus:
            if let drillID = task.drillID, let drill = DrillLibrary.drills.first(where: { $0.id == drillID }) {
                viewModel.recommendedDrill = drill
                showDrillPlayer = true
            }
        }
    }

    private func stateCard(label: String, value: String, icon: String, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(label)
                .font(.caption2.weight(.bold))
                .foregroundStyle(.secondary)
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.title3.weight(.medium))
                    .foregroundStyle(color)
                Text(value)
                    .font(.headline.weight(.bold))
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .eliteCard()
    }

    private func quickAccessButton(title: String, subtitle: String, icon: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundStyle(AppTheme.gold)
                VStack(spacing: 2) {
                    Text(title)
                        .font(.caption.weight(.semibold))
                    Text(subtitle)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(Color(.secondarySystemGroupedBackground))
            .clipShape(.rect(cornerRadius: 12))
        }
        .buttonStyle(.plain)
    }
}

struct RecoveryDrillSheet: View {
    @Environment(\.dismiss) private var dismiss
    let confidenceState: ConfidenceState
    @State private var selectedDrill: Drill?
    @State private var showDrillPlayer = false

    private var recoveryDrills: [Drill] {
        ConfidenceRecoveryEngine.recoveryDrills(for: confidenceState)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    VStack(spacing: 8) {
                        Image(systemName: confidenceState.icon)
                            .font(.system(size: 36))
                            .foregroundStyle(AppTheme.gold)
                        Text("Confidence Recovery")
                            .font(.title3.weight(.bold))
                        Text(confidenceState.recoveryPrompt)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, 8)

                    if recoveryDrills.isEmpty {
                        Text("Your confidence is stable. Keep building through consistent preparation.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                    } else {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("RECOMMENDED DRILLS")
                                .font(.caption.weight(.bold))
                                .foregroundStyle(.secondary)

                            ForEach(recoveryDrills) { drill in
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
                                            Text(drill.duration)
                                                .font(.caption2.weight(.bold))
                                                .foregroundStyle(AppTheme.gold)
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
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 24)
            }
            .background(Color(.systemBackground))
            .navigationTitle("Recovery Protocol")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                }
            }
            .sheet(isPresented: $showDrillPlayer) {
                if let drill = selectedDrill {
                    DrillPlayerView(drill: drill)
                }
            }
        }
    }
}
