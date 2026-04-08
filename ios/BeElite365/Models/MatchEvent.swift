import Foundation
import SwiftData

@Model
class MatchEvent {
    var id: UUID
    var title: String
    var date: Date
    var opponent: String
    var isHome: Bool
    var notes: String
    var preMatchCompleted: Bool
    var postMatchCompleted: Bool
    var notificationScheduled: Bool

    init(
        title: String = "Match",
        date: Date,
        opponent: String = "",
        isHome: Bool = true,
        notes: String = ""
    ) {
        self.id = UUID()
        self.title = title
        self.date = date
        self.opponent = opponent
        self.isHome = isHome
        self.notes = notes
        self.preMatchCompleted = false
        self.postMatchCompleted = false
        self.notificationScheduled = false
    }
}
