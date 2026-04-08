import Foundation
import SwiftData

@Model
class MatchDaySession {
    var id: UUID
    var matchEventID: UUID?
    var date: Date
    var arousalStateRaw: String
    var anchorWord: String
    var regulateDurationSeconds: Int
    var rehearseCompleted: Bool
    var anchorCompleted: Bool
    var sequenceCompleted: Bool
    var selfMessageForNextMatch: String

    var arousalState: ArousalState {
        get { ArousalState(rawValue: arousalStateRaw) ?? .wired }
        set { arousalStateRaw = newValue.rawValue }
    }

    init(
        matchEventID: UUID? = nil,
        arousalState: ArousalState = .wired,
        anchorWord: String = ""
    ) {
        self.id = UUID()
        self.matchEventID = matchEventID
        self.date = Date()
        self.arousalStateRaw = arousalState.rawValue
        self.anchorWord = anchorWord
        self.regulateDurationSeconds = 0
        self.rehearseCompleted = false
        self.anchorCompleted = false
        self.sequenceCompleted = false
        self.selfMessageForNextMatch = ""
    }
}

nonisolated enum ArousalState: String, Codable, CaseIterable, Sendable, Identifiable {
    case wired = "Too Wired"
    case flat = "Too Flat"

    var id: String { rawValue }

    var breathingPattern: String {
        switch self {
        case .wired: "4-7-8 Calming"
        case .flat: "Box Breathing"
        }
    }

    var icon: String {
        switch self {
        case .wired: "bolt.heart"
        case .flat: "battery.25percent"
        }
    }
}
