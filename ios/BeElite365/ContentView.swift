import SwiftUI
import SwiftData

struct ContentView: View {
    @AppStorage("isSignedIn") private var isSignedIn = false
    @Environment(\.modelContext) private var modelContext
    @State private var selectedTab: AppTab = .dashboard
    @State private var hasProfile: Bool?

    var body: some View {
        Group {
            if !isSignedIn {
                WelcomeView()
            } else if let hasProfile, !hasProfile {
                OnboardingView(onComplete: {
                    checkForProfile()
                })
            } else if hasProfile == true {
                mainTabView
            } else {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color(.systemBackground))
                    .preferredColorScheme(.dark)
            }
        }
        .task {
            checkForProfile()
        }
        .onChange(of: isSignedIn) { _, newValue in
            if newValue {
                checkForProfile()
            } else {
                hasProfile = nil
            }
        }
    }

    private var mainTabView: some View {
        TabView(selection: $selectedTab) {
            Tab("Control Room", systemImage: "square.grid.2x2", value: .dashboard) {
                NavigationStack {
                    DashboardView(selectedTab: $selectedTab)
                        .toolbar {
                            ToolbarItem(placement: .topBarTrailing) {
                                NavigationLink {
                                    SettingsView()
                                } label: {
                                    Image(systemName: "gearshape")
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }
                }
            }

            Tab("Solve", systemImage: "brain", value: .solve) {
                SolveView()
            }

            Tab("Thinking Gym", systemImage: "book.closed", value: .skills) {
                MentalSkillsView()
            }

            Tab("Coach", systemImage: "message", value: .coach) {
                CoachView()
            }

            Tab("Insights", systemImage: "chart.bar.xaxis", value: .insights) {
                InsightsView()
            }
        }
        .tint(AppTheme.gold)
        .preferredColorScheme(.dark)
    }

    private func checkForProfile() {
        let desc = FetchDescriptor<PlayerProfile>(
            predicate: #Predicate { $0.onboardingComplete == true },
            sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
        )
        let count = (try? modelContext.fetchCount(desc)) ?? 0
        hasProfile = count > 0
    }
}
