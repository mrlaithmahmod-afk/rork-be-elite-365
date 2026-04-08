import SwiftUI
import SwiftData

struct DailyCheckInView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @State private var confidence: Double = 50
    @State private var mentalPrep: Double = 50
    @State private var practice: Double = 50
    @State private var performance: Double = 50
    @State private var notes: String = ""

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("How are you feeling today?")
                            .font(.headline.weight(.bold))

                        triangleSlider(label: "Confidence", value: $confidence)
                        triangleSlider(label: "Mental Preparation", value: $mentalPrep)
                        triangleSlider(label: "Practice Quality", value: $practice)
                        triangleSlider(label: "Performance Readiness", value: $performance)
                    }

                    VStack(alignment: .leading, spacing: 6) {
                        Text("NOTES")
                            .font(.caption2.weight(.bold))
                            .foregroundStyle(.secondary)
                        TextField("", text: $notes, prompt: Text("Anything on your mind?").foregroundStyle(.white.opacity(0.3)), axis: .vertical)
                            .font(.body)
                            .lineLimit(3...6)
                            .padding(14)
                            .background(Color(.secondarySystemGroupedBackground))
                            .clipShape(.rect(cornerRadius: 10))
                    }
                }
                .padding(.horizontal)
                .padding(.top, 16)
                .padding(.bottom, 24)
            }
            .scrollDismissesKeyboard(.interactively)
            .background(Color(.systemBackground))
            .navigationTitle("Daily Check-In")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveCheckIn()
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

    private func saveCheckIn() {
        let avg = (mentalPrep + practice + performance) / 3.0
        let energy: EnergyLoopState = avg >= 50 ? .positive : .negative
        let checkIn = DailyCheckIn(
            type: .daily,
            mentalPrepRating: mentalPrep,
            practiceRating: practice,
            performanceRating: performance,
            rStage: .reset,
            energyLoop: energy,
            confidenceLevel: confidence,
            notes: notes
        )
        modelContext.insert(checkIn)
    }
}
