import SwiftUI
import SwiftData

struct SelfTalkBuilderView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @State private var buildStep: SelfTalkStep = .notice
    @State private var selectedNotice: String = ""
    @State private var selectedMeaning: String = ""
    @State private var selectedAction: String = ""
    @State private var customNotice: String = ""
    @State private var effectiveness: Int = 3

    private let noticeOptions = [
        "I notice frustration building",
        "I notice doubt creeping in",
        "I notice my focus drifting",
        "I notice anxiety about the match",
        "I notice anger after that decision",
        "I notice fear of making a mistake",
        "I notice pressure from the coach",
        "I notice my confidence dropping"
    ]

    private let meaningOptions = [
        "This is a signal, not a command",
        "This feeling will pass in seconds",
        "My body is preparing to compete",
        "I have been here before and recovered",
        "This does not define my performance",
        "I can choose what happens next"
    ]

    private let actionOptions = [
        "My next action is a simple, clean pass",
        "My next action is to hold my position",
        "My next action is to win the next ball",
        "My next action is to communicate clearly",
        "My next action is to sprint to recover",
        "My next action is one controlled breath"
    ]

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                switch buildStep {
                case .notice: noticeView
                case .meaning: meaningView
                case .action: actionStepView
                case .complete: completionView
                }
            }
            .background(Color(.systemBackground))
            .navigationTitle("Self-Talk Builder")
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

    private var noticeView: some View {
        ScrollView {
            VStack(spacing: 24) {
                VStack(spacing: 12) {
                    Image(systemName: "text.bubble")
                        .font(.system(size: 40))
                        .foregroundStyle(Color(red: 0.85, green: 0.35, blue: 0.30))

                    Text("I Notice...")
                        .font(.title2.weight(.bold))

                    Text("Build a personal self-talk script you can use in matches. Start by naming what you notice.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 16)
                }
                .padding(.top, 8)

                stepIndicator(current: 1)

                VStack(spacing: 8) {
                    ForEach(noticeOptions, id: \.self) { option in
                        Button {
                            selectedNotice = option
                            withAnimation { buildStep = .meaning }
                        } label: {
                            HStack {
                                Text(option)
                                    .font(.subheadline)
                                    .foregroundStyle(.primary)
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .font(.caption2)
                                    .foregroundStyle(.tertiary)
                            }
                            .padding(14)
                            .background(Color(.secondarySystemGroupedBackground))
                            .clipShape(.rect(cornerRadius: 12))
                        }
                        .buttonStyle(.plain)
                    }
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text("OR WRITE YOUR OWN")
                        .font(.caption2.weight(.bold))
                        .foregroundStyle(.secondary)

                    HStack(spacing: 10) {
                        TextField("", text: $customNotice, prompt: Text("I notice...").foregroundStyle(.white.opacity(0.3)))
                            .font(.subheadline)
                            .padding(12)
                            .background(Color(.secondarySystemGroupedBackground))
                            .clipShape(.rect(cornerRadius: 10))

                        Button {
                            selectedNotice = customNotice
                            withAnimation { buildStep = .meaning }
                        } label: {
                            Image(systemName: "arrow.right.circle.fill")
                                .font(.title2)
                                .foregroundStyle(customNotice.isEmpty ? .secondary : AppTheme.gold)
                        }
                        .disabled(customNotice.trimmingCharacters(in: .whitespaces).isEmpty)
                    }
                }
            }
            .padding(.horizontal)
            .padding(.bottom, 24)
        }
    }

    private var meaningView: some View {
        ScrollView {
            VStack(spacing: 24) {
                VStack(spacing: 12) {
                    Image(systemName: "arrow.triangle.merge")
                        .font(.system(size: 40))
                        .foregroundStyle(Color(red: 0.30, green: 0.55, blue: 0.85))

                    Text("This Means...")
                        .font(.title2.weight(.bold))

                    Text("Reframe the feeling. What does this moment actually mean?")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 8)

                stepIndicator(current: 2)

                VStack(alignment: .leading, spacing: 4) {
                    Text("YOUR NOTICE")
                        .font(.caption2.weight(.bold))
                        .foregroundStyle(.secondary)
                    Text(selectedNotice)
                        .font(.caption)
                        .foregroundStyle(Color(red: 0.85, green: 0.35, blue: 0.30))
                        .padding(10)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color(red: 0.85, green: 0.35, blue: 0.30).opacity(0.08))
                        .clipShape(.rect(cornerRadius: 8))
                }

                VStack(spacing: 8) {
                    ForEach(meaningOptions, id: \.self) { option in
                        Button {
                            selectedMeaning = option
                            withAnimation { buildStep = .action }
                        } label: {
                            HStack {
                                Text(option)
                                    .font(.subheadline)
                                    .foregroundStyle(.primary)
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .font(.caption2)
                                    .foregroundStyle(.tertiary)
                            }
                            .padding(14)
                            .background(Color(.secondarySystemGroupedBackground))
                            .clipShape(.rect(cornerRadius: 12))
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .padding(.horizontal)
            .padding(.bottom, 24)
        }
    }

    private var actionStepView: some View {
        ScrollView {
            VStack(spacing: 24) {
                VStack(spacing: 12) {
                    Image(systemName: "scope")
                        .font(.system(size: 40))
                        .foregroundStyle(Color(red: 0.25, green: 0.75, blue: 0.40))

                    Text("My Next Action Is...")
                        .font(.title2.weight(.bold))

                    Text("Commit to one specific, controllable action.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 8)

                stepIndicator(current: 3)

                VStack(spacing: 8) {
                    ForEach(actionOptions, id: \.self) { option in
                        Button {
                            selectedAction = option
                            withAnimation { buildStep = .complete }
                        } label: {
                            HStack {
                                Text(option)
                                    .font(.subheadline)
                                    .foregroundStyle(.primary)
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .font(.caption2)
                                    .foregroundStyle(.tertiary)
                            }
                            .padding(14)
                            .background(Color(.secondarySystemGroupedBackground))
                            .clipShape(.rect(cornerRadius: 12))
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .padding(.horizontal)
            .padding(.bottom, 24)
        }
    }

    private var completionView: some View {
        VStack(spacing: 28) {
            Spacer()

            VStack(spacing: 12) {
                Image(systemName: "text.quote")
                    .font(.system(size: 44))
                    .foregroundStyle(AppTheme.gold)

                Text("Your Self-Talk Script")
                    .font(.title2.weight(.bold))
            }

            VStack(alignment: .leading, spacing: 12) {
                scriptCard(label: "NOTICE", text: selectedNotice, color: Color(red: 0.85, green: 0.35, blue: 0.30))
                scriptCard(label: "MEANING", text: selectedMeaning, color: Color(red: 0.30, green: 0.55, blue: 0.85))
                scriptCard(label: "ACTION", text: selectedAction, color: Color(red: 0.25, green: 0.75, blue: 0.40))
            }
            .padding(.horizontal, 24)

            Text("Rehearse this script 3 times now. In the moment, it will run automatically.")
                .font(.caption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)

            VStack(spacing: 12) {
                Text("How useful is this script?")
                    .font(.caption.weight(.semibold))
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
                    drillID: "self-talk-builder",
                    effectiveness: effectiveness
                )
                modelContext.insert(completion)
                dismiss()
            } label: {
                Text("Save Script")
                    .font(.body.weight(.semibold))
                    .foregroundStyle(.black)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(AppTheme.gold)
                    .clipShape(.rect(cornerRadius: 12))
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 16)
            .sensoryFeedback(.success, trigger: effectiveness)
        }
    }

    private func scriptCard(label: String, text: String, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label)
                .font(.caption2.weight(.black))
                .foregroundStyle(color)
                .tracking(1)
            Text(text)
                .font(.subheadline)
                .foregroundStyle(.primary.opacity(0.85))
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.secondarySystemGroupedBackground))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .strokeBorder(color.opacity(0.2), lineWidth: 1)
                )
        )
    }

    private func stepIndicator(current: Int) -> some View {
        HStack(spacing: 8) {
            ForEach(1...3, id: \.self) { step in
                HStack(spacing: 4) {
                    Circle()
                        .fill(step <= current ? AppTheme.gold : Color.white.opacity(0.1))
                        .frame(width: 8, height: 8)
                    if step < 3 {
                        Rectangle()
                            .fill(step < current ? AppTheme.gold : Color.white.opacity(0.1))
                            .frame(width: 30, height: 2)
                    }
                }
            }
        }
    }
}

nonisolated enum SelfTalkStep: Sendable {
    case notice, meaning, action, complete
}
