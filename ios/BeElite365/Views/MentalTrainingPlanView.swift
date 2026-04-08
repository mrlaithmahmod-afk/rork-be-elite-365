import SwiftUI
import SwiftData

struct MentalTrainingPlanView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var weeklyGoal: String = ""
    @State private var savedGoal: String = ""
    @State private var showGoalInput = false

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 8) {
                    Image(systemName: "calendar.badge.clock")
                        .font(.caption)
                        .foregroundStyle(AppTheme.gold)
                    Text("MENTAL TRAINING PLAN")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(.secondary)
                        .tracking(1)
                }

                Text("Structure your mental development across the week.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            if !savedGoal.isEmpty {
                VStack(alignment: .leading, spacing: 6) {
                    Text("WEEKLY GOAL")
                        .font(.caption2.weight(.bold))
                        .foregroundStyle(.secondary)
                    Text(savedGoal)
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(AppTheme.gold)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(14)
                .background(AppTheme.gold.opacity(0.06))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .strokeBorder(AppTheme.gold.opacity(0.2), lineWidth: 1)
                )
                .clipShape(.rect(cornerRadius: 12))
            }

            Button {
                showGoalInput.toggle()
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: savedGoal.isEmpty ? "plus.circle" : "pencil.circle")
                        .font(.caption)
                    Text(savedGoal.isEmpty ? "Set Weekly Goal" : "Update Goal")
                        .font(.caption.weight(.semibold))
                }
                .foregroundStyle(AppTheme.gold)
            }

            if showGoalInput {
                VStack(alignment: .leading, spacing: 8) {
                    TextField("", text: $weeklyGoal, prompt: Text("e.g. Improve my reset speed after mistakes").foregroundStyle(.white.opacity(0.3)))
                        .font(.subheadline)
                        .padding(12)
                        .background(Color(.secondarySystemGroupedBackground))
                        .clipShape(.rect(cornerRadius: 10))

                    Button {
                        savedGoal = weeklyGoal
                        UserDefaults.standard.set(savedGoal, forKey: "weeklyMentalGoal")
                        showGoalInput = false
                    } label: {
                        Text("Save Goal")
                            .font(.caption.weight(.bold))
                            .foregroundStyle(.black)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 8)
                            .background(AppTheme.gold)
                            .clipShape(Capsule())
                    }
                    .disabled(weeklyGoal.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }

            VStack(alignment: .leading, spacing: 12) {
                Text("SUGGESTED WEEKLY STRUCTURE")
                    .font(.caption2.weight(.bold))
                    .foregroundStyle(.secondary)

                ForEach(WeeklyPlan.days, id: \.day) { plan in
                    HStack(alignment: .top, spacing: 12) {
                        Text(plan.day)
                            .font(.caption2.weight(.bold))
                            .foregroundStyle(AppTheme.gold)
                            .frame(width: 36, alignment: .leading)

                        VStack(alignment: .leading, spacing: 2) {
                            Text(plan.focus)
                                .font(.caption.weight(.semibold))
                            Text(plan.activity)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .padding(10)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color(.secondarySystemGroupedBackground))
                    .clipShape(.rect(cornerRadius: 8))
                }
            }
        }
        .onAppear {
            savedGoal = UserDefaults.standard.string(forKey: "weeklyMentalGoal") ?? ""
        }
    }
}

struct WeeklyPlanDay: Sendable {
    let day: String
    let focus: String
    let activity: String
}

struct WeeklyPlan {
    static let days: [WeeklyPlanDay] = [
        WeeklyPlanDay(day: "MON", focus: "Reset Training", activity: "Breathing reset + body scan drill"),
        WeeklyPlanDay(day: "TUE", focus: "Focus Lock", activity: "Attention switching drill during training"),
        WeeklyPlanDay(day: "WED", focus: "Confidence Build", activity: "Evidence log + process goal setting"),
        WeeklyPlanDay(day: "THU", focus: "Pressure Prep", activity: "Simulated pressure drill + composure anchor"),
        WeeklyPlanDay(day: "FRI", focus: "Pre-Match", activity: "Visualisation + intention setting"),
        WeeklyPlanDay(day: "SAT", focus: "Match Day", activity: "Pre-match routine + post-match review"),
        WeeklyPlanDay(day: "SUN", focus: "Recovery", activity: "Values check + weekly reflection"),
    ]
}
