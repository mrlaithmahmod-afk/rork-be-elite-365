import SwiftUI
import SwiftData

struct PostMatchReviewView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @State private var overallRating: Double = 5
    @State private var mentalPrep: Double = 60
    @State private var practice: Double = 60
    @State private var performance: Double = 60
    @State private var bestMoment: String = ""
    @State private var worstMoment: String = ""
    @State private var usedR: RStage = .reset
    @State private var keyLearning: String = ""

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Overall Performance")
                            .font(.headline.weight(.bold))

                        HStack {
                            Text("\(Int(overallRating))")
                                .font(.system(size: 48, weight: .bold))
                                .foregroundStyle(AppTheme.gold)
                                .contentTransition(.numericText())
                                .animation(.snappy, value: overallRating)
                            Text("/10")
                                .font(.title3)
                                .foregroundStyle(.secondary)
                        }

                        Slider(value: $overallRating, in: 1...10, step: 1)
                            .tint(AppTheme.gold)
                    }

                    VStack(alignment: .leading, spacing: 16) {
                        Text("Triangle Assessment")
                            .font(.headline.weight(.bold))
                        triangleSlider(label: "Mental Preparation", value: $mentalPrep)
                        triangleSlider(label: "Practice Quality", value: $practice)
                        triangleSlider(label: "Match Performance", value: $performance)
                    }

                    VStack(alignment: .leading, spacing: 12) {
                        Text("Match Moments")
                            .font(.headline.weight(.bold))

                        textField(label: "BEST MOMENT", text: $bestMoment, prompt: "What went well?")
                        textField(label: "MOST DIFFICULT MOMENT", text: $worstMoment, prompt: "What challenged you?")
                    }

                    VStack(alignment: .leading, spacing: 12) {
                        Text("Which R was most useful?")
                            .font(.headline.weight(.bold))

                        HStack(spacing: 10) {
                            ForEach(RStage.allCases) { stage in
                                Button {
                                    usedR = stage
                                } label: {
                                    VStack(spacing: 4) {
                                        Image(systemName: stage.icon)
                                            .font(.title3)
                                        Text(stage.rawValue)
                                            .font(.caption2.weight(.semibold))
                                    }
                                    .foregroundStyle(usedR == stage ? .black : .white)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 14)
                                    .background(usedR == stage ? AppTheme.gold : Color(.secondarySystemGroupedBackground))
                                    .clipShape(.rect(cornerRadius: 10))
                                }
                            }
                        }
                    }

                    textField(label: "KEY LEARNING", text: $keyLearning, prompt: "One thing to carry forward")
                }
                .padding(.horizontal)
                .padding(.bottom, 24)
            }
            .scrollDismissesKeyboard(.interactively)
            .background(Color(.systemBackground))
            .navigationTitle("Post-Match Review")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveReview()
                        dismiss()
                    }
                    .fontWeight(.semibold)
                    .foregroundStyle(AppTheme.gold)
                }
            }
        }
        .presentationDetents([.large])
    }

    private func triangleSlider(label: String, value: Binding<Double>) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(label)
                    .font(.subheadline.weight(.medium))
                Spacer()
                Text("\(Int(value.wrappedValue))")
                    .font(.subheadline.weight(.bold).monospacedDigit())
                    .foregroundStyle(AppTheme.stabilityColor(for: value.wrappedValue))
            }
            Slider(value: value, in: 0...100, step: 5)
                .tint(AppTheme.stabilityColor(for: value.wrappedValue))
        }
    }

    private func textField(label: String, text: Binding<String>, prompt: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label)
                .font(.caption2.weight(.bold))
                .foregroundStyle(.secondary)
            TextField("", text: text, prompt: Text(prompt).foregroundStyle(.white.opacity(0.3)))
                .font(.body)
                .padding(14)
                .background(Color(.secondarySystemGroupedBackground))
                .clipShape(.rect(cornerRadius: 10))
        }
    }

    private func saveReview() {
        let avg = (mentalPrep + practice + performance) / 3.0
        let energy: EnergyLoopState = avg >= 50 ? .positive : .negative
        let notes = [bestMoment, worstMoment, keyLearning].filter { !$0.isEmpty }.joined(separator: " | ")

        let checkIn = DailyCheckIn(
            type: .postMatch,
            mentalPrepRating: mentalPrep,
            practiceRating: practice,
            performanceRating: performance,
            rStage: usedR,
            energyLoop: energy,
            confidenceLevel: overallRating * 10,
            notes: notes
        )
        modelContext.insert(checkIn)
    }
}
