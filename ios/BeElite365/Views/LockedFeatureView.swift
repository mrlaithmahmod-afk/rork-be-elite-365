import SwiftUI

struct LockedFeatureView: View {
    let title: String
    let subtitle: String
    let requiredTier: SubscriptionTier
    let onUpgrade: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "lock.fill")
                .font(.system(size: 28))
                .foregroundStyle(.secondary)

            VStack(spacing: 6) {
                Text(title)
                    .font(.subheadline.weight(.semibold))
                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }

            Button(action: onUpgrade) {
                HStack(spacing: 6) {
                    Image(systemName: "crown")
                        .font(.caption2.weight(.bold))
                    Text("Unlock with \(requiredTier.displayName)")
                        .font(.caption.weight(.semibold))
                }
                .foregroundStyle(.black)
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(AppTheme.gold)
                .clipShape(Capsule())
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(.rect(cornerRadius: 12))
    }
}

struct LockedModuleOverlay: View {
    let requiredTier: SubscriptionTier

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: "lock.fill")
                .font(.system(size: 8))
            Text(requiredTier.displayName)
                .font(.system(size: 9, weight: .bold))
        }
        .foregroundStyle(.black)
        .padding(.horizontal, 6)
        .padding(.vertical, 3)
        .background(AppTheme.gold.opacity(0.9))
        .clipShape(Capsule())
    }
}
