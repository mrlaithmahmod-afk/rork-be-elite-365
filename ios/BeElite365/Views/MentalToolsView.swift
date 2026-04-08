import SwiftUI

struct MentalToolsView: View {
    @State private var selectedRStage: RStage?
    @State private var expandedToolID: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 8) {
                Image(systemName: "wrench.and.screwdriver")
                    .font(.caption)
                    .foregroundStyle(AppTheme.gold)
                Text("MENTAL TOOLS")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(.secondary)
                    .tracking(1)
            }

            Text("Quick-access tools for pressure moments. Categorised by the 3Rs.")
                .font(.caption)
                .foregroundStyle(.secondary)

            HStack(spacing: 8) {
                toolFilterChip(label: "All", isSelected: selectedRStage == nil) {
                    selectedRStage = nil
                }
                ForEach(RStage.allCases) { stage in
                    toolFilterChip(label: stage.rawValue, isSelected: selectedRStage == stage) {
                        selectedRStage = stage
                    }
                }
            }

            ForEach(filteredTools) { tool in
                Button {
                    withAnimation(.smooth(duration: 0.2)) {
                        expandedToolID = expandedToolID == tool.id ? nil : tool.id
                    }
                } label: {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack(spacing: 10) {
                            Image(systemName: tool.rStage.icon)
                                .font(.caption)
                                .foregroundStyle(colorForStage(tool.rStage))
                                .frame(width: 20)

                            VStack(alignment: .leading, spacing: 2) {
                                Text(tool.name)
                                    .font(.subheadline.weight(.semibold))
                                    .foregroundStyle(.primary)
                                HStack(spacing: 6) {
                                    Text(tool.rStage.rawValue)
                                        .font(.caption2.weight(.bold))
                                        .foregroundStyle(colorForStage(tool.rStage))
                                    Text(tool.duration)
                                        .font(.caption2)
                                        .foregroundStyle(.secondary)
                                }
                            }

                            Spacer()

                            Image(systemName: expandedToolID == tool.id ? "chevron.up" : "chevron.down")
                                .font(.caption2)
                                .foregroundStyle(.tertiary)
                        }

                        if expandedToolID == tool.id {
                            VStack(alignment: .leading, spacing: 10) {
                                Text(tool.description)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)

                                VStack(alignment: .leading, spacing: 6) {
                                    ForEach(Array(tool.steps.enumerated()), id: \.offset) { index, step in
                                        HStack(alignment: .top, spacing: 8) {
                                            Text("\(index + 1)")
                                                .font(.caption2.weight(.bold).monospacedDigit())
                                                .foregroundStyle(colorForStage(tool.rStage))
                                                .frame(width: 16)
                                            Text(step)
                                                .font(.caption)
                                                .foregroundStyle(.primary.opacity(0.8))
                                        }
                                    }
                                }

                                HStack(spacing: 4) {
                                    Image(systemName: "clock")
                                        .font(.system(size: 9))
                                    Text(tool.whenToUse)
                                        .font(.caption2)
                                }
                                .foregroundStyle(.secondary)
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

    private var filteredTools: [MentalTool] {
        if let stage = selectedRStage {
            return MentalToolsLibrary.tools(for: stage)
        }
        return MentalToolsLibrary.tools
    }

    private func colorForStage(_ stage: RStage) -> Color {
        switch stage {
        case .reset: Color(red: 0.85, green: 0.35, blue: 0.30)
        case .regroup: Color(red: 0.30, green: 0.55, blue: 0.85)
        case .refocus: Color(red: 0.25, green: 0.75, blue: 0.40)
        }
    }

    private func toolFilterChip(label: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
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
