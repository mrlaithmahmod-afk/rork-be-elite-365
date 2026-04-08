import SwiftUI
import SwiftData

struct PreMatchResetView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @State private var step: Int = 0
    @State private var mentalPrep: Double = 60
    @State private var practice: Double = 60
    @State private var performance: Double = 60
    @State private var intention: String = ""

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                Group {
                    switch step {
                    case 0: breathingStep
                    case 1: triangleCheckStep
                    case 2: intentionStep
                    case 3: focusStep
                    default: EmptyView()
                    }
                }
                .frame(maxHeight: .infinity)
                .id(step)
                .transition(.opacity)
                .animation(.smooth(duration: 0.25), value: step)

                HStack(spacing: 16) {
                    if step > 0 {
                        Button("Back") {
                            step -= 1
                        }
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity)
                    }

                    Button {
                        if step < 3 {
                            step += 1
                        } else {
                            saveCheckIn()
                            dismiss()
                        }
                    } label: {
                        Text(step == 3 ? "Ready" : "Continue")
                            .font(.body.weight(.semibold))
                            .foregroundStyle(.black)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(AppTheme.gold)
                            .clipShape(.rect(cornerRadius: 12))
                    }
                    .sensoryFeedback(.impact(weight: .light), trigger: step)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 16)
            }
            .background(Color(.systemBackground))
            .navigationTitle("Pre-Match Reset")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                }
            }
        }
        .presentationDetents([.large])
    }

    private var breathingStep: some View {
        VStack(spacing: 32) {
            Spacer()
            BreathingCircle()
                .frame(height: 200)

            VStack(spacing: 8) {
                Text("Centre yourself")
                    .font(.title3.weight(.bold))
                Text("Breathe in through the nose.\nRelease through the mouth.\nLet the world slow down.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
            Spacer()
        }
        .padding(.horizontal, 24)
    }

    private var triangleCheckStep: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                Text("Quick Triangle Check")
                    .font(.title3.weight(.bold))
                Text("Rate each side of your performance triangle right now.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                triangleSlider(label: "Mental Preparation", value: $mentalPrep)
                triangleSlider(label: "Practice Quality", value: $practice)
                triangleSlider(label: "Performance Readiness", value: $performance)
            }
            .padding(.horizontal, 24)
            .padding(.top, 24)
        }
    }

    private var intentionStep: some View {
        VStack(alignment: .leading, spacing: 24) {
            Text("Set Your Intention")
                .font(.title3.weight(.bold))
            Text("One clear statement for this match. What will you commit to?")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            TextField("", text: $intention, prompt: Text("e.g. Play with authority from the first whistle").foregroundStyle(.white.opacity(0.3)))
                .font(.body)
                .padding(14)
                .background(Color(.secondarySystemGroupedBackground))
                .clipShape(.rect(cornerRadius: 10))

            Spacer()
        }
        .padding(.horizontal, 24)
        .padding(.top, 24)
    }

    private var focusStep: some View {
        VStack(spacing: 32) {
            Spacer()
            Image(systemName: "scope")
                .font(.system(size: 48))
                .foregroundStyle(AppTheme.gold)

            VStack(spacing: 12) {
                Text("Focus Cue")
                    .font(.title3.weight(.bold))
                if !intention.isEmpty {
                    Text("\"\(intention)\"")
                        .font(.subheadline.italic())
                        .foregroundStyle(AppTheme.gold)
                        .multilineTextAlignment(.center)
                }
                Text("Where energy goes, energy flows.\nMaster the mind and the body will follow.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
            Spacer()
        }
        .padding(.horizontal, 24)
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
            type: .preMatch,
            mentalPrepRating: mentalPrep,
            practiceRating: practice,
            performanceRating: performance,
            rStage: .reset,
            energyLoop: energy,
            confidenceLevel: avg,
            notes: intention
        )
        modelContext.insert(checkIn)
    }
}
