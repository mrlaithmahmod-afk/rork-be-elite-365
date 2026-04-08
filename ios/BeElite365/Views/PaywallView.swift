import SwiftUI
import SwiftData

struct PaywallView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @State private var selectedTier: SubscriptionTier = .perform
    @State private var billingCycle: BillingCycle = .yearly
    @State private var profile: PlayerProfile?

    private var recommendedTier: SubscriptionTier {
        guard let profile else { return .perform }
        return FeatureAccessService.recommendedTier(for: profile.level)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    headerSection

                    if let profile {
                        levelBadge(profile.level)
                    }

                    tierCarousel

                    selectedTierDetails

                    billingToggle

                    subscribeButton

                    Button("Restore Purchases") {}
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    legalText
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 32)
            }
            .background(Color(.systemBackground))
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                        .foregroundStyle(.secondary)
                }
            }
            .task {
                let desc = FetchDescriptor<PlayerProfile>(sortBy: [SortDescriptor(\.createdAt, order: .reverse)])
                profile = try? modelContext.fetch(desc).first
                selectedTier = recommendedTier
            }
        }
    }

    private var headerSection: some View {
        VStack(spacing: 12) {
            Image(systemName: "triangle.fill")
                .font(.system(size: 36, weight: .thin))
                .foregroundStyle(AppTheme.gold)

            Text("BE ELITE 365")
                .font(.title3.weight(.black))
                .tracking(2)

            Text("Choose the plan that matches your level.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding(.top, 20)
    }

    private func levelBadge(_ level: PlayingLevel) -> some View {
        HStack(spacing: 8) {
            Image(systemName: levelIcon(level))
                .font(.caption.weight(.semibold))
                .foregroundStyle(AppTheme.gold)
            Text("Recommended for \(level.rawValue) players")
                .font(.caption.weight(.medium))
                .foregroundStyle(.secondary)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 8)
        .background(AppTheme.gold.opacity(0.08))
        .clipShape(Capsule())
    }

    private var tierCarousel: some View {
        VStack(spacing: 10) {
            ForEach(SubscriptionTier.allCases.filter { $0 != .free }) { tier in
                let isSelected = selectedTier == tier
                let isRecommended = tier == recommendedTier

                Button {
                    withAnimation(.smooth(duration: 0.2)) {
                        selectedTier = tier
                    }
                } label: {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            HStack(spacing: 8) {
                                Text(tier.displayName)
                                    .font(.subheadline.weight(.bold))
                                    .foregroundStyle(isSelected ? .black : .white)
                                if isRecommended {
                                    Text("Recommended")
                                        .font(.system(size: 9, weight: .bold))
                                        .foregroundStyle(.black)
                                        .padding(.horizontal, 6)
                                        .padding(.vertical, 2)
                                        .background(isSelected ? Color.black.opacity(0.15) : AppTheme.gold)
                                        .clipShape(Capsule())
                                }
                            }
                            Text(tier.tagline)
                                .font(.caption)
                                .foregroundStyle(isSelected ? .black.opacity(0.6) : .secondary)
                        }
                        Spacer()
                        Text(billingCycle == .yearly ? tier.yearlyMonthlyEquivalent : tier.monthlyPrice)
                            .font(.subheadline.weight(.bold))
                            .foregroundStyle(isSelected ? .black : AppTheme.gold)
                    }
                    .padding(16)
                    .background(isSelected ? AppTheme.gold : Color(.secondarySystemGroupedBackground))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(isSelected ? Color.clear : (isRecommended ? AppTheme.gold.opacity(0.4) : Color(.separator)), lineWidth: 1)
                    )
                    .clipShape(.rect(cornerRadius: 12))
                }
            }
        }
    }

    private var selectedTierDetails: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("WHAT YOU GET")
                .font(.caption.weight(.bold))
                .foregroundStyle(.secondary)
                .tracking(1)

            ForEach(benefits(for: selectedTier), id: \.self) { benefit in
                HStack(spacing: 12) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.caption)
                        .foregroundStyle(AppTheme.gold)
                        .frame(width: 20)
                    Text(benefit)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .eliteCard()
    }

    private var billingToggle: some View {
        HStack(spacing: 0) {
            billingOption(cycle: .yearly, label: "Yearly", detail: "Save 40%")
            billingOption(cycle: .monthly, label: "Monthly", detail: "Flexible")
        }
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(.rect(cornerRadius: 12))
    }

    private func billingOption(cycle: BillingCycle, label: String, detail: String) -> some View {
        Button {
            billingCycle = cycle
        } label: {
            VStack(spacing: 2) {
                Text(label)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(billingCycle == cycle ? .black : .white)
                Text(detail)
                    .font(.caption2)
                    .foregroundStyle(billingCycle == cycle ? .black.opacity(0.6) : .secondary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(billingCycle == cycle ? AppTheme.gold : Color.clear)
            .clipShape(.rect(cornerRadius: 12))
        }
    }

    private var subscribeButton: some View {
        Button {
            dismiss()
        } label: {
            VStack(spacing: 4) {
                Text(billingCycle == .yearly ? "Start 7-Day Free Trial" : "Subscribe Now")
                    .font(.body.weight(.semibold))
                Text(billingCycle == .yearly ? "Then \(selectedTier.yearlyPrice)" : selectedTier.monthlyPrice)
                    .font(.caption)
                    .opacity(0.7)
            }
            .foregroundStyle(.black)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(AppTheme.gold)
            .clipShape(.rect(cornerRadius: 12))
        }
    }

    private var legalText: some View {
        VStack(spacing: 4) {
            Text("Payment will be charged to your Apple ID account at confirmation of purchase. Subscription automatically renews unless cancelled at least 24 hours before the end of the current period.")
                .font(.system(size: 9))
                .foregroundStyle(.quaternary)
                .multilineTextAlignment(.center)

            HStack(spacing: 12) {
                Button("Terms") {}
                    .font(.system(size: 9))
                    .foregroundStyle(.quaternary)
                Button("Privacy") {}
                    .font(.system(size: 9))
                    .foregroundStyle(.quaternary)
            }
        }
    }

    private func benefits(for tier: SubscriptionTier) -> [String] {
        switch tier {
        case .free:
            return []
        case .perform:
            return [
                "Unlimited coach conversations",
                "Full Thinking Gym (basic + intermediate)",
                "Full Solve engine with Solution Cards",
                "Basic insights and trends",
                "Daily mental performance plans",
                "Voice coach mode"
            ]
        case .progress:
            return [
                "Everything in Perform, plus:",
                "Advanced Thinking Gym modules",
                "Pressure & consistency systems",
                "Enhanced insights with pattern analysis",
                "Structured mental routines",
                "Performance tracking over time"
            ]
        case .elite:
            return [
                "Everything in Progress, plus:",
                "Elite-level mental systems",
                "Advanced performance analytics",
                "Private debrief system",
                "Fixture preparation tools",
                "Leadership and pressure load tools"
            ]
        }
    }

    private func levelIcon(_ level: PlayingLevel) -> String {
        switch level {
        case .grassroots: "leaf.fill"
        case .academy: "graduationcap.fill"
        case .semiPro: "gearshape.fill"
        case .professional: "crown.fill"
        }
    }
}

nonisolated enum BillingCycle: Sendable {
    case monthly
    case yearly
}
