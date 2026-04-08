import Foundation

struct PatternInsight: Identifiable, Sendable {
    let id: UUID
    let text: String
    let category: InsightCategory

    init(text: String, category: InsightCategory) {
        self.id = UUID()
        self.text = text
        self.category = category
    }
}

nonisolated enum InsightCategory: String, Sendable {
    case pattern = "Pattern"
    case improvement = "Improvement"
    case adjustment = "Adjustment"
}

struct PatternAnalysisService {
    static func analyze(checkIns: [DailyCheckIn], cards: [SolutionCard]) -> [PatternInsight] {
        var insights: [PatternInsight] = []

        if cards.count >= 2 {
            let resetSkips = cards.filter { $0.skippedR == .reset }.count
            let regroupSkips = cards.filter { $0.skippedR == .regroup }.count
            let refocusSkips = cards.filter { $0.skippedR == .refocus }.count

            let maxSkip = max(resetSkips, regroupSkips, refocusSkips)
            if maxSkip >= 2 {
                if maxSkip == resetSkips {
                    insights.append(PatternInsight(
                        text: "You frequently skip the Reset stage after setbacks. Emotional momentum carries into your next action.",
                        category: .pattern
                    ))
                } else if maxSkip == regroupSkips {
                    insights.append(PatternInsight(
                        text: "You tend to bypass Regroup. Without restoring composure, your refocus lacks direction.",
                        category: .pattern
                    ))
                } else {
                    insights.append(PatternInsight(
                        text: "Refocus is your most skipped stage. You reset and regroup but do not commit to a specific next action.",
                        category: .pattern
                    ))
                }
            }

            let emotionCounts = Dictionary(grouping: cards, by: \.emotionType)
            if let mostCommon = emotionCounts.max(by: { $0.value.count < $1.value.count }),
               mostCommon.value.count >= 2 {
                insights.append(PatternInsight(
                    text: "\(mostCommon.key.rawValue) is your most frequent emotional response. Build specific strategies for this emotion.",
                    category: .adjustment
                ))
            }
        }

        if checkIns.count >= 3 {
            let recent = Array(checkIns.prefix(5))
            let avgConfidence = recent.map(\.confidenceLevel).reduce(0, +) / Double(recent.count)

            if avgConfidence >= 70 {
                insights.append(PatternInsight(
                    text: "Confidence levels are strong. Maintain your current preparation routines.",
                    category: .improvement
                ))
            } else if avgConfidence <= 40 {
                insights.append(PatternInsight(
                    text: "Confidence has been low recently. Stack small controllable wins in training to rebuild.",
                    category: .adjustment
                ))
            }

            let negativeCount = checkIns.prefix(7).filter { $0.energyLoop == .negative }.count
            if negativeCount >= 4 {
                insights.append(PatternInsight(
                    text: "You have been in a negative spiral for the majority of recent sessions. Prioritise a full Reset before your next match.",
                    category: .adjustment
                ))
            }
        }

        if insights.isEmpty {
            insights.append(PatternInsight(
                text: "Continue logging sessions to build enough data for pattern analysis.",
                category: .pattern
            ))
        }

        return insights
    }
}
