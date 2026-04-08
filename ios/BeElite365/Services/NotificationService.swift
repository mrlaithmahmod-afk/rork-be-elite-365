import Foundation
import UserNotifications

struct NotificationService {
    static func requestPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { _, _ in }
    }

    static func scheduleDailyCheckInReminder() {
        let content = UNMutableNotificationContent()
        content.title = "Daily Check-In"
        content.body = "How are you feeling today? Take 30 seconds to check in."
        content.sound = .default

        var dateComponents = DateComponents()
        dateComponents.hour = 9
        dateComponents.minute = 0
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)

        let request = UNNotificationRequest(identifier: "daily-checkin", content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
    }

    static func scheduleMatchReminder(match: MatchEvent) {
        guard let reminderDate = Calendar.current.date(byAdding: .hour, value: -1, to: match.date),
              reminderDate > Date() else { return }

        let content = UNMutableNotificationContent()
        content.title = "Match in 1 Hour"
        let opponent = match.opponent.isEmpty ? "your match" : "vs \(match.opponent)"
        content.body = "Your match starts in an hour. Let's get you ready. \(opponent)"
        content.sound = .default

        let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: reminderDate)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)

        let request = UNNotificationRequest(identifier: "match-\(match.id.uuidString)", content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
    }

    static func schedulePostMatchReminder(match: MatchEvent) {
        guard let reminderDate = Calendar.current.date(byAdding: .hour, value: 2, to: match.date),
              reminderDate > Date() else { return }

        let content = UNMutableNotificationContent()
        content.title = "Post-Match Review"
        content.body = "How did the match go? Take a few minutes to reflect and log your review."
        content.sound = .default

        let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: reminderDate)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)

        let request = UNNotificationRequest(identifier: "postmatch-\(match.id.uuidString)", content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
    }

    static func scheduleTrainingReminder() {
        let content = UNMutableNotificationContent()
        content.title = "Mental Training"
        content.body = "Consistency builds elite performance. Time for today's drill."
        content.sound = .default

        var dateComponents = DateComponents()
        dateComponents.hour = 18
        dateComponents.minute = 0
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)

        let request = UNNotificationRequest(identifier: "training-reminder", content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
    }
}
