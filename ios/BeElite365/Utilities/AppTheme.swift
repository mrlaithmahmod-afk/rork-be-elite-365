import SwiftUI

struct AppTheme {
    static let gold = Color(red: 0.85, green: 0.68, blue: 0.22)
    static let goldLight = Color(red: 0.95, green: 0.82, blue: 0.40)
    static let goldDark = Color(red: 0.68, green: 0.53, blue: 0.12)

    static let goldGradient = LinearGradient(
        colors: [goldLight, gold],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let stable = Color(red: 0.20, green: 0.78, blue: 0.35)
    static let weakening = Color(red: 0.95, green: 0.77, blue: 0.06)
    static let breakdown = Color(red: 0.90, green: 0.22, blue: 0.21)

    static func stabilityColor(for score: Double) -> Color {
        if score >= 65 { return stable }
        if score >= 35 { return weakening }
        return breakdown
    }

    static func stabilityLabel(for score: Double) -> String {
        if score >= 65 { return "Stable" }
        if score >= 35 { return "Weakening" }
        return "Breakdown"
    }
}

struct EliteCardModifier: ViewModifier {
    var padding: CGFloat = 16

    func body(content: Content) -> some View {
        content
            .padding(padding)
            .background(Color(.secondarySystemGroupedBackground))
            .clipShape(.rect(cornerRadius: 12))
    }
}

extension View {
    func eliteCard(padding: CGFloat = 16) -> some View {
        modifier(EliteCardModifier(padding: padding))
    }
}
