import Foundation

nonisolated struct PlaybookLoader: Sendable {
    static func load() -> MentalPlaybook? {
        guard let url = Bundle.main.url(forResource: "mental_playbook", withExtension: "json"),
              let data = try? Data(contentsOf: url) else {
            return nil
        }
        return try? JSONDecoder().decode(MentalPlaybook.self, from: data)
    }

    static func condensed(_ playbook: MentalPlaybook) -> String {
        var lines: [String] = []
        lines.append("PRINCIPLES: \(playbook.principles.joined(separator: " "))")
        lines.append("3Rs: \(playbook.frameworks.threeRs.joined(separator: " "))")
        lines.append("TRIANGLE: \(playbook.frameworks.performanceTriangle.joined(separator: ", "))")
        lines.append("SELF-TALK SYSTEM: Label the feeling. Reframe it. Redirect to action.")
        lines.append("RESET TECHNIQUES: \(playbook.resetTechniques.joined(separator: " "))")
        lines.append("REGROUP TECHNIQUES: \(playbook.regroupTechniques.joined(separator: " "))")
        lines.append("REFOCUS TECHNIQUES: \(playbook.refocusTechniques.joined(separator: " "))")
        return lines.joined(separator: "\n")
    }
}
