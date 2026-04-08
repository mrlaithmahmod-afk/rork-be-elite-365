import Foundation

struct FlowDrill: Identifiable, Sendable {
    let id: String
    let name: String
    let duration: String
    let description: String
    let steps: [String]
    let category: FlowCategory
}

nonisolated enum FlowCategory: String, CaseIterable, Sendable, Identifiable {
    case attentionControl = "Attention Control"
    case presentMoment = "Present-Moment Focus"
    case routineBuilding = "Routine Building"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .attentionControl: "eye.trianglebadge.exclamationmark"
        case .presentMoment: "timer"
        case .routineBuilding: "list.bullet.rectangle"
        }
    }
}

struct FlowLibrary {
    static let drills: [FlowDrill] = [
        FlowDrill(
            id: "flow-attention-narrow",
            name: "Attention Narrowing",
            duration: "3 min",
            description: "Train switching between broad and narrow attention on demand.",
            steps: [
                "Stand still. Widen your vision to see everything in your peripheral.",
                "Hold for 10 seconds. Notice everything without fixating.",
                "Now narrow: lock onto a single object. Block everything else.",
                "Hold for 10 seconds.",
                "Switch back and forth 5 times.",
                "End with narrow focus on your breathing."
            ],
            category: .attentionControl
        ),
        FlowDrill(
            id: "flow-single-task",
            name: "Single-Task Commitment",
            duration: "2 min",
            description: "Practice committing fully to one action without second-guessing.",
            steps: [
                "Pick one simple action: a pass, a touch, a movement.",
                "Before executing, state your intention silently.",
                "Execute with full commitment. No adjustment mid-action.",
                "Assess after, not during.",
                "Repeat 5 times with increasing speed."
            ],
            category: .attentionControl
        ),
        FlowDrill(
            id: "flow-present-anchor",
            name: "Present-Moment Anchor",
            duration: "2 min",
            description: "Use sensory cues to pull yourself into the current moment.",
            steps: [
                "Feel the ground under your boots. Notice the texture.",
                "Hear the closest sound to you. Let it fill your attention.",
                "Feel the air on your skin.",
                "Now pick one thing you can see. Lock onto it.",
                "Say silently: 'I am here. This moment. This action.'"
            ],
            category: .presentMoment
        ),
        FlowDrill(
            id: "flow-body-scan-quick",
            name: "60-Second Body Check",
            duration: "1 min",
            description: "Quickly scan for tension and release it to enter a flow-ready state.",
            steps: [
                "Jaw: unclench. Let it hang slightly open.",
                "Shoulders: drop them. Roll back once.",
                "Hands: unclench. Shake for 3 seconds.",
                "Legs: bounce lightly. Feel loose.",
                "One deep breath. You are ready."
            ],
            category: .presentMoment
        ),
        FlowDrill(
            id: "flow-prematch-routine",
            name: "Pre-Match Flow Routine",
            duration: "5 min",
            description: "A structured routine to enter a flow-ready state before kick-off.",
            steps: [
                "T-30 min: Music or silence. Your choice. No phone.",
                "T-15 min: Three slow breaths. Drop the shoulders.",
                "T-10 min: Visualise your first three involvements.",
                "T-5 min: Choose your cue word for the match.",
                "Walking out: Anchor the cue word. Lock in."
            ],
            category: .routineBuilding
        ),
        FlowDrill(
            id: "flow-halftime-reset",
            name: "Half-Time Reset Protocol",
            duration: "3 min",
            description: "Reset and recalibrate between halves.",
            steps: [
                "Sit still for 30 seconds. Let the first half go.",
                "One thing that went well. Acknowledge it.",
                "One adjustment for the second half. Be specific.",
                "Three breaths. Cue word.",
                "Stand up. You are reset."
            ],
            category: .routineBuilding
        ),
    ]

    static func drills(for category: FlowCategory) -> [FlowDrill] {
        drills.filter { $0.category == category }
    }
}
