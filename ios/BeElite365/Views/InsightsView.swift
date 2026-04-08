import SwiftUI
import SwiftData
import Charts

struct InsightsView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel = InsightsViewModel()
    @State private var selectedSection: InsightsSection = .overview
    @State private var showPaywall = false

    private var playerLevel: PlayingLevel { viewModel.profile?.level ?? .academy }
    private var playerTier: SubscriptionTier { viewModel.profile?.subscriptionTier ?? .free }

    var body: some View {
        NavigationStack {
            ScrollView {
                if viewModel.hasEnoughData {
                    VStack(spacing: 20) {
                        Picker("Section", selection: $selectedSection) {
                            ForEach(InsightsSection.allCases) { section in
                                Text(section.rawValue).tag(section)
                            }
                        }
                        .pickerStyle(.segmented)

                        levelInsightHeader

                        switch selectedSection {
                        case .overview:
                            overviewSection
                        case .tracker:
                            if FeatureAccessService.canAccess(feature: .advancedInsights, level: playerLevel, tier: playerTier) {
                                trackerSection
                            } else {
                                LockedFeatureView(
                                    title: "Advanced Tracker",
                                    subtitle: "Unlock pressure patterns, consistency analytics, and performance intelligence.",
                                    requiredTier: FeatureAccessService.requiredTier(for: .advancedInsights, at: playerLevel)
                                ) {
                                    showPaywall = true
                                }
                                .padding(.horizontal)
                            }
                        case .eliteTracker:
                            if FeatureAccessService.canAccess(feature: .eliteInsights, level: playerLevel, tier: playerTier) {
                                EliteTrackerView()
                            } else {
                                LockedFeatureView(
                                    title: "Elite Stats",
                                    subtitle: "Performance intelligence dashboard for advanced players.",
                                    requiredTier: FeatureAccessService.requiredTier(for: .eliteInsights, at: playerLevel)
                                ) {
                                    showPaywall = true
                                }
                                .padding(.horizontal)
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 24)
                } else {
                    ContentUnavailableView(
                        "Not Enough Data",
                        systemImage: "chart.bar.xaxis",
                        description: Text("Complete check-ins and solve sessions to unlock insights into your mental game.")
                    )
                }
            }
            .background(Color(.systemBackground))
            .navigationTitle("Insights")
            .sheet(isPresented: $showPaywall) { PaywallView() }
            .task { viewModel.loadData(context: modelContext) }
            .refreshable { viewModel.loadData(context: modelContext) }
        }
    }

    private var levelInsightHeader: some View {
        Group {
            switch LevelConfig.profile(for: playerLevel).insightsStyle {
            case .simpleTrends:
                HStack(spacing: 8) {
                    Image(systemName: "chart.line.uptrend.xyaxis")
                        .font(.caption)
                        .foregroundStyle(AppTheme.gold)
                    Text("Your confidence and progress trends")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            case .pressurePatterns:
                HStack(spacing: 8) {
                    Image(systemName: "waveform.path.ecg")
                        .font(.caption)
                        .foregroundStyle(AppTheme.gold)
                    Text("Pressure patterns and evaluation performance")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            case .consistencyAnalytics:
                HStack(spacing: 8) {
                    Image(systemName: "chart.bar.fill")
                        .font(.caption)
                        .foregroundStyle(AppTheme.gold)
                    Text("Consistency analytics and form tracking")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            case .performanceIntelligence:
                HStack(spacing: 8) {
                    Image(systemName: "brain")
                        .font(.caption)
                        .foregroundStyle(AppTheme.gold)
                    Text("Performance intelligence dashboard")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
    }

    private var overviewSection: some View {
        VStack(spacing: 20) {
            weeklyInsightSection

            if !viewModel.confidenceTrend.isEmpty {
                confidenceChart
            }

            statsRow

            energyFlowSection

            recoverySection

            patternSection

            if !viewModel.pinnedCards.isEmpty {
                pinnedSection
            }
        }
    }

    private var trackerSection: some View {
        VStack(spacing: 20) {
            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 8) {
                    Image(systemName: "chart.line.uptrend.xyaxis")
                        .font(.caption)
                        .foregroundStyle(AppTheme.gold)
                    Text("ELITE PERFORMANCE TRACKER")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(.secondary)
                        .tracking(1)
                }

                Text("Long-term patterns that reveal your mental game trajectory.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            if !viewModel.confidenceTrend.isEmpty {
                confidenceChart
            }

            if viewModel.confidenceTrend.count >= 3 {
                confidenceAnalysisCard
            }

            if !viewModel.triangleHistory.isEmpty {
                triangleStabilityChart
            }

            pressureTriggerSection

            focusConsistencySection

            mistakeRecoverySection
        }
    }

    private var confidenceAnalysisCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("CONFIDENCE ANALYSIS")
                .font(.caption.weight(.bold))
                .foregroundStyle(.secondary)

            let trend = viewModel.confidenceTrend
            let recent = Array(trend.suffix(3))
            let older = Array(trend.prefix(max(1, trend.count - 3)))
            let recentAvg = recent.reduce(0, +) / max(1, Double(recent.count))
            let olderAvg = older.reduce(0, +) / max(1, Double(older.count))

            HStack(spacing: 16) {
                VStack(spacing: 4) {
                    Text("\(Int(recentAvg))")
                        .font(.title2.weight(.bold))
                        .foregroundStyle(AppTheme.stabilityColor(for: recentAvg))
                    Text("Recent Avg")
                        .font(.caption2.weight(.semibold))
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)

                VStack(spacing: 4) {
                    let diff = recentAvg - olderAvg
                    HStack(spacing: 2) {
                        Image(systemName: diff >= 0 ? "arrow.up.right" : "arrow.down.right")
                            .font(.caption2)
                        Text(String(format: "%+.0f", diff))
                            .font(.title3.weight(.bold))
                    }
                    .foregroundStyle(diff >= 0 ? AppTheme.stable : AppTheme.breakdown)
                    Text("Trend")
                        .font(.caption2.weight(.semibold))
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)

                VStack(spacing: 4) {
                    let lowest = trend.min() ?? 0
                    Text("\(Int(lowest))")
                        .font(.title3.weight(.bold))
                        .foregroundStyle(AppTheme.stabilityColor(for: lowest))
                    Text("Lowest")
                        .font(.caption2.weight(.semibold))
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)
            }
            .eliteCard()
        }
    }

    private var triangleStabilityChart: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("TRIANGLE STABILITY")
                .font(.caption.weight(.bold))
                .foregroundStyle(.secondary)

            Chart {
                ForEach(Array(viewModel.triangleHistory.enumerated()), id: \.offset) { index, entry in
                    LineMark(x: .value("Session", index), y: .value("Score", entry.mental))
                        .foregroundStyle(Color(red: 0.30, green: 0.55, blue: 0.85))
                        .interpolationMethod(.catmullRom)
                        .symbol { Circle().fill(Color(red: 0.30, green: 0.55, blue: 0.85)).frame(width: 4) }

                    LineMark(x: .value("Session", index), y: .value("Score", entry.practice))
                        .foregroundStyle(AppTheme.gold)
                        .interpolationMethod(.catmullRom)
                        .symbol { Circle().fill(AppTheme.gold).frame(width: 4) }

                    LineMark(x: .value("Session", index), y: .value("Score", entry.performance))
                        .foregroundStyle(Color(red: 0.25, green: 0.75, blue: 0.40))
                        .interpolationMethod(.catmullRom)
                        .symbol { Circle().fill(Color(red: 0.25, green: 0.75, blue: 0.40)).frame(width: 4) }
                }
            }
            .chartYScale(domain: 0...100)
            .chartXAxis(.hidden)
            .chartYAxis {
                AxisMarks(values: [0, 50, 100]) { _ in
                    AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5))
                        .foregroundStyle(.white.opacity(0.06))
                    AxisValueLabel()
                        .foregroundStyle(.secondary)
                }
            }
            .frame(height: 140)
            .eliteCard()

            HStack(spacing: 16) {
                legendDot(color: Color(red: 0.30, green: 0.55, blue: 0.85), label: "Mental Prep")
                legendDot(color: AppTheme.gold, label: "Practice")
                legendDot(color: Color(red: 0.25, green: 0.75, blue: 0.40), label: "Performance")
            }
            .font(.caption2)
        }
    }

    private func legendDot(color: Color, label: String) -> some View {
        HStack(spacing: 4) {
            Circle().fill(color).frame(width: 6, height: 6)
            Text(label).foregroundStyle(.secondary)
        }
    }

    private var pressureTriggerSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("PRESSURE TRIGGERS")
                .font(.caption.weight(.bold))
                .foregroundStyle(.secondary)

            let situationCounts = Dictionary(grouping: viewModel.solutionCards, by: \.situationType)
            let sorted = situationCounts.sorted { $0.value.count > $1.value.count }

            if sorted.isEmpty {
                Text("Complete solve sessions to reveal pressure triggers.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .eliteCard()
            } else {
                ForEach(sorted.prefix(4), id: \.key) { situation, cards in
                    HStack {
                        Text(situation.rawValue)
                            .font(.subheadline.weight(.medium))
                        Spacer()
                        Text("\(cards.count)x")
                            .font(.caption.weight(.bold).monospacedDigit())
                            .foregroundStyle(AppTheme.gold)
                    }
                    .eliteCard(padding: 12)
                }
            }
        }
    }

    private var focusConsistencySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("FOCUS CONSISTENCY")
                .font(.caption.weight(.bold))
                .foregroundStyle(.secondary)

            let focusRatings = viewModel.checkIns.prefix(7).map(\.focusRating)
            if focusRatings.isEmpty {
                Text("Log check-ins to track focus consistency.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .eliteCard()
            } else {
                let avg = focusRatings.reduce(0, +) / Double(focusRatings.count)
                let variance = focusRatings.map { ($0 - avg) * ($0 - avg) }.reduce(0, +) / Double(focusRatings.count)
                let consistency = max(0, 100 - variance)

                HStack {
                    VStack(spacing: 4) {
                        Text("\(Int(avg))")
                            .font(.title2.weight(.bold))
                            .foregroundStyle(AppTheme.stabilityColor(for: avg))
                        Text("Avg Focus")
                            .font(.caption2.weight(.semibold))
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity)

                    VStack(spacing: 4) {
                        Text("\(Int(consistency))%")
                            .font(.title2.weight(.bold))
                            .foregroundStyle(AppTheme.stabilityColor(for: consistency))
                        Text("Consistency")
                            .font(.caption2.weight(.semibold))
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                }
                .eliteCard()
            }
        }
    }

    private var mistakeRecoverySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("MISTAKE RECOVERY")
                .font(.caption.weight(.bold))
                .foregroundStyle(.secondary)

            let mistakeCards = viewModel.solutionCards.filter {
                $0.situationType == .mistake || $0.situationType == .lostBall || $0.situationType == .missedChance
            }

            if mistakeCards.count < 2 {
                Text("Complete more solve sessions after mistakes to track recovery speed.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .eliteCard()
            } else {
                let avgIntensity = mistakeCards.map(\.emotionIntensity).reduce(0, +) / Double(mistakeCards.count)
                let recentIntensity = mistakeCards.prefix(2).map(\.emotionIntensity).reduce(0, +) / Double(min(2, mistakeCards.count))

                HStack {
                    VStack(spacing: 4) {
                        Text(String(format: "%.1f", avgIntensity))
                            .font(.title2.weight(.bold))
                            .foregroundStyle(avgIntensity <= 5 ? AppTheme.stable : AppTheme.weakening)
                        Text("Avg Intensity")
                            .font(.caption2.weight(.semibold))
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity)

                    VStack(spacing: 4) {
                        let diff = recentIntensity - avgIntensity
                        HStack(spacing: 2) {
                            Image(systemName: diff <= 0 ? "arrow.down.right" : "arrow.up.right")
                                .font(.caption2)
                            Text(String(format: "%+.1f", diff))
                                .font(.title3.weight(.bold))
                        }
                        .foregroundStyle(diff <= 0 ? AppTheme.stable : AppTheme.breakdown)
                        Text("Recent Trend")
                            .font(.caption2.weight(.semibold))
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                }
                .eliteCard()
            }
        }
    }

    private var weeklyInsightSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("WEEKLY INSIGHT")
                .font(.caption.weight(.bold))
                .foregroundStyle(.secondary)

            insightRow(icon: "magnifyingglass", label: "PATTERN", text: viewModel.weeklyPattern)
            insightRow(icon: "arrow.up.right", label: "IMPROVEMENT", text: viewModel.weeklyImprovement)
            if !viewModel.weeklyAdjustment.isEmpty {
                insightRow(icon: "slider.horizontal.3", label: "ADJUSTMENT", text: viewModel.weeklyAdjustment)
            }
        }
    }

    private var confidenceChart: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("CONFIDENCE TREND")
                .font(.caption.weight(.bold))
                .foregroundStyle(.secondary)

            Chart {
                ForEach(Array(viewModel.confidenceTrend.enumerated()), id: \.offset) { index, value in
                    LineMark(
                        x: .value("Session", index),
                        y: .value("Confidence", value)
                    )
                    .foregroundStyle(AppTheme.gold)
                    .interpolationMethod(.catmullRom)

                    AreaMark(
                        x: .value("Session", index),
                        y: .value("Confidence", value)
                    )
                    .foregroundStyle(
                        LinearGradient(
                            colors: [AppTheme.gold.opacity(0.2), AppTheme.gold.opacity(0.02)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .interpolationMethod(.catmullRom)
                }
            }
            .chartYScale(domain: 0...100)
            .chartXAxis(.hidden)
            .chartYAxis {
                AxisMarks(values: [0, 25, 50, 75, 100]) { _ in
                    AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5))
                        .foregroundStyle(.white.opacity(0.06))
                    AxisValueLabel()
                        .foregroundStyle(.secondary)
                }
            }
            .frame(height: 160)
            .eliteCard()
        }
    }

    private var statsRow: some View {
        HStack(spacing: 12) {
            statCard(label: "DRILLS THIS WEEK", value: "\(viewModel.weeklyDrillCount)")
            statCard(label: "TOTAL DRILLS", value: "\(viewModel.totalDrillsCompleted)")
            if let skipped = viewModel.mostSkippedR {
                statCard(label: "MOST SKIPPED", value: skipped.rawValue)
            }
        }
    }

    private var energyFlowSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("ENERGY FLOW (LAST 14 SESSIONS)")
                .font(.caption.weight(.bold))
                .foregroundStyle(.secondary)

            HStack(spacing: 12) {
                energyBar(label: "Positive", count: viewModel.positiveFlowCount, color: AppTheme.stable)
                energyBar(label: "Negative", count: viewModel.negativeFlowCount, color: AppTheme.breakdown)
            }
        }
    }

    private var recoverySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("RECOVERY SPEED")
                .font(.caption.weight(.bold))
                .foregroundStyle(.secondary)

            Text(viewModel.recoverySpeed)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .eliteCard()
        }
    }

    private var patternSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("DIAGNOSTICS")
                .font(.caption.weight(.bold))
                .foregroundStyle(.secondary)

            let insights = PatternAnalysisService.analyze(
                checkIns: viewModel.checkIns,
                cards: viewModel.solutionCards
            )

            ForEach(insights) { insight in
                HStack(alignment: .top, spacing: 10) {
                    Circle()
                        .fill(insight.category == .pattern ? AppTheme.gold : insight.category == .improvement ? AppTheme.stable : AppTheme.weakening)
                        .frame(width: 6, height: 6)
                        .padding(.top, 6)
                    VStack(alignment: .leading, spacing: 2) {
                        Text(insight.category.rawValue.uppercased())
                            .font(.caption2.weight(.bold))
                            .foregroundStyle(.secondary)
                        Text(insight.text)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }
                .eliteCard(padding: 14)
            }
        }
    }

    private var pinnedSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("PINNED SOLUTION CARDS")
                .font(.caption.weight(.bold))
                .foregroundStyle(.secondary)

            ForEach(viewModel.pinnedCards.prefix(3)) { card in
                SolutionCardDetailView(card: card)
            }
        }
    }

    private func insightRow(icon: String, label: String, text: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.caption)
                .foregroundStyle(AppTheme.gold)
                .frame(width: 20)
                .padding(.top, 2)
            VStack(alignment: .leading, spacing: 2) {
                Text(label)
                    .font(.caption2.weight(.bold))
                    .foregroundStyle(.secondary)
                Text(text)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .eliteCard(padding: 14)
    }

    private func statCard(label: String, value: String) -> some View {
        VStack(spacing: 6) {
            Text(value)
                .font(.title3.weight(.bold))
                .foregroundStyle(AppTheme.gold)
            Text(label)
                .font(.system(size: 8, weight: .bold))
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .eliteCard()
    }

    private func energyBar(label: String, count: Int, color: Color) -> some View {
        VStack(spacing: 8) {
            Text("\(count)")
                .font(.title2.weight(.bold))
                .foregroundStyle(color)
            Text(label)
                .font(.caption2.weight(.semibold))
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .eliteCard()
    }
}

nonisolated enum InsightsSection: String, CaseIterable, Sendable, Identifiable {
    case overview = "Overview"
    case tracker = "Tracker"
    case eliteTracker = "Stats"

    var id: String { rawValue }
}
