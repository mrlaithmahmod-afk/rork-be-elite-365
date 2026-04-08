import Foundation
import SwiftData

@Model
class ConfidenceVaultEntry {
    var id: UUID
    var date: Date
    var typeRaw: String
    var title: String
    var content: String
    var matchMomentOpponent: String
    var isPinned: Bool

    var entryType: VaultEntryType {
        get { VaultEntryType(rawValue: typeRaw) ?? .textEntry }
        set { typeRaw = newValue.rawValue }
    }

    init(
        type: VaultEntryType,
        title: String,
        content: String,
        matchMomentOpponent: String = ""
    ) {
        self.id = UUID()
        self.date = Date()
        self.typeRaw = type.rawValue
        self.title = title
        self.content = content
        self.matchMomentOpponent = matchMomentOpponent
        self.isPinned = false
    }

    var summaryForCoach: String {
        var s = "\(entryType.rawValue): \(title)"
        if !content.isEmpty {
            s += " — \(content.prefix(100))"
        }
        return s
    }
}

nonisolated enum VaultEntryType: String, Codable, CaseIterable, Sendable, Identifiable {
    case textEntry = "Note"
    case coachCompliment = "Coach Compliment"
    case matchMoment = "Match Moment"
    case milestone = "Milestone"
    case proudMoment = "Proud Moment"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .textEntry: "note.text"
        case .coachCompliment: "quote.bubble"
        case .matchMoment: "sportscourt"
        case .milestone: "flag.fill"
        case .proudMoment: "star.fill"
        }
    }

    var color: String {
        switch self {
        case .textEntry: "secondary"
        case .coachCompliment: "blue"
        case .matchMoment: "green"
        case .milestone: "gold"
        case .proudMoment: "purple"
        }
    }
}
