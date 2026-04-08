import Foundation

nonisolated struct MentalPlaybook: Codable, Sendable {
    let principles: [String]
    let frameworks: PlaybookFrameworks
    let selfTalkSystem: SelfTalkSystem
    let resetTechniques: [String]
    let regroupTechniques: [String]
    let refocusTechniques: [String]

    enum CodingKeys: String, CodingKey {
        case principles
        case frameworks
        case selfTalkSystem = "self_talk_system"
        case resetTechniques = "reset_techniques"
        case regroupTechniques = "regroup_techniques"
        case refocusTechniques = "refocus_techniques"
    }
}

nonisolated struct PlaybookFrameworks: Codable, Sendable {
    let threeRs: [String]
    let performanceTriangle: [String]
    let cognitiveAppraisal: [String]

    enum CodingKeys: String, CodingKey {
        case threeRs = "three_rs"
        case performanceTriangle = "performance_triangle"
        case cognitiveAppraisal = "cognitive_appraisal"
    }
}

nonisolated struct SelfTalkSystem: Codable, Sendable {
    let label: String
    let reframe: String
    let redirect: String
    let examples: [SelfTalkExample]
}

nonisolated struct SelfTalkExample: Codable, Sendable {
    let emotion: String
    let label: String
    let reframe: String
    let redirect: String
}
