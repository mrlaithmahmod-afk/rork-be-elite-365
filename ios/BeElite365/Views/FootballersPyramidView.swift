import SwiftUI

struct FootballersPyramidView: View {
    @State private var slots: [String: String?] = FootballersPyramidData.defaultSlots()
    @State private var selectedPrinciple: String?
    @State private var saved = false

    private var placedIDs: Set<String> {
        Set(slots.values.compactMap { $0 })
    }

    private var placedCount: Int { placedIDs.count }
    private let totalSlots = 7

    var body: some View {
        VStack(spacing: 20) {
            header

            pyramidVisual

            progressIndicator

            principlesList

            actionButtons
        }
        .onAppear {
            slots = FootballersPyramidData.loadSlots()
        }
    }

    private var header: some View {
        VStack(spacing: 6) {
            HStack(spacing: 8) {
                Image(systemName: "triangle")
                    .font(.caption)
                    .foregroundStyle(AppTheme.gold)
                Text("THE FOOTBALLER'S PYRAMID")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(.secondary)
                    .tracking(1)
            }

            Text("Build your personal philosophy. Place 7 principles across the pyramid to define what drives your career.")
                .font(.caption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
    }

    private var pyramidVisual: some View {
        VStack(spacing: 6) {
            tierLabel("THE PEAK")
            HStack(spacing: 8) {
                slotView(key: "peak-0")
            }
            .frame(maxWidth: 100)

            tierLabel("THE GROWTH ENGINE")
            HStack(spacing: 8) {
                slotView(key: "growth-0")
                slotView(key: "growth-1")
            }
            .frame(maxWidth: 200)

            tierLabel("THE FOUNDATION")
            HStack(spacing: 8) {
                slotView(key: "foundation-0")
                slotView(key: "foundation-1")
                slotView(key: "foundation-2")
                slotView(key: "foundation-3")
            }
        }
    }

    private func tierLabel(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 9, weight: .bold))
            .foregroundStyle(.secondary)
            .tracking(2)
            .padding(.top, 4)
    }

    private func slotView(key: String) -> some View {
        let principleID = slots[key] ?? nil
        let principle = principleID.flatMap { FootballersPyramidData.principle(for: $0) }
        let canPlace = principle == nil && selectedPrinciple != nil

        return Button {
            handleSlotTap(key: key)
        } label: {
            VStack(spacing: 4) {
                if let principle {
                    Text(principle.name.uppercased())
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(.white)
                        .tracking(0.5)
                        .lineLimit(1)
                    Text("tap to remove")
                        .font(.system(size: 7))
                        .foregroundStyle(.secondary)
                } else {
                    Text(canPlace ? "Place here" : "Empty")
                        .font(.system(size: 9))
                        .foregroundStyle(canPlace ? AppTheme.gold : Color.secondary.opacity(0.4))
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 60)
            .background(
                principle != nil ? AppTheme.gold.opacity(0.08) : Color.white.opacity(0.02)
            )
            .clipShape(.rect(cornerRadius: 8))
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .strokeBorder(
                        canPlace ? AppTheme.gold.opacity(0.6) :
                        principle != nil ? AppTheme.gold.opacity(0.4) :
                        Color.white.opacity(0.06),
                        style: canPlace ? StrokeStyle(lineWidth: 1.5, dash: [4, 3]) : StrokeStyle(lineWidth: 1)
                    )
            )
        }
        .buttonStyle(.plain)
    }

    private var progressIndicator: some View {
        HStack(spacing: 4) {
            Text("\(placedCount)")
                .font(.subheadline.weight(.bold))
                .foregroundStyle(AppTheme.gold)
            Text("/ \(totalSlots) principles placed")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }

    private var principlesList: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("CORE PRINCIPLES")
                .font(.caption2.weight(.bold))
                .foregroundStyle(.secondary)

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 6) {
                ForEach(FootballersPyramidData.principles) { principle in
                    let isPlaced = placedIDs.contains(principle.id)
                    let isSelected = selectedPrinciple == principle.id

                    Button {
                        guard !isPlaced else { return }
                        withAnimation(.smooth(duration: 0.2)) {
                            selectedPrinciple = selectedPrinciple == principle.id ? nil : principle.id
                        }
                    } label: {
                        HStack(spacing: 8) {
                            Circle()
                                .fill(isPlaced ? AppTheme.stable : isSelected ? AppTheme.gold : Color.white.opacity(0.1))
                                .frame(width: 16, height: 16)
                                .overlay {
                                    if isPlaced {
                                        Image(systemName: "checkmark")
                                            .font(.system(size: 8, weight: .bold))
                                            .foregroundStyle(.white)
                                    }
                                }

                            VStack(alignment: .leading, spacing: 1) {
                                Text(principle.name)
                                    .font(.caption.weight(.semibold))
                                    .foregroundStyle(isPlaced ? .secondary : .primary)
                                Text(principle.description)
                                    .font(.system(size: 8))
                                    .foregroundStyle(.secondary)
                                    .lineLimit(1)
                            }
                        }
                        .padding(8)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(
                            isSelected ? AppTheme.gold.opacity(0.08) : Color(.secondarySystemGroupedBackground)
                        )
                        .clipShape(.rect(cornerRadius: 8))
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .strokeBorder(
                                    isSelected ? AppTheme.gold.opacity(0.5) : Color.clear,
                                    lineWidth: 1
                                )
                        )
                        .opacity(isPlaced ? 0.5 : 1)
                    }
                    .buttonStyle(.plain)
                    .disabled(isPlaced)
                }
            }
        }
    }

    private var actionButtons: some View {
        VStack(spacing: 10) {
            Button {
                handleSave()
            } label: {
                Text(saved ? "Saved" : "Save My Pyramid")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(.black)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(saved ? AppTheme.stable : AppTheme.gold)
                    .clipShape(.rect(cornerRadius: 10))
            }
            .disabled(placedCount < totalSlots)
            .opacity(placedCount < totalSlots ? 0.4 : 1)

            Button {
                handleReset()
            } label: {
                Text("Reset All")
                    .font(.caption2.weight(.bold))
                    .foregroundStyle(.secondary)
            }
        }
    }

    private func handleSlotTap(key: String) {
        let current = slots[key] ?? nil
        if current != nil {
            withAnimation(.smooth(duration: 0.2)) {
                slots[key] = nil
            }
            return
        }
        guard let selected = selectedPrinciple else { return }
        withAnimation(.smooth(duration: 0.2)) {
            slots[key] = selected
            selectedPrinciple = nil
        }
    }

    private func handleSave() {
        FootballersPyramidData.saveSlots(slots)
        saved = true
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            saved = false
        }
    }

    private func handleReset() {
        withAnimation(.smooth(duration: 0.2)) {
            slots = FootballersPyramidData.defaultSlots()
            selectedPrinciple = nil
            saved = false
        }
    }
}
