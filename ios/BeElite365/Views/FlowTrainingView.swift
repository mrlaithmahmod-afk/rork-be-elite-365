import SwiftUI

struct FlowTrainingView: View {
    @State private var selectedCategory: FlowCategory?
    @State private var selectedDrill: FlowDrill?

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 8) {
                Image(systemName: "wind")
                    .font(.caption)
                    .foregroundStyle(AppTheme.gold)
                Text("FLOW TRAINING")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(.secondary)
                    .tracking(1)
            }

            Text("Train your ability to enter and sustain flow state during matches and training.")
                .font(.caption)
                .foregroundStyle(.secondary)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    flowCategoryChip(label: "All", isSelected: selectedCategory == nil) {
                        selectedCategory = nil
                    }
                    ForEach(FlowCategory.allCases) { cat in
                        flowCategoryChip(label: cat.rawValue, isSelected: selectedCategory == cat) {
                            selectedCategory = cat
                        }
                    }
                }
            }

            ForEach(filteredDrills) { drill in
                Button {
                    withAnimation(.smooth(duration: 0.2)) {
                        selectedDrill = selectedDrill?.id == drill.id ? nil : drill
                    }
                } label: {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(drill.name)
                                    .font(.subheadline.weight(.semibold))
                                    .foregroundStyle(.primary)
                                Text(drill.description)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                    .lineLimit(selectedDrill?.id == drill.id ? nil : 2)
                            }
                            Spacer()
                            Text(drill.duration)
                                .font(.caption2.weight(.bold))
                                .foregroundStyle(AppTheme.gold)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(AppTheme.gold.opacity(0.12))
                                .clipShape(Capsule())
                        }

                        if selectedDrill?.id == drill.id {
                            VStack(alignment: .leading, spacing: 6) {
                                ForEach(Array(drill.steps.enumerated()), id: \.offset) { index, step in
                                    HStack(alignment: .top, spacing: 8) {
                                        Text("\(index + 1)")
                                            .font(.caption2.weight(.bold).monospacedDigit())
                                            .foregroundStyle(AppTheme.gold)
                                            .frame(width: 16)
                                        Text(step)
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                    }
                                }
                            }
                            .padding(.top, 4)
                            .transition(.opacity)
                        }
                    }
                    .padding(14)
                    .background(Color(.secondarySystemGroupedBackground))
                    .clipShape(.rect(cornerRadius: 12))
                }
                .buttonStyle(.plain)
            }
        }
    }

    private var filteredDrills: [FlowDrill] {
        if let cat = selectedCategory {
            return FlowLibrary.drills(for: cat)
        }
        return FlowLibrary.drills
    }

    private func flowCategoryChip(label: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(label)
                .font(.caption2.weight(.semibold))
                .foregroundStyle(isSelected ? .black : .white)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(isSelected ? AppTheme.gold : Color(.secondarySystemGroupedBackground))
                .clipShape(Capsule())
        }
    }
}
