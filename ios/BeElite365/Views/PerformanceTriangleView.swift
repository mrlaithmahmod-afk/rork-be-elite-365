import SwiftUI

struct PerformanceTriangleView: View {
    let mentalPrep: Double
    let practice: Double
    let performance: Double
    var energyLoop: EnergyLoopState = .neutral

    private var weakestSide: TriangleSide {
        let sides: [(TriangleSide, Double)] = [
            (.mentalPreparation, mentalPrep),
            (.practice, practice),
            (.performance, performance)
        ]
        return sides.min(by: { $0.1 < $1.1 })?.0 ?? .mentalPreparation
    }

    private var weakestScore: Double {
        min(mentalPrep, practice, performance)
    }

    var body: some View {
        VStack(spacing: 12) {
            Canvas { context, size in
                drawTriangle(context: context, size: size)
            }
            .frame(height: 240)

            HStack(spacing: 16) {
                triangleLegend(label: "Mental Prep", score: mentalPrep)
                triangleLegend(label: "Practice", score: practice)
                triangleLegend(label: "Performance", score: performance)
            }

            if weakestScore < 50 {
                HStack(spacing: 6) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.system(size: 9))
                        .foregroundStyle(AppTheme.weakening)
                    Text("Weak side: \(weakestSide.shortName)")
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundStyle(AppTheme.weakening)
                    Text("\(Int(weakestScore))")
                        .font(.system(size: 10, weight: .bold, design: .monospaced))
                        .foregroundStyle(AppTheme.stabilityColor(for: weakestScore))
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(AppTheme.weakening.opacity(0.08))
                .clipShape(Capsule())
            }

            energyFlowIndicator
        }
        .padding(16)
        .background(Color.black)
        .clipShape(.rect(cornerRadius: 16))
    }

    @ViewBuilder
    private var energyFlowIndicator: some View {
        if energyLoop != .neutral {
            HStack(spacing: 6) {
                Image(systemName: energyLoop == .positive ? "arrow.up.right" : "arrow.down.right")
                    .font(.system(size: 9, weight: .bold))
                Text(energyLoop == .positive ? "Positive Energy Flow" : "Negative Energy Spiral")
                    .font(.system(size: 9, weight: .bold))
                    .tracking(0.5)
            }
            .foregroundStyle(energyLoop == .positive ? AppTheme.stable : AppTheme.breakdown)
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background((energyLoop == .positive ? AppTheme.stable : AppTheme.breakdown).opacity(0.08))
            .clipShape(Capsule())
        }
    }

    private func triangleLegend(label: String, score: Double) -> some View {
        VStack(spacing: 4) {
            Text("\(Int(score))")
                .font(.system(size: 18, weight: .bold, design: .monospaced))
                .foregroundStyle(AppTheme.stabilityColor(for: score))
            Text(label)
                .font(.system(size: 9, weight: .semibold))
                .foregroundStyle(.white.opacity(0.6))
            Text(AppTheme.stabilityLabel(for: score))
                .font(.system(size: 8, weight: .bold))
                .foregroundStyle(AppTheme.stabilityColor(for: score))
        }
        .frame(maxWidth: .infinity)
    }

    private func drawTriangle(context: GraphicsContext, size: CGSize) {
        let center = CGPoint(x: size.width / 2, y: size.height / 2 + 8)
        let radius = min(size.width, size.height) / 2 - 28

        let goldColor = AppTheme.gold

        let top = pointOnCircle(center: center, radius: radius, angleDeg: -90)
        let bottomLeft = pointOnCircle(center: center, radius: radius, angleDeg: 150)
        let bottomRight = pointOnCircle(center: center, radius: radius, angleDeg: 30)

        for i in stride(from: 0.3, through: 1.0, by: 0.35) {
            let r = radius * i
            let t = pointOnCircle(center: center, radius: r, angleDeg: -90)
            let bl = pointOnCircle(center: center, radius: r, angleDeg: 150)
            let br = pointOnCircle(center: center, radius: r, angleDeg: 30)
            var gridPath = Path()
            gridPath.move(to: t)
            gridPath.addLine(to: br)
            gridPath.addLine(to: bl)
            gridPath.closeSubpath()
            context.stroke(gridPath, with: .color(.white.opacity(0.06)), lineWidth: 0.5)
        }

        var outerPath = Path()
        outerPath.move(to: top)
        outerPath.addLine(to: bottomRight)
        outerPath.addLine(to: bottomLeft)
        outerPath.closeSubpath()
        context.stroke(outerPath, with: .color(goldColor.opacity(0.4)), lineWidth: 1.5)

        let perfNorm = performance / 100.0
        let mentalNorm = mentalPrep / 100.0
        let practiceNorm = practice / 100.0

        let dataTop = lerp(center, top, t: perfNorm)
        let dataLeft = lerp(center, bottomLeft, t: mentalNorm)
        let dataRight = lerp(center, bottomRight, t: practiceNorm)

        var dataPath = Path()
        dataPath.move(to: dataTop)
        dataPath.addLine(to: dataRight)
        dataPath.addLine(to: dataLeft)
        dataPath.closeSubpath()

        let avgScore = (mentalPrep + practice + performance) / 3.0
        let fillColor = AppTheme.stabilityColor(for: avgScore)

        context.fill(dataPath, with: .color(fillColor.opacity(0.2)))
        context.stroke(dataPath, with: .color(fillColor.opacity(0.8)), lineWidth: 2)

        let dotSize: CGFloat = 7
        for pt in [dataTop, dataLeft, dataRight] {
            let rect = CGRect(x: pt.x - dotSize / 2, y: pt.y - dotSize / 2, width: dotSize, height: dotSize)
            context.fill(Path(ellipseIn: rect.insetBy(dx: -2, dy: -2)), with: .color(fillColor.opacity(0.3)))
            context.fill(Path(ellipseIn: rect), with: .color(fillColor))
        }

        let labelSize: CGFloat = 10
        let labelWeight: Font.Weight = .heavy

        let perfLabel = Text("PERFORMANCE")
            .font(.system(size: labelSize, weight: labelWeight))
            .foregroundColor(AppTheme.stabilityColor(for: performance))
        context.draw(context.resolve(perfLabel), at: CGPoint(x: top.x, y: top.y - 14))

        let mentalLabel = Text("MENTAL PREP")
            .font(.system(size: labelSize, weight: labelWeight))
            .foregroundColor(AppTheme.stabilityColor(for: mentalPrep))
        context.draw(context.resolve(mentalLabel), at: CGPoint(x: bottomLeft.x - 4, y: bottomLeft.y + 14))

        let practiceLabel = Text("PRACTICE")
            .font(.system(size: labelSize, weight: labelWeight))
            .foregroundColor(AppTheme.stabilityColor(for: practice))
        context.draw(context.resolve(practiceLabel), at: CGPoint(x: bottomRight.x + 4, y: bottomRight.y + 14))

        let scores: [(CGPoint, Double)] = [
            (midpoint(top, center), performance),
            (midpoint(bottomRight, center), practice),
            (midpoint(bottomLeft, center), mentalPrep)
        ]
        for (pt, score) in scores {
            let color = AppTheme.stabilityColor(for: score)
            let scoreText = Text("\(Int(score))")
                .font(.system(size: 12, weight: .bold, design: .monospaced))
                .foregroundColor(color)
            context.draw(context.resolve(scoreText), at: pt)
        }
    }

    private func pointOnCircle(center: CGPoint, radius: CGFloat, angleDeg: CGFloat) -> CGPoint {
        let rad = angleDeg * .pi / 180
        return CGPoint(x: center.x + radius * cos(rad), y: center.y + radius * sin(rad))
    }

    private func midpoint(_ a: CGPoint, _ b: CGPoint) -> CGPoint {
        CGPoint(x: (a.x + b.x) / 2, y: (a.y + b.y) / 2)
    }

    private func lerp(_ a: CGPoint, _ b: CGPoint, t: Double) -> CGPoint {
        CGPoint(
            x: a.x + (b.x - a.x) * t,
            y: a.y + (b.y - a.y) * t
        )
    }
}
