import Foundation

struct Drill: Identifiable, Sendable {
    let id: String
    let name: String
    let duration: String
    let triangleSide: TriangleSide
    let rStage: RStage
    let principle: FoundationalPrinciple
    let contexts: [DrillContext]
    let steps: [String]
    let whyItWorks: String
    let category: DrillCategory
}

nonisolated enum DrillCategory: String, CaseIterable, Sendable, Identifiable {
    case reset = "Reset"
    case regroup = "Regroup"
    case refocus = "Refocus"
    case pressure = "Pressure"
    case mistakeRecovery = "Mistake Recovery"
    case identity = "Identity"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .reset: "arrow.counterclockwise"
        case .regroup: "arrow.triangle.merge"
        case .refocus: "scope"
        case .pressure: "flame"
        case .mistakeRecovery: "arrow.uturn.up"
        case .identity: "person.fill"
        }
    }
}

struct DrillLibrary {
    static let drills: [Drill] = [
        Drill(
            id: "reset-breathing-30s",
            name: "30-Second Breathing Reset",
            duration: "30 seconds",
            triangleSide: .mentalPreparation,
            rStage: .reset,
            principle: .discipline,
            contexts: [.inMatch, .preMatch, .training, .any],
            steps: [
                "Stop. Drop your shoulders.",
                "Inhale through your nose for 4 seconds.",
                "Hold for 2 seconds.",
                "Exhale through your mouth for 6 seconds.",
                "Repeat twice more.",
                "Name one thing you can control right now."
            ],
            whyItWorks: "Controlled breathing activates the parasympathetic nervous system, reducing cortisol and restoring decision-making clarity within seconds.",
            category: .reset
        ),
        Drill(
            id: "reset-body-scan",
            name: "Quick Body Scan Release",
            duration: "60 seconds",
            triangleSide: .mentalPreparation,
            rStage: .reset,
            principle: .discipline,
            contexts: [.preMatch, .training, .restDay],
            steps: [
                "Close your eyes. Stand or sit still.",
                "Scan from your head down: notice tension in jaw, neck, shoulders.",
                "Consciously release each area. Drop the jaw. Roll the shoulders back.",
                "Shake out your hands for 3 seconds.",
                "Take one deep breath.",
                "Open your eyes. You are reset."
            ],
            whyItWorks: "Physical tension mirrors mental tension. Releasing the body signals the brain to release the emotional charge of the previous moment.",
            category: .reset
        ),
        Drill(
            id: "reset-release-cue",
            name: "Release the Last Action",
            duration: "10 seconds",
            triangleSide: .mentalPreparation,
            rStage: .reset,
            principle: .patience,
            contexts: [.inMatch, .training],
            steps: [
                "As soon as the moment passes, clench both fists tightly for 2 seconds.",
                "Open your hands wide and exhale sharply.",
                "Say silently: 'Done. Next.'",
                "Look up. Find your next reference point on the pitch."
            ],
            whyItWorks: "A physical cue paired with a verbal trigger creates a neurological anchor that trains rapid emotional release under pressure.",
            category: .reset
        ),
        Drill(
            id: "regroup-controllables",
            name: "Controllables Mapping",
            duration: "2 minutes",
            triangleSide: .practice,
            rStage: .regroup,
            principle: .determination,
            contexts: [.preMatch, .postMatch, .training],
            steps: [
                "Draw a mental line: left side = things I can control, right side = things I cannot.",
                "List 3 controllables: effort, body language, next decision.",
                "List what is outside your control: referee, opponent, weather, result.",
                "Commit to only investing energy in the left column.",
                "Choose one controllable as your anchor for the next 15 minutes."
            ],
            whyItWorks: "Clarity on what you can and cannot control eliminates wasted mental energy and directs focus to actionable performance factors.",
            category: .regroup
        ),
        Drill(
            id: "regroup-pressure-reframe",
            name: "Pressure Reframe Script",
            duration: "2 minutes",
            triangleSide: .mentalPreparation,
            rStage: .regroup,
            principle: .perseverance,
            contexts: [.preMatch, .any],
            steps: [
                "Identify the pressure thought: 'I have to...' or 'What if...'",
                "Reframe: replace 'I have to' with 'I get to'. Replace 'What if I fail' with 'What if I execute'.",
                "State the reframe out loud or silently three times.",
                "Anchor it to one physical action: a breath, a stretch, adjusting your kit."
            ],
            whyItWorks: "Reframing shifts the brain from threat-detection mode to opportunity-seeking mode, improving both decision speed and accuracy.",
            category: .regroup
        ),
        Drill(
            id: "regroup-composure-anchor",
            name: "Composure Anchor",
            duration: "30 seconds",
            triangleSide: .performance,
            rStage: .regroup,
            principle: .patience,
            contexts: [.inMatch, .preMatch],
            steps: [
                "Choose a physical anchor: tap your thigh, adjust your armband, touch the ground.",
                "Pair it with a cue word: 'Calm', 'Steady', 'Mine'.",
                "When composure breaks, execute the anchor + cue word together.",
                "Take one breath. Resume."
            ],
            whyItWorks: "Anchoring pairs a physical stimulus with a desired mental state. With repetition, the anchor alone triggers composure automatically.",
            category: .regroup
        ),
        Drill(
            id: "refocus-next-action",
            name: "Next-Action Targeting",
            duration: "1 minute",
            triangleSide: .practice,
            rStage: .refocus,
            principle: .determination,
            contexts: [.inMatch, .training],
            steps: [
                "Ask: 'What is the single next thing I need to do?'",
                "Make it specific: not 'play better' but 'win the next header' or 'play a simple five-yard pass'.",
                "Commit fully. No half decisions.",
                "Execute. Then repeat the process."
            ],
            whyItWorks: "Narrowing attention to one specific action eliminates overthinking and channels all mental energy into execution.",
            category: .refocus
        ),
        Drill(
            id: "refocus-visualisation",
            name: "Next Involvement Visualisation",
            duration: "3 minutes",
            triangleSide: .mentalPreparation,
            rStage: .refocus,
            principle: .dedication,
            contexts: [.preMatch, .restDay],
            steps: [
                "Close your eyes. Breathe twice slowly.",
                "Visualise your next match involvement: see the ball coming, feel the touch.",
                "Imagine executing perfectly: body shape, first touch, decision.",
                "Add sensory detail: the sound, the surface, the pressure.",
                "Open your eyes. Carry that image into action."
            ],
            whyItWorks: "Mental rehearsal activates the same neural pathways as physical practice. Visualisation before action primes the brain for automatic execution.",
            category: .refocus
        ),
        Drill(
            id: "refocus-attentional-switch",
            name: "Matchday Attentional Switch",
            duration: "2 minutes",
            triangleSide: .practice,
            rStage: .refocus,
            principle: .discipline,
            contexts: [.preMatch, .inMatch],
            steps: [
                "Identify your current attention mode: broad (scanning) or narrow (ball focus).",
                "Switch deliberately: if stuck narrow, widen your vision. If too broad, lock onto the ball.",
                "Practice switching between modes three times.",
                "Set your default mode for the next passage of play."
            ],
            whyItWorks: "Elite performers switch attention modes deliberately rather than reactively. Training this switch improves tactical awareness and reduces tunnel vision.",
            category: .refocus
        ),
        Drill(
            id: "pressure-prematch-routine",
            name: "Pre-Match Routine Builder",
            duration: "5 minutes",
            triangleSide: .mentalPreparation,
            rStage: .reset,
            principle: .discipline,
            contexts: [.preMatch],
            steps: [
                "60 minutes before: finalise your tactical focus for the match.",
                "30 minutes before: put headphones on. Listen to your chosen track or silence.",
                "15 minutes before: three-breath reset. Drop the shoulders.",
                "5 minutes before: visualise your first three involvements.",
                "Walking out: choose your cue word. Lock in."
            ],
            whyItWorks: "A consistent pre-match routine reduces anxiety by creating predictability. The brain performs better when it knows what comes next.",
            category: .pressure
        ),
        Drill(
            id: "pressure-penalty-reset",
            name: "Penalty/1v1 Pressure Reset",
            duration: "30 seconds",
            triangleSide: .performance,
            rStage: .reset,
            principle: .patience,
            contexts: [.inMatch, .training],
            steps: [
                "Before the action: place the ball deliberately. Own the space.",
                "Take two slow breaths. Ignore external noise.",
                "Pick your target. Commit. Do not change.",
                "Visualise the ball hitting the target once.",
                "Execute with full commitment."
            ],
            whyItWorks: "High-pressure moments require slowing internal tempo. Commitment eliminates hesitation, and visualisation primes motor execution.",
            category: .pressure
        ),
        Drill(
            id: "pressure-crowd-focus",
            name: "Crowd/Noise Focus Drill",
            duration: "3 minutes",
            triangleSide: .practice,
            rStage: .refocus,
            principle: .perseverance,
            contexts: [.training, .preMatch],
            steps: [
                "In training, play loud crowd noise through a speaker or headphones.",
                "Set a specific technical task: 10 passes to a target.",
                "Each time your attention drifts to the noise, note it and redirect.",
                "Count successful redirects. Aim to improve the count each session."
            ],
            whyItWorks: "Training under simulated distraction builds attentional resilience. The brain learns to filter noise and prioritise relevant cues.",
            category: .pressure
        ),
        Drill(
            id: "mistake-10s-recovery",
            name: "10-Second Recovery Protocol",
            duration: "10 seconds",
            triangleSide: .performance,
            rStage: .reset,
            principle: .persistence,
            contexts: [.inMatch, .training],
            steps: [
                "Second 1-3: One sharp exhale. Release the tension.",
                "Second 4-6: Name it silently. 'That's done.'",
                "Second 7-8: Find your next reference point. Where do you need to be?",
                "Second 9-10: Move. Commit to your next action."
            ],
            whyItWorks: "Research shows elite athletes recover from mistakes within 10 seconds. This protocol trains that exact response window.",
            category: .mistakeRecovery
        ),
        Drill(
            id: "mistake-one-action",
            name: "One Action at a Time",
            duration: "Ongoing",
            triangleSide: .practice,
            rStage: .refocus,
            principle: .persistence,
            contexts: [.inMatch, .training],
            steps: [
                "After a mistake, resist the urge to do something spectacular.",
                "Choose the simplest possible next action: a five-yard pass, a clearance, a sprint.",
                "Execute it cleanly.",
                "Stack another simple action on top.",
                "Rebuild momentum through small wins, not heroics."
            ],
            whyItWorks: "Trying to compensate after a mistake leads to risk-taking and further errors. Simple actions rebuild neural confidence pathways safely.",
            category: .mistakeRecovery
        ),
        Drill(
            id: "identity-values",
            name: "Values and Process Check",
            duration: "5 minutes",
            triangleSide: .mentalPreparation,
            rStage: .regroup,
            principle: .dedication,
            contexts: [.restDay, .any],
            steps: [
                "Write down three values that define you as a footballer beyond results.",
                "For each value, identify one specific action from this week that demonstrated it.",
                "If you cannot find an action, that value needs more attention.",
                "Set one process goal for tomorrow that aligns with your strongest value."
            ],
            whyItWorks: "Identity anchored in values and process is more resilient than identity anchored in outcomes. This drill separates self-worth from results.",
            category: .identity
        ),
    ]

    static func drills(for category: DrillCategory) -> [Drill] {
        drills.filter { $0.category == category }
    }

    static func drills(for rStage: RStage) -> [Drill] {
        drills.filter { $0.rStage == rStage }
    }

    static func drills(for side: TriangleSide) -> [Drill] {
        drills.filter { $0.triangleSide == side }
    }

    static func recommendedDrill(for profile: PlayerProfile) -> Drill? {
        let skippedR = profile.defaultSkippedR
        let matching = drills.filter { $0.rStage == skippedR }
        return matching.randomElement() ?? drills.first
    }
}
