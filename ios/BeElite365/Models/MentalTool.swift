import Foundation

struct MentalTool: Identifiable, Sendable {
    let id: String
    let name: String
    let duration: String
    let rStage: RStage
    let description: String
    let steps: [String]
    let whenToUse: String
}

struct MentalToolsLibrary {
    static let tools: [MentalTool] = [
        MentalTool(
            id: "tool-pressure-breathing",
            name: "Pressure Breathing Reset",
            duration: "30 sec",
            rStage: .reset,
            description: "Rapid breathing technique to cut through pressure in the moment.",
            steps: [
                "Sharp exhale through the mouth. Push the air out.",
                "Inhale slowly through the nose for 4 seconds.",
                "Hold for 2 seconds.",
                "Exhale for 6 seconds through the mouth.",
                "Repeat once more. Name one controllable."
            ],
            whenToUse: "Before penalties, free kicks, or any high-pressure moment."
        ),
        MentalTool(
            id: "tool-mistake-recovery",
            name: "Mistake Recovery Protocol",
            duration: "10 sec",
            rStage: .reset,
            description: "Structured 10-second sequence to recover from any on-pitch error.",
            steps: [
                "1-3 sec: One sharp exhale. Release the tension.",
                "4-6 sec: Name it silently. 'That is done.'",
                "7-8 sec: Find your next reference point on the pitch.",
                "9-10 sec: Move. Commit to the next action."
            ],
            whenToUse: "Immediately after any mistake during a match or training."
        ),
        MentalTool(
            id: "tool-focus-cue",
            name: "Focus Cue Reset",
            duration: "15 sec",
            rStage: .refocus,
            description: "A quick verbal cue technique to redirect wandering attention.",
            steps: [
                "Notice your attention has drifted.",
                "Say your cue word silently: 'Ball', 'Position', or 'Next'.",
                "Lock your eyes onto the ball or your marker.",
                "Commit to one task for the next 30 seconds."
            ],
            whenToUse: "When you notice your mind drifting during play."
        ),
        MentalTool(
            id: "tool-attention-switch",
            name: "Attention Switch Drill",
            duration: "1 min",
            rStage: .refocus,
            description: "Deliberately switch between broad and narrow attention.",
            steps: [
                "Broad: scan the pitch. Where are your teammates? Opponents?",
                "Narrow: lock onto the ball. Nothing else exists.",
                "Broad again: check your position relative to the play.",
                "Narrow: focus on your next specific task.",
                "This is the switch. Practice it until it is automatic."
            ],
            whenToUse: "During training or when tactical awareness drops in a match."
        ),
        MentalTool(
            id: "tool-controllables-filter",
            name: "Controllables Filter",
            duration: "1 min",
            rStage: .regroup,
            description: "Quickly separate what you can and cannot control.",
            steps: [
                "What just happened? State it factually.",
                "Can I change it? If no, let it go.",
                "What can I control right now?",
                "Pick one: effort, body language, or next decision.",
                "Commit to that one thing. Nothing else matters."
            ],
            whenToUse: "After criticism, bad referee decisions, or teammate errors."
        ),
        MentalTool(
            id: "tool-composure-anchor",
            name: "Composure Anchor",
            duration: "5 sec",
            rStage: .regroup,
            description: "A physical trigger paired with a mental cue to restore composure instantly.",
            steps: [
                "Choose your anchor: tap your thigh, adjust your armband, touch the ground.",
                "Pair it with your cue word: 'Calm', 'Steady', or 'Mine'.",
                "Execute: anchor + cue word together.",
                "One breath. Resume."
            ],
            whenToUse: "When composure breaks. Before set pieces. After receiving criticism."
        ),
        MentalTool(
            id: "tool-cognitive-reframe",
            name: "Cognitive Reframe",
            duration: "30 sec",
            rStage: .regroup,
            description: "Replace a pressure thought with a performance thought.",
            steps: [
                "Identify the thought: 'I have to...' or 'What if...'",
                "Reframe: 'I have to' becomes 'I get to'.",
                "'What if I fail' becomes 'What if I execute'.",
                "State the reframe once. Anchor it with a breath."
            ],
            whenToUse: "Pre-match nerves, before big moments, after self-doubt."
        ),
        MentalTool(
            id: "tool-if-then",
            name: "If/Then Script",
            duration: "2 min",
            rStage: .refocus,
            description: "Pre-programme your response to common pressure triggers.",
            steps: [
                "Identify your most common trigger.",
                "Write: 'If [trigger], then I will [response].'",
                "Example: 'If I lose the ball, then I will sprint to recover.'",
                "Rehearse it mentally 3 times.",
                "In the moment, the script runs automatically."
            ],
            whenToUse: "Pre-match preparation. Weekly mental training."
        ),
        MentalTool(
            id: "tool-self-talk-scripting",
            name: "Self-Talk Scripting",
            duration: "5 min",
            rStage: .regroup,
            description: "Rewrite your internal dialogue from critical to constructive.",
            steps: [
                "Write down the negative thought you repeat most often during matches.",
                "Identify the emotion behind it: fear, frustration, doubt.",
                "Rewrite it as a factual, task-focused statement.",
                "Example: 'I always mess up' becomes 'I execute my next action cleanly.'",
                "Rehearse the new script 5 times. Anchor it to a physical trigger."
            ],
            whenToUse: "Weekly mental training. Before matches if self-doubt is high."
        ),
        MentalTool(
            id: "tool-highlight-reel",
            name: "Highlight Reel",
            duration: "3 min",
            rStage: .regroup,
            description: "Visualise your best moments to prime confidence before performance.",
            steps: [
                "Close your eyes. Take two slow breaths.",
                "Recall three of your best football moments. Be specific.",
                "For each: see it, hear it, feel it. Replay in slow motion.",
                "Notice the confidence in your body during those moments.",
                "Open your eyes. Carry that feeling into your next action."
            ],
            whenToUse: "Pre-match. After a confidence dip. During weekly mental training."
        ),
        MentalTool(
            id: "tool-power-posing",
            name: "Confidence Posture Reset",
            duration: "2 min",
            rStage: .reset,
            description: "Use body language to shift your internal state from doubt to readiness.",
            steps: [
                "Stand tall. Feet shoulder-width apart.",
                "Chest open. Shoulders back and down.",
                "Hands on hips or arms slightly wide. Take up space.",
                "Hold for 60 seconds. Breathe slowly.",
                "Your body signals your brain: you are ready."
            ],
            whenToUse: "Before walking onto the pitch. In the tunnel. After being substituted on."
        ),
        MentalTool(
            id: "tool-win-next-ball",
            name: "Win the Next Ball",
            duration: "10 sec",
            rStage: .refocus,
            description: "Immediate attention shift to the next actionable moment.",
            steps: [
                "Whatever just happened is done.",
                "Ask: where is the ball going next?",
                "Move towards it. Be first.",
                "Win it. That is your reset."
            ],
            whenToUse: "Immediately after any setback during a match."
        ),
        MentalTool(
            id: "tool-narrow-external",
            name: "Narrow-External Focus",
            duration: "3 min",
            rStage: .refocus,
            description: "Block out crowd noise and distractions by narrowing your visual focus.",
            steps: [
                "Pick one object in your environment. Lock eyes on it.",
                "Hold for 10 seconds. Let all peripheral noise fade.",
                "Now shift to the ball. Same intensity of focus.",
                "Practice this switch 5 times.",
                "In matches, use this when the crowd or pressure builds."
            ],
            whenToUse: "During training with simulated noise. Before set pieces."
        ),
    ]

    static func tools(for rStage: RStage) -> [MentalTool] {
        tools.filter { $0.rStage == rStage }
    }
}
