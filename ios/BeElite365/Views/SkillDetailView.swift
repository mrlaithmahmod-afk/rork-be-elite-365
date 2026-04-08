import SwiftUI

struct SkillDetailView: View {
    let skill: MentalSkill

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                VStack(alignment: .leading, spacing: 12) {
                    HStack(spacing: 8) {
                        Image(systemName: skill.rStage.icon)
                            .font(.title2)
                            .foregroundStyle(AppTheme.gold)
                        VStack(alignment: .leading, spacing: 2) {
                            Text(skill.rStage.rawValue)
                                .font(.caption.weight(.bold))
                                .foregroundStyle(AppTheme.gold)
                            Text(skill.triangleSide.shortName)
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }
                    }

                    Text(skill.skillDescription)
                        .font(.body)
                        .foregroundStyle(.secondary)
                }

                skillSection(
                    label: "DAILY DRILL",
                    icon: "calendar",
                    content: skill.dailyDrill
                )

                skillSection(
                    label: "MATCH-DAY VERSION",
                    icon: "sportscourt",
                    content: skill.matchDayVersion
                )

                skillSection(
                    label: "WHY IT MATTERS",
                    icon: "lightbulb",
                    content: skill.whyItMatters
                )

                HStack(spacing: 8) {
                    principleTag(skill.principle.rawValue)
                    principleTag(skill.triangleSide.shortName)
                    principleTag(skill.rStage.rawValue)
                }
            }
            .padding(.horizontal)
            .padding(.bottom, 32)
        }
        .background(Color(.systemBackground))
        .navigationTitle(skill.name)
        .navigationBarTitleDisplayMode(.large)
    }

    private func skillSection(label: String, icon: String, content: String) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.caption)
                    .foregroundStyle(AppTheme.gold)
                Text(label)
                    .font(.caption.weight(.bold))
                    .foregroundStyle(AppTheme.gold)
            }
            Text(content)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .eliteCard()
    }

    private func principleTag(_ text: String) -> some View {
        Text(text)
            .font(.caption2.weight(.semibold))
            .foregroundStyle(.secondary)
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(Color(.tertiarySystemGroupedBackground))
            .clipShape(Capsule())
    }
}
