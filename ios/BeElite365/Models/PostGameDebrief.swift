import Foundation
import SwiftData

@Model
class PostGameDebrief {
    var id: UUID
    var matchEventID: UUID?
    var date: Date
    var wentWellTags: [String]
    var wentWellFreeText: String
    var challengedTags: [String]
    var challengedFreeText: String
    var selfMessageForNextMatch: String

    init(
        matchEventID: UUID? = nil,
        wentWellTags: [String] = [],
        wentWellFreeText: String = "",
        challengedTags: [String] = [],
        challengedFreeText: String = "",
        selfMessageForNextMatch: String = ""
    ) {
        self.id = UUID()
        self.matchEventID = matchEventID
        self.date = Date()
        self.wentWellTags = wentWellTags
        self.wentWellFreeText = wentWellFreeText
        self.challengedTags = challengedTags
        self.challengedFreeText = challengedFreeText
        self.selfMessageForNextMatch = selfMessageForNextMatch
    }

    var summaryForCoach: String {
        var parts: [String] = []
        let allWell = wentWellTags + (wentWellFreeText.isEmpty ? [] : [wentWellFreeText])
        let allChallenged = challengedTags + (challengedFreeText.isEmpty ? [] : [challengedFreeText])
        if !allWell.isEmpty {
            parts.append("Went well: \(allWell.joined(separator: ", "))")
        }
        if !allChallenged.isEmpty {
            parts.append("Challenged by: \(allChallenged.joined(separator: ", "))")
        }
        if !selfMessageForNextMatch.isEmpty {
            parts.append("Message to self: \"\(selfMessageForNextMatch)\"")
        }
        return parts.joined(separator: ". ")
    }
}

struct DebriefTagLibrary {
    static let wentWellTags: [String] = [
        "Stayed composed",
        "Good body language",
        "Bounced back from a mistake",
        "Controlled my self-talk",
        "Stuck to my focus",
        "Stayed switched on",
        "Played with confidence",
        "Led by example",
        "Managed my energy",
        "Trusted the process"
    ]

    static let challengedTags: [String] = [
        "Lost confidence after a mistake",
        "Overthought",
        "Let the crowd affect me",
        "Got frustrated with a teammate",
        "Couldn't switch on",
        "Anxiety took over",
        "Lost focus mid-match",
        "Negative self-talk",
        "Couldn't recover after setback",
        "Felt flat and disconnected"
    ]
}
