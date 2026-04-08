import SwiftUI
import SwiftData

@Observable
class OnboardingViewModel {
    var currentStep: Int = 0
    let totalSteps: Int = 15

    var name: String = ""
    var selectedGender: Gender?
    var selectedAgeBand: AgeBand?
    var selectedLevel: PlayingLevel?
    var selectedPosition: FootballPosition?
    var selectedPrimaryGoal: PrimaryGoal?
    var selectedCurrentIssues: Set<CurrentIssue> = []
    var selectedPressureMoment: PressureMoment?
    var selectedMistakeResponse: MistakeResponse?
    var selectedSelfTalkStyle: SelfTalkStyle?
    var selectedConfidenceDependency: ConfidenceDependency?
    var emotionalControlScore: Double = 5
    var focusConsistencyScore: Double = 5
    var selectedDisciplineBaseline: DisciplineBaseline?
    var selectedDecisionPointHabit: DecisionPointHabit?

    var isLastStep: Bool { currentStep == totalSteps - 1 }
    var progress: Double { Double(currentStep + 1) / Double(totalSteps) }

    var canProceed: Bool {
        switch currentStep {
        case 0: return !name.trimmingCharacters(in: .whitespaces).isEmpty
        case 1: return selectedGender != nil
        case 2: return selectedAgeBand != nil
        case 3: return selectedLevel != nil
        case 4: return selectedPosition != nil
        case 5: return selectedPrimaryGoal != nil
        case 6: return !selectedCurrentIssues.isEmpty && selectedCurrentIssues.count <= 2
        case 7: return selectedPressureMoment != nil
        case 8: return selectedMistakeResponse != nil
        case 9: return selectedSelfTalkStyle != nil
        case 10: return selectedConfidenceDependency != nil
        case 11: return true
        case 12: return true
        case 13: return selectedDisciplineBaseline != nil
        case 14: return selectedDecisionPointHabit != nil
        default: return false
        }
    }

    func nextStep() {
        guard currentStep < totalSteps - 1 else { return }
        currentStep += 1
    }

    func previousStep() {
        guard currentStep > 0 else { return }
        currentStep -= 1
    }

    func generateProfile(context: ModelContext) {
        var mentalPrep = 30.0 + emotionalControlScore * 5.0
        var practice = 30.0 + focusConsistencyScore * 5.0
        var performance = 25.0 + (emotionalControlScore + focusConsistencyScore) * 2.5

        switch selectedPrimaryGoal {
        case .calmUnderPressure: mentalPrep -= 10
        case .fasterRecovery: performance -= 10
        case .consistency: practice -= 8
        case .strongerFocus: practice -= 10
        case .independentConfidence: performance -= 8; mentalPrep -= 5
        case .returnToPlay: mentalPrep -= 8; performance -= 8
        case .none: break
        }

        let issueImpact = Double(selectedCurrentIssues.count) * 3.0
        mentalPrep -= issueImpact

        if selectedCurrentIssues.contains(.mistakesKillConfidence) { performance -= 5 }
        if selectedCurrentIssues.contains(.overthinking) { mentalPrep -= 5 }
        if selectedCurrentIssues.contains(.focusDrops) { practice -= 5 }
        if selectedCurrentIssues.contains(.inconsistency) { practice -= 3; performance -= 3 }

        switch selectedDisciplineBaseline {
        case .noRoutine: mentalPrep -= 8
        case .inconsistent: mentalPrep -= 4
        case .solid: mentalPrep += 3
        case .elite: mentalPrep += 6
        case .none: break
        }

        switch selectedSelfTalkStyle {
        case .harshCritical: mentalPrep -= 6
        case .doubtfulAnxious: mentalPrep -= 4; performance -= 3
        case .calmInconsistent: break
        case .positiveFragile: performance -= 2
        case .quietTaskFocused: practice += 3
        case .none: break
        }

        let skippedR: RStage
        switch selectedMistakeResponse {
        case .rushToFix: skippedR = .reset
        case .goQuiet: skippedR = .regroup
        case .getAngry: skippedR = .reset
        case .loseFocus: skippedR = .refocus
        case .resetQuickly: skippedR = .regroup
        case .none: skippedR = .reset
        }

        mentalPrep = max(15, min(90, mentalPrep))
        practice = max(15, min(90, practice))
        performance = max(15, min(90, performance))

        let avg = (mentalPrep + practice + performance) / 3.0
        let energyLoop: EnergyLoopState = avg >= 50 ? .positive : .negative

        let minScore = min(mentalPrep, practice, performance)
        let weakest: TriangleSide
        if minScore == mentalPrep { weakest = .mentalPreparation }
        else if minScore == practice { weakest = .practice }
        else { weakest = .performance }

        let profile = PlayerProfile(
            name: name.trimmingCharacters(in: .whitespaces),
            gender: selectedGender ?? .preferNotToSay,
            ageBand: selectedAgeBand ?? .under24,
            position: selectedPosition ?? .centreMidfield,
            level: selectedLevel ?? .academy,
            primaryGoal: selectedPrimaryGoal ?? .calmUnderPressure,
            currentIssues: Array(selectedCurrentIssues),
            pressureMoment: selectedPressureMoment ?? .afterMistake,
            mistakeResponse: selectedMistakeResponse ?? .rushToFix,
            selfTalkStyle: selectedSelfTalkStyle ?? .calmInconsistent,
            confidenceDependency: selectedConfidenceDependency ?? .results,
            emotionalControlScore: emotionalControlScore,
            focusConsistencyScore: focusConsistencyScore,
            disciplineBaseline: selectedDisciplineBaseline ?? .inconsistent,
            decisionPointHabit: selectedDecisionPointHabit ?? .forceIt,
            mentalPrepScore: mentalPrep,
            practiceScore: practice,
            performanceScore: performance,
            defaultSkippedR: skippedR,
            currentEnergyLoop: energyLoop,
            currentRStage: skippedR,
            trainingFocusArea: weakest
        )
        context.insert(profile)
    }
}
