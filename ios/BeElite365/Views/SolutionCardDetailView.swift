import SwiftUI

struct SolutionCardDetailView: View {
    let card: SolutionCard

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(card.situationType.rawValue)
                        .font(.headline.weight(.bold))
                    Text(card.createdAt.formatted(date: .abbreviated, time: .shortened))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                HStack(spacing: 6) {
                    if card.isPinned {
                        Image(systemName: "pin.fill")
                            .font(.caption2)
                            .foregroundStyle(AppTheme.gold)
                    }
                    Text(card.skippedR.rawValue)
                        .font(.caption.weight(.bold))
                        .foregroundStyle(AppTheme.gold)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(AppTheme.gold.opacity(0.15))
                        .clipShape(Capsule())
                }
            }

            if !card.reframe.isEmpty {
                VStack(alignment: .leading, spacing: 6) {
                    Text("REFRAME")
                        .font(.caption2.weight(.bold))
                        .foregroundStyle(AppTheme.gold)
                    Text(card.reframe)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }

            if !card.microActions.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("MICRO-ACTIONS")
                        .font(.caption2.weight(.bold))
                        .foregroundStyle(AppTheme.gold)
                    ForEach(card.microActions, id: \.self) { action in
                        HStack(spacing: 8) {
                            Circle()
                                .fill(AppTheme.gold)
                                .frame(width: 5, height: 5)
                            Text(action)
                                .font(.subheadline)
                        }
                    }
                }
            }

            if !card.refocusAction.isEmpty {
                VStack(alignment: .leading, spacing: 6) {
                    Text("REFOCUS ACTION")
                        .font(.caption2.weight(.bold))
                        .foregroundStyle(AppTheme.gold)
                    Text(card.refocusAction)
                        .font(.subheadline.weight(.medium))
                }
            }

            if !card.ifThenScript.isEmpty {
                VStack(alignment: .leading, spacing: 6) {
                    Text("IF / THEN SCRIPT")
                        .font(.caption2.weight(.bold))
                        .foregroundStyle(AppTheme.gold)
                    Text(card.ifThenScript)
                        .font(.subheadline.italic())
                        .foregroundStyle(.secondary)
                }
            }

            if card.usageCount > 0 {
                HStack(spacing: 4) {
                    Text("Used \(card.usageCount) time\(card.usageCount == 1 ? "" : "s")")
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                }
            }
        }
        .eliteCard()
    }
}
