import SwiftUI
import SwiftData

struct GoalsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \GoalItem.createdAt, order: .reverse) private var allGoals: [GoalItem]
    @State private var selectedCategory: GoalCategory = .mental
    @State private var showAddGoal = false
    @State private var newGoalText = ""
    @State private var newCurrentValue = ""
    @State private var newTargetValue = ""
    @State private var newUnit = ""

    private var activeGoals: [GoalItem] {
        allGoals.filter { !$0.isCompleted && $0.category == selectedCategory }
    }

    private var completedGoals: [GoalItem] {
        allGoals.filter { $0.isCompleted && $0.category == selectedCategory }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 8) {
                    Image(systemName: "target")
                        .font(.caption)
                        .foregroundStyle(AppTheme.gold)
                    Text("GOALS")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(.secondary)
                        .tracking(1)
                }

                Text("Set development targets across mental, technical, physical, and lifestyle areas.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            categoryTabs

            if activeGoals.isEmpty && completedGoals.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: selectedCategory.icon)
                        .font(.title2)
                        .foregroundStyle(.secondary)
                    Text("No \(selectedCategory.rawValue.lowercased()) goals yet")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 24)
            }

            ForEach(activeGoals) { goal in
                goalCard(goal)
            }

            if !completedGoals.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("COMPLETED (\(completedGoals.count))")
                        .font(.caption2.weight(.bold))
                        .foregroundStyle(.secondary)

                    ForEach(completedGoals.prefix(3)) { goal in
                        completedGoalRow(goal)
                    }
                }
            }

            Button {
                showAddGoal = true
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: "plus.circle")
                        .font(.caption)
                    Text("Add Goal")
                        .font(.caption.weight(.semibold))
                }
                .foregroundStyle(AppTheme.gold)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(AppTheme.gold.opacity(0.06))
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .strokeBorder(AppTheme.gold.opacity(0.3), lineWidth: 1)
                )
                .clipShape(.rect(cornerRadius: 10))
            }
        }
        .sheet(isPresented: $showAddGoal) {
            addGoalSheet
        }
    }

    private var categoryTabs: some View {
        HStack(spacing: 6) {
            ForEach(GoalCategory.allCases) { cat in
                Button {
                    withAnimation(.smooth(duration: 0.2)) {
                        selectedCategory = cat
                    }
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: cat.icon)
                            .font(.system(size: 9))
                        Text(cat.rawValue)
                            .font(.caption2.weight(.semibold))
                    }
                    .foregroundStyle(selectedCategory == cat ? .black : .white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(selectedCategory == cat ? AppTheme.gold : Color(.secondarySystemGroupedBackground))
                    .clipShape(Capsule())
                }
            }
        }
    }

    private func goalCard(_ goal: GoalItem) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 8) {
                Image(systemName: goal.category.icon)
                    .font(.caption)
                    .foregroundStyle(AppTheme.gold)
                VStack(alignment: .leading, spacing: 2) {
                    Text(goal.text)
                        .font(.subheadline.weight(.semibold))
                    Text(goal.source)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
                Spacer()
            }

            HStack {
                Text("\(Int(goal.currentValue)) \(goal.unit)")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                Spacer()
                Text("\(Int(goal.targetValue)) \(goal.unit)")
                    .font(.caption2.weight(.bold))
                    .foregroundStyle(AppTheme.gold)
            }

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color.white.opacity(0.06))
                    Capsule()
                        .fill(goal.progress >= 1.0 ? AppTheme.stable : AppTheme.gold)
                        .frame(width: geo.size.width * goal.progress)
                }
            }
            .frame(height: 5)
            .clipShape(Capsule())

            HStack {
                Text("\(Int(goal.progress * 100))% complete")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                Spacer()
                Button {
                    completeGoal(goal)
                } label: {
                    Text("Complete")
                        .font(.caption2.weight(.bold))
                        .foregroundStyle(AppTheme.gold)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(AppTheme.gold.opacity(0.1))
                        .clipShape(Capsule())
                }
            }
        }
        .padding(14)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(.rect(cornerRadius: 12))
    }

    private func completedGoalRow(_ goal: GoalItem) -> some View {
        HStack(spacing: 8) {
            Image(systemName: "checkmark.circle.fill")
                .font(.caption)
                .foregroundStyle(AppTheme.stable)
            Text(goal.text)
                .font(.caption)
                .foregroundStyle(.secondary)
                .strikethrough()
            Spacer()
            if let date = goal.completedAt {
                Text(date.formatted(date: .abbreviated, time: .omitted))
                    .font(.caption2)
                    .foregroundStyle(.quaternary)
            }
        }
        .padding(10)
        .background(Color(.secondarySystemGroupedBackground).opacity(0.5))
        .clipShape(.rect(cornerRadius: 8))
    }

    private func completeGoal(_ goal: GoalItem) {
        goal.isCompleted = true
        goal.completedAt = Date()
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
    }

    private var addGoalSheet: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("CATEGORY")
                            .font(.caption2.weight(.bold))
                            .foregroundStyle(.secondary)
                        HStack(spacing: 8) {
                            ForEach(GoalCategory.allCases) { cat in
                                Button {
                                    selectedCategory = cat
                                } label: {
                                    Text(cat.rawValue)
                                        .font(.caption2.weight(.semibold))
                                        .foregroundStyle(selectedCategory == cat ? .black : .white)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 8)
                                        .background(selectedCategory == cat ? AppTheme.gold : Color(.secondarySystemGroupedBackground))
                                        .clipShape(Capsule())
                                }
                            }
                        }
                    }

                    VStack(alignment: .leading, spacing: 6) {
                        Text("GOAL")
                            .font(.caption2.weight(.bold))
                            .foregroundStyle(.secondary)
                        TextField("", text: $newGoalText, prompt: Text("e.g. Improve reset speed after mistakes").foregroundStyle(.white.opacity(0.3)))
                            .font(.subheadline)
                            .padding(12)
                            .background(Color(.secondarySystemGroupedBackground))
                            .clipShape(.rect(cornerRadius: 10))
                    }

                    HStack(spacing: 12) {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("CURRENT")
                                .font(.caption2.weight(.bold))
                                .foregroundStyle(.secondary)
                            TextField("", text: $newCurrentValue, prompt: Text("0").foregroundStyle(.white.opacity(0.3)))
                                .font(.subheadline)
                                .keyboardType(.decimalPad)
                                .padding(12)
                                .background(Color(.secondarySystemGroupedBackground))
                                .clipShape(.rect(cornerRadius: 10))
                        }
                        VStack(alignment: .leading, spacing: 6) {
                            Text("TARGET")
                                .font(.caption2.weight(.bold))
                                .foregroundStyle(.secondary)
                            TextField("", text: $newTargetValue, prompt: Text("100").foregroundStyle(.white.opacity(0.3)))
                                .font(.subheadline)
                                .keyboardType(.decimalPad)
                                .padding(12)
                                .background(Color(.secondarySystemGroupedBackground))
                                .clipShape(.rect(cornerRadius: 10))
                        }
                    }

                    VStack(alignment: .leading, spacing: 6) {
                        Text("UNIT")
                            .font(.caption2.weight(.bold))
                            .foregroundStyle(.secondary)
                        TextField("", text: $newUnit, prompt: Text("e.g. %, km/h, score").foregroundStyle(.white.opacity(0.3)))
                            .font(.subheadline)
                            .padding(12)
                            .background(Color(.secondarySystemGroupedBackground))
                            .clipShape(.rect(cornerRadius: 10))
                    }
                }
                .padding()
            }
            .background(Color(.systemBackground))
            .navigationTitle("Add Goal")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        resetForm()
                        showAddGoal = false
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveGoal()
                    }
                    .disabled(newGoalText.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
    }

    private func saveGoal() {
        let goal = GoalItem(
            text: newGoalText.trimmingCharacters(in: .whitespaces),
            category: selectedCategory,
            currentValue: Double(newCurrentValue) ?? 0,
            targetValue: Double(newTargetValue) ?? 100,
            unit: newUnit.trimmingCharacters(in: .whitespaces).isEmpty ? "%" : newUnit.trimmingCharacters(in: .whitespaces),
            source: "Custom Goal"
        )
        modelContext.insert(goal)
        resetForm()
        showAddGoal = false
    }

    private func resetForm() {
        newGoalText = ""
        newCurrentValue = ""
        newTargetValue = ""
        newUnit = ""
    }
}
