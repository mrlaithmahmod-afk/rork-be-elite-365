import Foundation

struct MentalSkill: Identifiable, Sendable {
    let id: UUID
    let name: String
    let triangleSide: TriangleSide
    let rStage: RStage
    let principle: FoundationalPrinciple
    let skillDescription: String
    let dailyDrill: String
    let matchDayVersion: String
    let whyItMatters: String
}

struct MentalSkillData {
    static let skills: [MentalSkill] = [
        MentalSkill(
            id: UUID(),
            name: "Emotional Control",
            triangleSide: .mentalPreparation,
            rStage: .reset,
            principle: .discipline,
            skillDescription: "The ability to recognise and regulate emotional responses during high-pressure moments without suppressing them.",
            dailyDrill: "Before training, identify one emotion you expect to feel today. After training, rate how well you managed it from 1-10. Track the pattern over seven days.",
            matchDayVersion: "When emotion rises, use the 3-breath protocol: inhale 4 seconds, hold 2, exhale 6. Name the emotion silently. Choose your next action deliberately.",
            whyItMatters: "Uncontrolled emotions lead to reactive decisions. Elite players feel everything but act only on what serves performance."
        ),
        MentalSkill(
            id: UUID(),
            name: "Focus Lock",
            triangleSide: .practice,
            rStage: .refocus,
            principle: .determination,
            skillDescription: "The capacity to direct and sustain attention on the task at hand, filtering distractions without forcing concentration.",
            dailyDrill: "During a 15-minute training drill, set a single focus cue. Each time your mind drifts, silently return to the cue. Count your returns.",
            matchDayVersion: "Between plays, use a reset trigger: adjust your kit, tap the ground, or take one sharp breath. Reconnect to your tactical role for the next passage.",
            whyItMatters: "Focus is a skill, not a trait. The players who win consistently are the ones who refocus fastest."
        ),
        MentalSkill(
            id: UUID(),
            name: "Resilience",
            triangleSide: .performance,
            rStage: .regroup,
            principle: .perseverance,
            skillDescription: "The ability to maintain performance standards after setbacks, errors, or adverse conditions without retreating into self-protection.",
            dailyDrill: "After your worst moment in training, deliberately increase your involvement for the next five minutes. Track whether you withdrew or engaged.",
            matchDayVersion: "After a setback, run the 3R sequence: Reset (one breath), Regroup (what is in my control?), Refocus (next specific action). Execute within 10 seconds.",
            whyItMatters: "Every player faces setbacks. The difference between elite and average is recovery speed, not the absence of failure."
        ),
        MentalSkill(
            id: UUID(),
            name: "Composure Under Pressure",
            triangleSide: .performance,
            rStage: .reset,
            principle: .patience,
            skillDescription: "Maintaining technical quality and decision-making clarity when the stakes are highest and external pressure intensifies.",
            dailyDrill: "In training, simulate pressure: give yourself one attempt at a skill with a teammate watching. Notice your body's response. Practice slowing your preparation.",
            matchDayVersion: "Before a high-pressure action, slow your breathing, widen your vision, and commit to your decision before executing.",
            whyItMatters: "Pressure is not the enemy. Rushing under pressure is. Composure is the ability to take your time when everything says hurry."
        ),
        MentalSkill(
            id: UUID(),
            name: "Self-Talk Management",
            triangleSide: .mentalPreparation,
            rStage: .regroup,
            principle: .dedication,
            skillDescription: "Controlling and directing your internal dialogue to support performance rather than undermine it.",
            dailyDrill: "For one training session, notice every negative self-statement. Replace each with a factual, neutral alternative.",
            matchDayVersion: "Prepare three pre-loaded statements for difficult moments: one for after a mistake, one for low confidence, one for fatigue. Use them automatically.",
            whyItMatters: "You will always talk to yourself. The question is whether that voice is a coach or a critic. Train it like any other skill."
        ),
        MentalSkill(
            id: UUID(),
            name: "Pre-Match Visualisation",
            triangleSide: .mentalPreparation,
            rStage: .refocus,
            principle: .dedication,
            skillDescription: "Using mental imagery to rehearse specific match scenarios, building neural pathways that support automatic execution.",
            dailyDrill: "Spend five minutes in a quiet space. Visualise three specific match situations from your position. Include sounds and physical sensations.",
            matchDayVersion: "In the 30 minutes before kick-off, visualise your first three involvements. See the ball, feel the touch. Rehearse your response to the first mistake.",
            whyItMatters: "The brain does not fully distinguish between vividly imagined and real experiences. Visualisation builds the same neural pathways as physical practice."
        ),
        MentalSkill(
            id: UUID(),
            name: "Decision Making Under Pressure",
            triangleSide: .practice,
            rStage: .refocus,
            principle: .determination,
            skillDescription: "The ability to process information quickly and commit to decisions without second-guessing during high-speed moments.",
            dailyDrill: "In small-sided games, set a rule: make every decision within two touches. After training, review three decisions you hesitated on.",
            matchDayVersion: "Trust your preparation. When you see an option, commit. A good decision executed immediately beats a perfect decision executed late.",
            whyItMatters: "Hesitation is the enemy of execution. Training your decision speed under pressure separates those who perform from those who freeze."
        ),
        MentalSkill(
            id: UUID(),
            name: "Confidence Recovery",
            triangleSide: .performance,
            rStage: .regroup,
            principle: .persistence,
            skillDescription: "Rebuilding self-belief after a poor performance or extended difficult period without relying on external validation.",
            dailyDrill: "End each day by writing one specific thing you did well in training. Not general praise but a precise, observable action.",
            matchDayVersion: "If confidence drops during a match, simplify. Play one-touch. Win a header. Make a tackle. Stack small successes to rebuild momentum.",
            whyItMatters: "Confidence is not a feeling you wait for. It is built through evidence. Create the evidence through controllable actions."
        )
    ]

    static func skills(for triangleSide: TriangleSide) -> [MentalSkill] {
        skills.filter { $0.triangleSide == triangleSide }
    }

    static func skills(for rStage: RStage) -> [MentalSkill] {
        skills.filter { $0.rStage == rStage }
    }
}
