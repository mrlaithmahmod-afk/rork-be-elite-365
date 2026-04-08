import SwiftUI
import SwiftData

struct PostGameDebriefView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @State private var screen: Int = 0
    @State private var selectedWellTags: Set<String> = []
    @State private var wellFreeText: String = ""
    @State private var selectedChallengeTags: Set<String> = []
    @State private var challengeFreeText: String = ""
    @State private var selfMessage: String = ""
    @State private var saved: Bool = false

    let match: MatchEvent?

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                HStack(spacing: 4) {
                    ForEach(0..<3, id: \.self) { i in
                        Capsule()
                            .fill(i <= screen ? AppTheme.gold : Color.white.opacity(0.08))
                            .frame(height: 3)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 8)

                Group {
                    switch screen {
                    case 0: wentWellScreen
                    case 1: challengedScreen
                    case 2: selfMessageScreen
                    default: EmptyView()
                    }
                }
                .frame(maxHeight: .infinity)
                .id(screen)
                .transition(.asymmetric(
                    insertion: .move(edge: .trailing).combined(with: .opacity),
                    removal: .move(edge: .leading).combined(with: .opacity)
                ))
                .animation(.smooth(duration: 0.3), value: screen)

                HStack(spacing: 16) {
                    if screen > 0 {
                        Button("Back") {
                            screen -= 1
                        }
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity)
                    }

                    Button {
                        if screen < 2 {
                            screen += 1
                        } else {
                            saveDebrief()
                        }
                    } label: {
                        Text(screen == 2 ? "Save Debrief" : "Continue")
                            .font(.body.weight(.semibold))
                            .foregroundStyle(.black)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(AppTheme.gold)
                            .clipShape(.rect(cornerRadius: 12))
                    }
                    .sensoryFeedback(.impact(weight: .light), trigger: screen)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 16)
            }
            .background(Color(.systemBackground))
            .navigationTitle("Post-Game Debrief")
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

    private var wentWellScreen: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("What went well mentally today?")
                        .font(.title3.weight(.bold))
                    Text("Select all that apply, or write your own.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                FlowLayout(spacing: 8) {
                    ForEach(DebriefTagLibrary.wentWellTags, id: \.self) { tag in
                        Button {
                            toggleTag(tag, in: &selectedWellTags)
                        } label: {
                            Text(tag)
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(selectedWellTags.contains(tag) ? .black : .primary)
                                .padding(.horizontal, 14)
                                .padding(.vertical, 10)
                                .background(selectedWellTags.contains(tag) ? AppTheme.gold : Color(.secondarySystemGroupedBackground))
                                .clipShape(Capsule())
                        }
                    }
                }

                VStack(alignment: .leading, spacing: 6) {
                    Text("ANYTHING ELSE?")
                        .font(.caption2.weight(.bold))
                        .foregroundStyle(.secondary)
                    TextField("", text: $wellFreeText, prompt: Text("Write your own...").foregroundStyle(.white.opacity(0.3)))
                        .font(.body)
                        .padding(14)
                        .background(Color(.secondarySystemGroupedBackground))
                        .clipShape(.rect(cornerRadius: 10))
                }
            }
            .padding(.horizontal, 24)
            .padding(.top, 20)
            .padding(.bottom, 24)
        }
        .scrollDismissesKeyboard(.interactively)
    }

    private var challengedScreen: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("What challenged you mentally?")
                        .font(.title3.weight(.bold))
                    Text("Be honest. This stays between us.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                FlowLayout(spacing: 8) {
                    ForEach(DebriefTagLibrary.challengedTags, id: \.self) { tag in
                        Button {
                            toggleTag(tag, in: &selectedChallengeTags)
                        } label: {
                            Text(tag)
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(selectedChallengeTags.contains(tag) ? .black : .primary)
                                .padding(.horizontal, 14)
                                .padding(.vertical, 10)
                                .background(selectedChallengeTags.contains(tag) ? AppTheme.gold : Color(.secondarySystemGroupedBackground))
                                .clipShape(Capsule())
                        }
                    }
                }

                VStack(alignment: .leading, spacing: 6) {
                    Text("ANYTHING ELSE?")
                        .font(.caption2.weight(.bold))
                        .foregroundStyle(.secondary)
                    TextField("", text: $challengeFreeText, prompt: Text("Write your own...").foregroundStyle(.white.opacity(0.3)))
                        .font(.body)
                        .padding(14)
                        .background(Color(.secondarySystemGroupedBackground))
                        .clipShape(.rect(cornerRadius: 10))
                }
            }
            .padding(.horizontal, 24)
            .padding(.top, 20)
            .padding(.bottom, 24)
        }
        .scrollDismissesKeyboard(.interactively)
    }

    private var selfMessageScreen: some View {
        VStack(spacing: 32) {
            Spacer()

            VStack(spacing: 12) {
                Image(systemName: "envelope.open")
                    .font(.system(size: 40))
                    .foregroundStyle(AppTheme.gold)

                Text("What would you tell yourself\nbefore the next match?")
                    .font(.title3.weight(.bold))
                    .multilineTextAlignment(.center)

                Text("One sentence. This will be shown to you\nnext time you do Match Day Lock-In.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }

            TextField("", text: $selfMessage, prompt: Text("e.g. Trust yourself from the first whistle").foregroundStyle(.white.opacity(0.3)))
                .font(.body.weight(.medium))
                .multilineTextAlignment(.center)
                .padding(16)
                .background(Color(.secondarySystemGroupedBackground))
                .clipShape(.rect(cornerRadius: 12))
                .padding(.horizontal, 24)

            Spacer()
        }
    }

    private func toggleTag(_ tag: String, in set: inout Set<String>) {
        if set.contains(tag) {
            set.remove(tag)
        } else {
            set.insert(tag)
        }
    }

    private func saveDebrief() {
        let debrief = PostGameDebrief(
            matchEventID: match?.id,
            wentWellTags: Array(selectedWellTags),
            wentWellFreeText: wellFreeText,
            challengedTags: Array(selectedChallengeTags),
            challengedFreeText: challengeFreeText,
            selfMessageForNextMatch: selfMessage
        )
        modelContext.insert(debrief)

        if let match {
            match.postMatchCompleted = true
        }

        saved = true
        dismiss()
    }
}

struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = layout(proposal: proposal, subviews: subviews)
        return result.size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = layout(proposal: proposal, subviews: subviews)
        for (index, position) in result.positions.enumerated() {
            subviews[index].place(at: CGPoint(x: bounds.minX + position.x, y: bounds.minY + position.y), proposal: .unspecified)
        }
    }

    private func layout(proposal: ProposedViewSize, subviews: Subviews) -> (size: CGSize, positions: [CGPoint]) {
        let maxWidth = proposal.width ?? .infinity
        var positions: [CGPoint] = []
        var currentX: CGFloat = 0
        var currentY: CGFloat = 0
        var lineHeight: CGFloat = 0
        var maxX: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if currentX + size.width > maxWidth, currentX > 0 {
                currentX = 0
                currentY += lineHeight + spacing
                lineHeight = 0
            }
            positions.append(CGPoint(x: currentX, y: currentY))
            lineHeight = max(lineHeight, size.height)
            currentX += size.width + spacing
            maxX = max(maxX, currentX)
        }

        return (CGSize(width: maxX, height: currentY + lineHeight), positions)
    }
}
