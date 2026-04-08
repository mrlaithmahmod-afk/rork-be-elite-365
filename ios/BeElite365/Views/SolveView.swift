import SwiftUI
import SwiftData

struct SolveView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \SolutionCard.createdAt, order: .reverse) private var recentCards: [SolutionCard]
    @State private var showSolveFlow = false
    @State private var selectedSection: SolveSection = .solve
    @State private var showPressureNormaliser = false
    @State private var showNextActionLockIn = false
    @State private var showThoughtInterrupt = false
    @State private var showResetGame = false
    @State private var showPaywall = false
    @State private var profile: PlayerProfile?

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    Picker("Section", selection: $selectedSection) {
                        ForEach(SolveSection.allCases) { section in
                            Text(section.rawValue).tag(section)
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal)

                    switch selectedSection {
                    case .solve:
                        solveSection
                    case .tools:
                        MentalToolsView()
                            .padding(.horizontal)
                    case .quickFix:
                        quickFixSection
                    }
                }
                .padding(.bottom, 24)
            }
            .background(Color(.systemBackground))
            .navigationTitle("Solve")
            .navigationDestination(for: PersistentIdentifier.self) { id in
                SolutionCardDetailFromID(cardID: id)
            }
            .fullScreenCover(isPresented: $showSolveFlow) {
                SolveFlowView()
            }
            .sheet(isPresented: $showPressureNormaliser) { PressureNormaliserView() }
            .sheet(isPresented: $showNextActionLockIn) { NextActionLockInView() }
            .sheet(isPresented: $showThoughtInterrupt) { ThoughtInterruptView() }
            .sheet(isPresented: $showResetGame) { ResetGameView() }
            .sheet(isPresented: $showPaywall) { PaywallView() }
            .task {
                let desc = FetchDescriptor<PlayerProfile>(sortBy: [SortDescriptor(\.createdAt, order: .reverse)])
                profile = try? modelContext.fetch(desc).first
            }
        }
    }

    private var solveSection: some View {
        VStack(spacing: 24) {
            VStack(spacing: 12) {
                Image(systemName: "brain")
                    .font(.system(size: 40))
                    .foregroundStyle(AppTheme.gold)

                Text("Problem-Solving Engine")
                    .font(.title3.weight(.bold))

                Text(solveDescription)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
            .padding(.top, 8)
            .padding(.horizontal)

            Button {
                showSolveFlow = true
            } label: {
                Text("Begin Session")
                    .font(.body.weight(.semibold))
                    .foregroundStyle(.black)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(AppTheme.gold)
                    .clipShape(.rect(cornerRadius: 12))
            }
            .padding(.horizontal)

            if !recentCards.isEmpty {
                VStack(alignment: .leading, spacing: 12) {
                    Text("SOLUTION CARDS")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(.secondary)

                    ForEach(recentCards.prefix(5)) { card in
                        NavigationLink(value: card.persistentModelID) {
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(card.situationType.rawValue)
                                        .font(.subheadline.weight(.semibold))
                                        .foregroundStyle(.primary)
                                    Text(card.createdAt.formatted(date: .abbreviated, time: .shortened))
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                                Spacer()
                                HStack(spacing: 4) {
                                    Text(card.skippedR.rawValue)
                                        .font(.caption2.weight(.semibold))
                                        .foregroundStyle(AppTheme.gold)
                                    if card.isPinned {
                                        Image(systemName: "pin.fill")
                                            .font(.caption2)
                                            .foregroundStyle(AppTheme.gold)
                                    }
                                }
                            }
                            .eliteCard()
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal)
            }
        }
    }

    private var quickFixSection: some View {
        VStack(spacing: 20) {
            VStack(spacing: 8) {
                Text("INSTANT INTERVENTIONS")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(.secondary)
                    .tracking(1)
                Text("Fast, interactive drills for in-the-moment problem solving.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding(.horizontal)

            VStack(spacing: 10) {
                quickFixRow(
                    title: "Pressure Normaliser",
                    subtitle: "Reframe pressure as readiness",
                    icon: "waveform.path.ecg",
                    duration: "60 sec",
                    rLabel: "RESET",
                    color: Color(red: 0.85, green: 0.35, blue: 0.30)
                ) {
                    showPressureNormaliser = true
                }

                quickFixRow(
                    title: "Next Action Lock-In",
                    subtitle: "2-second decision training",
                    icon: "bolt.circle.fill",
                    duration: "2 min",
                    rLabel: "REFOCUS",
                    color: Color(red: 0.25, green: 0.75, blue: 0.40)
                ) {
                    showNextActionLockIn = true
                }

                quickFixRow(
                    title: "Thought Interrupt",
                    subtitle: "Stop overthinking now",
                    icon: "xmark.octagon",
                    duration: "1 min",
                    rLabel: "RESET",
                    color: Color(red: 0.85, green: 0.35, blue: 0.30)
                ) {
                    showThoughtInterrupt = true
                }

                quickFixRow(
                    title: "10-Second Reset",
                    subtitle: "Mistake recovery game",
                    icon: "timer",
                    duration: "10 sec",
                    rLabel: "RESET",
                    color: Color(red: 0.85, green: 0.35, blue: 0.30)
                ) {
                    showResetGame = true
                }
            }
            .padding(.horizontal)
        }
    }

    private func quickFixRow(title: String, subtitle: String, icon: String, duration: String, rLabel: String, color: Color, action: @escaping () -> Void) -> some View {
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

    private var solveDescription: String {
        guard let profile else {
            return "Work through a challenge using the 3R framework. Identify the breakdown, reset, regroup, and refocus."
        }
        switch profile.level {
        case .grassroots:
            return "Made a mistake or feeling nervous? Work through it step by step. Build your confidence back."
        case .academy:
            return "Got criticism from the coach? Selection pressure? Work through it using the 3R framework."
        case .semiPro:
            return "Inconsistency, fatigue, or frustration? Identify the breakdown and rebuild your form."
        case .professional:
            return "Pressure load, mental fatigue, or scrutiny. Process it systematically and move forward."
        }
    }
}

nonisolated enum SolveSection: String, CaseIterable, Sendable, Identifiable {
    case solve = "Solve"
    case quickFix = "Quick Fix"
    case tools = "Tools"

    var id: String { rawValue }
}

struct SolutionCardDetailFromID: View {
    @Environment(\.modelContext) private var modelContext
    let cardID: PersistentIdentifier
    @State private var card: SolutionCard?

    var body: some View {
        Group {
            if let card {
                SolutionCardDetailView(card: card)
            } else {
                ProgressView()
            }
        }
        .task {
            card = modelContext.model(for: cardID) as? SolutionCard
        }
    }
}
