import SwiftUI

struct ConfidenceIndicatorView: View {
    let state: ConfidenceState
    let onRecoveryTap: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 8) {
                Text("CONFIDENCE STABILITY")
                    .font(.caption2.weight(.bold))
                    .foregroundStyle(.secondary)
                Spacer()
                HStack(spacing: 4) {
                    Image(systemName: state.icon)
                        .font(.caption2.weight(.semibold))
                    Text(state.rawValue.uppercased())
                        .font(.caption2.weight(.bold))
                        .tracking(0.5)
                }
                .foregroundStyle(stateColor)
            }

            Text(state.recoveryPrompt)
                .font(.caption)
                .foregroundStyle(.secondary)

            if state == .spiral || state == .dip {
                Button(action: onRecoveryTap) {
                    HStack(spacing: 6) {
                        Image(systemName: "arrow.counterclockwise")
                            .font(.caption2.weight(.semibold))
                        Text("Start Recovery")
                            .font(.caption.weight(.semibold))
                    }
                    .foregroundStyle(.black)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(AppTheme.gold)
                    .clipShape(Capsule())
                }
            }
        }
        .eliteCard()
    }

    private var stateColor: Color {
        switch state {
        case .stable: AppTheme.stable
        case .recovering: AppTheme.weakening
        case .dip: AppTheme.weakening
        case .spiral: AppTheme.breakdown
        }
    }
}
