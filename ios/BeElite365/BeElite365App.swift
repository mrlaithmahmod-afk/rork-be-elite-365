import SwiftUI
import SwiftData

@main
struct BeElite365App: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            PlayerProfile.self,
            DailyCheckIn.self,
            SolutionCard.self,
            DrillCompletion.self,
            CoachConversation.self,
            MatchEvent.self,
            GoalItem.self,
            MatchDaySession.self,
            PostGameDebrief.self,
            ConfidenceVaultEntry.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            let urls = [
                modelConfiguration.url,
                modelConfiguration.url.deletingPathExtension().appendingPathExtension("sqlite-wal"),
                modelConfiguration.url.deletingPathExtension().appendingPathExtension("sqlite-shm")
            ]
            for url in urls {
                try? FileManager.default.removeItem(at: url)
            }
            do {
                return try ModelContainer(for: schema, configurations: [modelConfiguration])
            } catch {
                fatalError("Could not create ModelContainer: \(error)")
            }
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .onAppear {
                    NotificationService.requestPermission()
                    NotificationService.scheduleDailyCheckInReminder()
                    NotificationService.scheduleTrainingReminder()
                }
        }
        .modelContainer(sharedModelContainer)
    }
}
