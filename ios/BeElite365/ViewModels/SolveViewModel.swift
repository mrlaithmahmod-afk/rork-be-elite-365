import SwiftUI
import SwiftData

@Observable
class SolveViewModel {
    var currentStep: Int = 0
    let totalSteps: Int = 8

    var selectedSituation: SituationType?
    var situationDescription: String = ""
    var selectedEmotion: EmotionType?
    var emotionIntensity: Double = 5
    var selectedTriangleSide: TriangleSide?
    var selectedSkippedR: RStage?
    var resetComplete: Bool = false
    var regroupComplete: Bool = false
    var selectedControllables: Set<String> = []
    var refocusAction: String = ""
    var ifThenTrigger: String = ""
    var ifThenResponse: String = ""

    var progress: Double { Double(currentStep + 1) / Double(totalSteps) }

    var canProceed: Bool {
        switch currentStep {
        case 0: return selectedSituation != nil
        case 1: return selectedEmotion != nil
        case 2: return selectedTriangleSide != nil
        case 3: return selectedSkippedR != nil
        case 4: return resetComplete
        case 5: return !selectedControllables.isEmpty
        case 6: return !refocusAction.trimmingCharacters(in: .whitespaces).isEmpty
        case 7: return true
        default: return false
        }
    }

    let controllableItems: [String] = [
        "My positioning",
        "My body language",
        "My next touch",
        "My communication",
        "My effort level",
        "My breathing",
        "My decision speed",
        "My movement off the ball"
    ]

    func nextStep() {
        guard currentStep < totalSteps - 1 else { return }
        currentStep += 1
    }

    func previousStep() {
        guard currentStep > 0 else { return }
        currentStep -= 1
    }

    func generateReframe() -> String {
        switch selectedSituation {
        case .mistake:
            return "A single error does not define your ability. Elite players make mistakes every match. What separates them is the next action they choose."
        case .lostBall:
            return "Losing possession is part of football. Your positioning and next decision are still within your control."
        case .missedChance:
            return "Getting into scoring positions proves your instinct. The finish will come through repetition, not self-criticism."
        case .gotSubbed:
            return "Being substituted is a tactical decision, not a judgement on your worth. Your response in training defines your trajectory."
        case .receivedCriticism:
            return "Criticism is information. Extract what is useful, discard what is not. Your response is always your choice."
        case .concededGoal:
            return "Goals conceded are team moments, not individual failures. Analyse, adjust, commit to the next defensive action."
        case .lostFocus:
            return "Recognising you lost focus is the first step. Redirect attention to the next controllable action."
        case .other, .none:
            return "Whatever happened has passed. The next moment is unwritten. Choose your response with clarity and purpose."
        }
    }

    func generateMicroActions() -> [String] {
        var actions: [String] = []

        actions.append("Controlled breathing reset: inhale 4, hold 2, exhale 6")

        switch selectedTriangleSide {
        case .mentalPreparation:
            actions.append("Recall your pre-match intention")
            actions.append("Straighten your body language immediately")
        case .practice:
            actions.append("Simplify your next involvement to one touch")
            actions.append("Focus on your first touch quality")
        case .performance:
            actions.append("Commit fully to your next action without hesitation")
            actions.append("Play with authority and presence")
        case .none:
            actions.append("Choose your next action deliberately")
        }

        actions.append("Attentional cue: identify the next controllable action")

        if !refocusAction.isEmpty {
            actions.append("Implementation intention: \(refocusAction)")
        }

        return actions
    }

    func generateTags() -> [String] {
        var tags: [String] = []
        if let situation = selectedSituation { tags.append(situation.rawValue) }
        if let emotion = selectedEmotion { tags.append(emotion.rawValue) }
        if let side = selectedTriangleSide { tags.append(side.shortName) }
        if let r = selectedSkippedR { tags.append(r.rawValue) }
        return tags
    }

    func saveSolutionCard(context: ModelContext) -> SolutionCard {
        let card = SolutionCard(
            situationType: selectedSituation ?? .other,
            situationDescription: situationDescription,
            emotionType: selectedEmotion ?? .frustrated,
            emotionIntensity: emotionIntensity,
            triangleBreakdown: selectedTriangleSide ?? .performance,
            skippedR: selectedSkippedR ?? .reset,
            reframe: generateReframe(),
            microActions: generateMicroActions(),
            refocusAction: refocusAction,
            ifThenTrigger: ifThenTrigger,
            ifThenResponse: ifThenResponse,
            tags: generateTags()
        )
        context.insert(card)
        return card
    }
}
