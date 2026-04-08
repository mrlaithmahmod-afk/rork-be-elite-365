import SwiftUI

struct PositionPickerView: View {
    @Binding var selectedPosition: FootballPosition?

    var body: some View {
        VStack(spacing: 16) {
            pitchView
                .frame(height: 400)
                .clipShape(.rect(cornerRadius: 16))

            if let pos = selectedPosition {
                HStack(spacing: 8) {
                    Text("Selected:")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text(pos.displayName)
                        .font(.caption.weight(.bold))
                        .foregroundStyle(AppTheme.gold)
                    Text("(\(pos.rawValue))")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)
                }
            }
        }
    }

    private var pitchView: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height

            ZStack {
                pitchBackground(width: w, height: h)

                ForEach(PitchLayout.positions) { slot in
                    let isSelected = selectedPosition == slot.position
                    Button {
                        withAnimation(.snappy(duration: 0.2)) {
                            selectedPosition = slot.position
                        }
                    } label: {
                        VStack(spacing: 3) {
                            Circle()
                                .fill(isSelected ? AppTheme.gold : Color.white.opacity(0.85))
                                .frame(width: isSelected ? 36 : 28, height: isSelected ? 36 : 28)
                                .overlay {
                                    Text(slot.position.rawValue)
                                        .font(.system(size: isSelected ? 11 : 9, weight: .heavy))
                                        .foregroundStyle(isSelected ? .black : Color(red: 0.15, green: 0.35, blue: 0.15))
                                }
                                .shadow(color: .black.opacity(0.3), radius: 4, y: 2)
                        }
                    }
                    .position(x: slot.x * w, y: slot.y * h)
                    .sensoryFeedback(.selection, trigger: selectedPosition)
                }
            }
        }
    }

    private func pitchBackground(width: CGFloat, height: CGFloat) -> some View {
        Canvas { context, size in
            let w = size.width
            let h = size.height

            let lineColor = Color.white.opacity(0.25)
            let lineWidth: CGFloat = 1.2

            for i in stride(from: 0, to: h, by: h / 8) {
                let stripColor = i.truncatingRemainder(dividingBy: h / 4) < h / 8
                    ? Color(red: 0.20, green: 0.44, blue: 0.20)
                    : Color(red: 0.17, green: 0.40, blue: 0.17)
                context.fill(
                    Path(CGRect(x: 0, y: i, width: w, height: h / 8)),
                    with: .color(stripColor)
                )
            }

            var borderPath = Path()
            borderPath.addRect(CGRect(x: 8, y: 8, width: w - 16, height: h - 16))
            context.stroke(borderPath, with: .color(lineColor), lineWidth: lineWidth)

            var halfLine = Path()
            halfLine.move(to: CGPoint(x: 8, y: h / 2))
            halfLine.addLine(to: CGPoint(x: w - 8, y: h / 2))
            context.stroke(halfLine, with: .color(lineColor), lineWidth: lineWidth)

            var centreCircle = Path()
            centreCircle.addEllipse(in: CGRect(x: w / 2 - 40, y: h / 2 - 40, width: 80, height: 80))
            context.stroke(centreCircle, with: .color(lineColor), lineWidth: lineWidth)

            let penaltyW: CGFloat = w * 0.5
            let penaltyH: CGFloat = h * 0.14
            var topPenalty = Path()
            topPenalty.addRect(CGRect(x: (w - penaltyW) / 2, y: 8, width: penaltyW, height: penaltyH))
            context.stroke(topPenalty, with: .color(lineColor), lineWidth: lineWidth)

            var bottomPenalty = Path()
            bottomPenalty.addRect(CGRect(x: (w - penaltyW) / 2, y: h - 8 - penaltyH, width: penaltyW, height: penaltyH))
            context.stroke(bottomPenalty, with: .color(lineColor), lineWidth: lineWidth)

            let goalW: CGFloat = w * 0.2
            let goalH: CGFloat = h * 0.04
            var topGoal = Path()
            topGoal.addRect(CGRect(x: (w - goalW) / 2, y: 8 - goalH / 2, width: goalW, height: goalH))
            context.stroke(topGoal, with: .color(lineColor), lineWidth: lineWidth)

            var bottomGoal = Path()
            bottomGoal.addRect(CGRect(x: (w - goalW) / 2, y: h - 8 - goalH / 2, width: goalW, height: goalH))
            context.stroke(bottomGoal, with: .color(lineColor), lineWidth: lineWidth)
        }
    }
}
