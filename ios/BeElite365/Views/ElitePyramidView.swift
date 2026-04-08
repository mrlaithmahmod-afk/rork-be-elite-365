import SwiftUI
import SwiftData

struct ElitePyramidView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var totalDrills: Int = 0
    @State private var selectedLevel: PyramidLevel?

    private var currentLevel: Int {
        ElitePyramid.currentLevel(drillCount: totalDrills)
    }

    private var progressToNext: Double {
        ElitePyramid.progressToNext(drillCount: totalDrills)
    }

    var body: some View {
        VStack(spacing: 20) {
            VStack(spacing: 8) {
                Text("ELITE DEVELOPMENT PYRAMID")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(.secondary)
                    .tracking(1)

                Text("Level \(currentLevel): \(ElitePyramid.levels[currentLevel - 1].name)")
                    .font(.title3.weight(.bold))
                    .foregroundStyle(AppTheme.gold)
            }

            pyramidVisual

            if currentLevel < ElitePyramid.levels.count {
                VStack(spacing: 6) {
                    HStack {
                        Text("Progress to Level \(currentLevel + 1)")
                            .font(.caption2.weight(.semibold))
                            .foregroundStyle(.secondary)
                        Spacer()
                        Text("\(totalDrills)/\(ElitePyramid.levels[currentLevel].requiredDrillCount) drills")
                            .font(.caption2.weight(.bold).monospacedDigit())
                            .foregroundStyle(AppTheme.gold)
                    }

                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            Capsule()
                                .fill(Color.white.opacity(0.08))
                            Capsule()
                                .fill(AppTheme.goldGradient)
                                .frame(width: geo.size.width * progressToNext)
                        }
                    }
                    .frame(height: 6)
                    .clipShape(Capsule())
                }
                .padding(.horizontal, 4)
            }

            if let selected = selectedLevel {
                levelDetail(selected)
            }
        }
        .eliteCard()
        .task {
            let desc = FetchDescriptor<DrillCompletion>()
            totalDrills = (try? modelContext.fetchCount(desc)) ?? 0
        }
    }

    private var pyramidVisual: some View {
        VStack(spacing: 4) {
            ForEach(ElitePyramid.levels.reversed()) { level in
                let isUnlocked = level.id <= currentLevel
                let isCurrent = level.id == currentLevel
                let widthFraction = 0.3 + (Double(level.id) / 5.0) * 0.7

                Button {
                    withAnimation(.smooth(duration: 0.2)) {
                        selectedLevel = selectedLevel?.id == level.id ? nil : level
                    }
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: level.icon)
                            .font(.caption2.weight(.semibold))
                            .foregroundStyle(isCurrent ? .black : isUnlocked ? AppTheme.gold : .secondary)
                            .frame(width: 16)

                        Text(level.name.uppercased())
                            .font(.system(size: 10, weight: .bold))
                            .foregroundStyle(isCurrent ? .black : isUnlocked ? .white : .secondary)
                            .tracking(0.5)

                        Spacer()

                        if isCurrent {
                            Circle()
                                .fill(.black.opacity(0.3))
                                .frame(width: 6, height: 6)
                        }
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 10)
                    .frame(maxWidth: .infinity)
                    .background(
                        isCurrent ? AppTheme.gold :
                        isUnlocked ? Color.white.opacity(0.06) :
                        Color.white.opacity(0.02)
                    )
                    .clipShape(.rect(cornerRadius: 6))
                    .overlay(
                        RoundedRectangle(cornerRadius: 6)
                            .strokeBorder(
                                isCurrent ? Color.clear :
                                isUnlocked ? AppTheme.gold.opacity(0.3) :
                                Color.white.opacity(0.06),
                                lineWidth: 1
                            )
                    )
                }
                .buttonStyle(.plain)
                .frame(width: UIScreen.main.bounds.width * widthFraction * 0.7)
            }
        }
    }

    private func levelDetail(_ level: PyramidLevel) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(level.description)
                .font(.caption)
                .foregroundStyle(.secondary)

            VStack(alignment: .leading, spacing: 6) {
                Text("SKILLS")
                    .font(.caption2.weight(.bold))
                    .foregroundStyle(.secondary)
                ForEach(level.skills, id: \.self) { skill in
                    HStack(spacing: 8) {
                        Circle()
                            .fill(level.id <= currentLevel ? AppTheme.gold : Color.white.opacity(0.15))
                            .frame(width: 4, height: 4)
                        Text(skill)
                            .font(.caption)
                            .foregroundStyle(level.id <= currentLevel ? .primary : .secondary)
                    }
                }
            }

            if level.id > currentLevel {
                Text("Complete \(level.requiredDrillCount) drills to unlock")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .transition(.opacity.combined(with: .move(edge: .top)))
    }
}
