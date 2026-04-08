import SwiftUI

struct EliteTrackerView: View {
    @State private var stats: [String: EliteTrackerData.StatValue] = [:]
    @State private var expandedCategories: Set<String> = Set(EliteTrackerData.categories.map(\.id))
    @State private var editingStat: (catID: String, statID: String)?
    @State private var editValue = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 8) {
                Image(systemName: "chart.line.uptrend.xyaxis")
                    .font(.caption)
                    .foregroundStyle(AppTheme.gold)
                Text("ELITE TRACKER")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(.secondary)
                    .tracking(1)
            }

            Text("Track your physical performance stats over time.")
                .font(.caption)
                .foregroundStyle(.secondary)

            ForEach(EliteTrackerData.categories) { category in
                categorySection(category)
            }
        }
        .onAppear {
            stats = EliteTrackerData.loadStats()
        }
        .sheet(item: editingBinding) { item in
            editStatSheet(catID: item.catID, statID: item.statID)
        }
    }

    private var editingBinding: Binding<EditingItem?> {
        Binding(
            get: {
                guard let e = editingStat else { return nil }
                return EditingItem(catID: e.catID, statID: e.statID)
            },
            set: { newValue in
                if let nv = newValue {
                    editingStat = (nv.catID, nv.statID)
                } else {
                    editingStat = nil
                }
            }
        )
    }

    private func categorySection(_ category: TrackerCategory) -> some View {
        VStack(spacing: 0) {
            Button {
                withAnimation(.smooth(duration: 0.2)) {
                    if expandedCategories.contains(category.id) {
                        expandedCategories.remove(category.id)
                    } else {
                        expandedCategories.insert(category.id)
                    }
                }
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: category.icon)
                        .font(.caption)
                        .foregroundStyle(AppTheme.gold)
                    Text(category.title.uppercased())
                        .font(.caption.weight(.bold))
                        .foregroundStyle(.white)
                        .tracking(0.5)
                    Spacer()
                    Image(systemName: expandedCategories.contains(category.id) ? "chevron.up" : "chevron.down")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
                .padding(12)
                .background(Color(.secondarySystemGroupedBackground))
                .clipShape(.rect(cornerRadii: expandedCategories.contains(category.id) ? .init(topLeading: 12, bottomLeading: 0, bottomTrailing: 0, topTrailing: 12) : .init(topLeading: 12, bottomLeading: 12, bottomTrailing: 12, topTrailing: 12)))
            }
            .buttonStyle(.plain)

            if expandedCategories.contains(category.id) {
                VStack(spacing: 1) {
                    ForEach(category.stats) { stat in
                        statRow(stat: stat, catID: category.id)
                    }
                }
                .clipShape(.rect(cornerRadii: .init(bottomLeading: 12, bottomTrailing: 12)))
            }
        }
    }

    private func statRow(stat: TrackerStatConfig, catID: String) -> some View {
        let value = stats[stat.id] ?? EliteTrackerData.StatValue(current: 0, previous: 0, lastUpdated: "-")
        let improved = stat.lowerIsBetter ? value.current < value.previous : value.current > value.previous
        let pctChange: Double = value.previous == 0 ? 0 : ((value.current - value.previous) / value.previous) * 100

        return HStack(spacing: 10) {
            VStack(alignment: .leading, spacing: 4) {
                Text(stat.label)
                    .font(.caption)
                    .foregroundStyle(.primary.opacity(0.85))
                Text("Updated: \(value.lastUpdated)")
                    .font(.system(size: 8))
                    .foregroundStyle(.quaternary)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 2) {
                Text("\(formattedValue(value.current))\(stat.unit)")
                    .font(.subheadline.weight(.bold).monospacedDigit())
                    .foregroundStyle(AppTheme.gold)
                if value.previous != 0 {
                    Text("\(pctChange >= 0 ? "+" : "")\(String(format: "%.1f", pctChange))%")
                        .font(.system(size: 9, weight: .bold))
                        .foregroundStyle(improved ? AppTheme.stable : AppTheme.breakdown)
                }
            }

            Button {
                editValue = formattedValue(value.current)
                editingStat = (catID, stat.id)
            } label: {
                Text("Update")
                    .font(.system(size: 9, weight: .bold))
                    .foregroundStyle(AppTheme.gold)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .overlay(
                        Capsule()
                            .strokeBorder(AppTheme.gold.opacity(0.4), lineWidth: 1)
                    )
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(Color(.secondarySystemGroupedBackground).opacity(0.7))
    }

    private func formattedValue(_ value: Double) -> String {
        if value == value.rounded() {
            return "\(Int(value))"
        }
        return String(format: "%.1f", value)
    }

    private func editStatSheet(catID: String, statID: String) -> some View {
        let statConfig = EliteTrackerData.categories
            .first { $0.id == catID }?
            .stats.first { $0.id == statID }

        return NavigationStack {
            VStack(spacing: 24) {
                VStack(spacing: 8) {
                    Text(statConfig?.label ?? "")
                        .font(.title3.weight(.bold))
                    let current = stats[statID]?.current ?? 0
                    Text("Current: \(formattedValue(current))\(statConfig?.unit ?? "")")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                TextField("", text: $editValue, prompt: Text("Enter new value").foregroundStyle(.white.opacity(0.3)))
                    .font(.title2.weight(.bold).monospacedDigit())
                    .keyboardType(.decimalPad)
                    .multilineTextAlignment(.center)
                    .padding(16)
                    .background(Color(.secondarySystemGroupedBackground))
                    .clipShape(.rect(cornerRadius: 12))

                Spacer()
            }
            .padding()
            .background(Color(.systemBackground))
            .navigationTitle("Update Stat")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { editingStat = nil }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveStat(statID: statID)
                    }
                }
            }
        }
    }

    private func saveStat(statID: String) {
        guard let newVal = Double(editValue) else { return }
        let old = stats[statID]?.current ?? 0
        let dateStr = Date().formatted(date: .abbreviated, time: .omitted)
        stats[statID] = EliteTrackerData.StatValue(current: newVal, previous: old, lastUpdated: dateStr)
        EliteTrackerData.saveStats(stats)
        editingStat = nil
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
    }
}

struct EditingItem: Identifiable {
    let catID: String
    let statID: String
    var id: String { "\(catID)-\(statID)" }
}
