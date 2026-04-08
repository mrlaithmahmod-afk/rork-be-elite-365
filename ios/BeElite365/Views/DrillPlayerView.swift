import SwiftUI
import SwiftData

struct DrillPlayerView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    let drill: Drill
    @State private var currentStepIndex: Int = 0
    @State private var isComplete = false
    @State private var effectiveness: Int = 3

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                if isComplete {
                    completionView
                } else {
                    drillContent
                }
            }
            .background(Color(.systemBackground))
            .navigationTitle(drill.name)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                        .foregroundStyle(.secondary)
                }
            }
        }
        .presentationDetents([.large])
    }

    private var drillContent: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    HStack(spacing: 12) {
                        Label(drill.duration, systemImage: "clock")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(AppTheme.gold)
                        Label(drill.rStage.rawValue, systemImage: drill.rStage.icon)
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(AppTheme.gold)
                    }

                    VStack(alignment: .leading, spacing: 16) {
                        ForEach(Array(drill.steps.enumerated()), id: \.offset) { index, step in
                            HStack(alignment: .top, spacing: 12) {
                                ZStack {
                                    Circle()
                                        .fill(index <= currentStepIndex ? AppTheme.gold : Color(.tertiarySystemGroupedBackground))
                                        .frame(width: 28, height: 28)
                                    if index < currentStepIndex {
                                        Image(systemName: "checkmark")
                                            .font(.caption2.weight(.bold))
                                            .foregroundStyle(.black)
                                    } else {
                                        Text("\(index + 1)")
                                            .font(.caption2.weight(.bold))
                                            .foregroundStyle(index <= currentStepIndex ? .black : .secondary)
                                    }
                                }

                                Text(step)
                                    .font(.subheadline)
                                    .foregroundStyle(index <= currentStepIndex ? .primary : .secondary)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(.top, 4)
                            }
                        }
                    }

                    VStack(alignment: .leading, spacing: 6) {
                        Text("WHY IT WORKS")
                            .font(.caption2.weight(.bold))
                            .foregroundStyle(AppTheme.gold)
                        Text(drill.whyItWorks)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .lineSpacing(2)
                    }
                    .eliteCard()
                }
                .padding(.horizontal, 24)
                .padding(.top, 20)
            }

            HStack(spacing: 16) {
                if currentStepIndex > 0 {
                    Button {
                        currentStepIndex -= 1
                    } label: {
                        Text("Back")
                            .font(.body.weight(.medium))
                            .foregroundStyle(.secondary)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                    }
                }

                Button {
                    if currentStepIndex < drill.steps.count - 1 {
                        withAnimation(.smooth(duration: 0.2)) {
                            currentStepIndex += 1
                        }
                    } else {
                        withAnimation(.smooth(duration: 0.3)) {
                            isComplete = true
                        }
                    }
                } label: {
                    Text(currentStepIndex == drill.steps.count - 1 ? "Complete" : "Next Step")
                        .font(.body.weight(.semibold))
                        .foregroundStyle(.black)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(AppTheme.gold)
                        .clipShape(.rect(cornerRadius: 12))
                }
                .sensoryFeedback(.impact(weight: .light), trigger: currentStepIndex)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 16)
        }
    }

    private var completionView: some View {
        VStack(spacing: 32) {
            Spacer()

            VStack(spacing: 12) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 56))
                    .foregroundStyle(AppTheme.stable)

                Text("Drill Complete")
                    .font(.title2.weight(.bold))
            }

            VStack(spacing: 12) {
                Text("How effective was this?")
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(.secondary)

                HStack(spacing: 8) {
                    ForEach(1...5, id: \.self) { value in
                        Button {
                            effectiveness = value
                        } label: {
                            Text("\(value)")
                                .font(.subheadline.weight(.bold))
                                .foregroundStyle(value <= effectiveness ? .black : .white)
                                .frame(width: 44, height: 44)
                                .background(value <= effectiveness ? AppTheme.gold : Color(.secondarySystemGroupedBackground))
                                .clipShape(Circle())
                        }
                    }
                }
            }

            Spacer()

            Button {
                let completion = DrillCompletion(
                    drillID: drill.id,
                    effectiveness: effectiveness
                )
                modelContext.insert(completion)
                dismiss()
            } label: {
                Text("Done")
                    .font(.body.weight(.semibold))
                    .foregroundStyle(.black)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(AppTheme.gold)
                    .clipShape(.rect(cornerRadius: 12))
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 16)
            .sensoryFeedback(.success, trigger: isComplete)
        }
    }
}
