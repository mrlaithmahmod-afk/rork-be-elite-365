import SwiftUI
import SwiftData

struct LevelPickerSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    let profile: PlayerProfile?
    let onChanged: () -> Void

    var body: some View {
        NavigationStack {
            List {
                Section {
                    Text("Your level determines your coaching style, available features, and recommended subscription.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .listRowBackground(Color.clear)
                }

                Section("Select Your Level") {
                    ForEach(PlayingLevel.allCases) { level in
                        let isSelected = profile?.level == level
                        Button {
                            profile?.level = level
                            profile?.updatedAt = Date()
                            onChanged()
                            dismiss()
                        } label: {
                            HStack(spacing: 14) {
                                Image(systemName: levelIcon(level))
                                    .font(.title3)
                                    .foregroundStyle(isSelected ? AppTheme.gold : .secondary)
                                    .frame(width: 28)

                                VStack(alignment: .leading, spacing: 4) {
                                    Text(level.rawValue)
                                        .font(.subheadline.weight(.semibold))
                                        .foregroundStyle(isSelected ? AppTheme.gold : .primary)
                                    Text(levelDescription(level))
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                        .lineLimit(2)
                                }

                                Spacer()

                                if isSelected {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundStyle(AppTheme.gold)
                                }
                            }
                        }
                        .foregroundStyle(.primary)
                    }
                }

                Section {
                    HStack(spacing: 12) {
                        Image(systemName: "arrow.triangle.2.circlepath")
                            .foregroundStyle(AppTheme.gold)
                        Text("Changing your level will adapt your coaching, drills, insights, and recommended plan.")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .navigationTitle("Playing Level")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                }
            }
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

    private func levelDescription(_ level: PlayingLevel) -> String {
        switch level {
        case .grassroots:
            "Sunday league, school, park football. Focus on confidence and nerves."
        case .academy:
            "Club academy or development squad. Pressure under evaluation."
        case .semiPro:
            "Semi-professional or non-league. Consistency and discipline."
        case .professional:
            "Professional contract. Elite maintenance and pressure control."
        }
    }
}
