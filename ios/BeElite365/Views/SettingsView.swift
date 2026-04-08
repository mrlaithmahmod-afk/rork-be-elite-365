import SwiftUI
import SwiftData
import LocalAuthentication

struct SettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @AppStorage("isSignedIn") private var isSignedIn = false
    @AppStorage("appLockEnabled") private var appLockEnabled = false
    @AppStorage("dailyCheckInReminder") private var dailyCheckInReminder = true
    @AppStorage("preMatchReminder") private var preMatchReminder = true
    @AppStorage("trainingReminder") private var trainingReminder = true
    @State private var showDeleteConfirmation = false
    @State private var showPaywall = false
    @State private var showExportAlert = false
    @State private var showLevelPicker = false
    @State private var profile: PlayerProfile?
    @State private var biometricType: LABiometryType = .none

    var body: some View {
        List {
            if let profile {
                Section {
                    HStack(spacing: 14) {
                        ZStack {
                            Circle()
                                .fill(AppTheme.gold.opacity(0.15))
                                .frame(width: 48, height: 48)
                            Text(String(profile.name.prefix(1)).uppercased())
                                .font(.title3.weight(.bold))
                                .foregroundStyle(AppTheme.gold)
                        }
                        VStack(alignment: .leading, spacing: 2) {
                            Text(profile.name)
                                .font(.headline.weight(.bold))
                            Text("\(profile.position.displayName) \u{00B7} \(profile.level.rawValue)")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                        VStack(alignment: .trailing, spacing: 2) {
                            Text(profile.subscriptionTier.displayName)
                                .font(.caption.weight(.bold))
                                .foregroundStyle(profile.subscriptionTier == .free ? .secondary : AppTheme.gold)
                            Image(systemName: levelIcon(profile.level))
                                .font(.caption)
                                .foregroundStyle(AppTheme.gold.opacity(0.6))
                        }
                    }
                }
            }

            if let profile {
                Section("Player Level") {
                    Button {
                        showLevelPicker = true
                    } label: {
                        HStack {
                            Label("Playing Level", systemImage: levelIcon(profile.level))
                            Spacer()
                            Text(profile.level.rawValue)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundStyle(.tertiary)
                        }
                    }
                    .foregroundStyle(.primary)

                    HStack(spacing: 12) {
                        Image(systemName: "info.circle")
                            .foregroundStyle(AppTheme.gold)
                        Text("Your level determines which features, coaching style, and tools are available.")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }

            Section("Subscription") {
                if let profile {
                    HStack {
                        Label("Current Plan", systemImage: "crown")
                        Spacer()
                        Text(profile.subscriptionTier.displayName)
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(profile.subscriptionTier == .free ? .secondary : AppTheme.gold)
                    }
                }

                Button {
                    showPaywall = true
                } label: {
                    HStack {
                        Label(profile?.subscriptionTier == .free ? "Upgrade Plan" : "Manage Plan", systemImage: "arrow.up.circle")
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .foregroundStyle(.tertiary)
                    }
                }
                .foregroundStyle(.primary)

                Button("Restore Purchases") {}
                    .foregroundStyle(AppTheme.gold)
            }

            Section("Privacy") {
                if biometricType != .none {
                    Toggle(isOn: $appLockEnabled) {
                        Label(
                            biometricType == .faceID ? "Face ID Lock" : "Touch ID Lock",
                            systemImage: biometricType == .faceID ? "faceid" : "touchid"
                        )
                    }
                    .tint(AppTheme.gold)
                }

                HStack(spacing: 12) {
                    Image(systemName: "lock.shield")
                        .foregroundStyle(AppTheme.gold)
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Your Private Space")
                            .font(.subheadline.weight(.medium))
                        Text("All data stays on your device. No social features. No public sharing.")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }

            Section("Notifications") {
                Toggle(isOn: $dailyCheckInReminder) {
                    Label("Daily Check-In", systemImage: "bell")
                }
                .tint(AppTheme.gold)
                .onChange(of: dailyCheckInReminder) { _, newValue in
                    if newValue {
                        NotificationService.scheduleDailyCheckInReminder()
                    } else {
                        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["daily-checkin"])
                    }
                }

                Toggle(isOn: $preMatchReminder) {
                    Label("Pre-Match Reminder", systemImage: "sportscourt")
                }
                .tint(AppTheme.gold)

                Toggle(isOn: $trainingReminder) {
                    Label("Training Reminder", systemImage: "figure.strengthtraining.traditional")
                }
                .tint(AppTheme.gold)
                .onChange(of: trainingReminder) { _, newValue in
                    if newValue {
                        NotificationService.scheduleTrainingReminder()
                    } else {
                        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["training-reminder"])
                    }
                }
            }

            Section("Data") {
                Button {
                    showExportAlert = true
                } label: {
                    Label("Export Data", systemImage: "square.and.arrow.up")
                }
                .foregroundStyle(.primary)
            }

            Section("Legal") {
                Button {} label: {
                    Label("Terms of Use", systemImage: "doc.text")
                }
                .foregroundStyle(.primary)

                Button {} label: {
                    Label("Privacy Policy", systemImage: "hand.raised")
                }
                .foregroundStyle(.primary)

                Text("Mental performance training. Not medical advice.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Section("Account") {
                Button {
                    isSignedIn = false
                } label: {
                    Label("Sign Out", systemImage: "rectangle.portrait.and.arrow.right")
                }
                .foregroundStyle(.primary)

                Button(role: .destructive) {
                    showDeleteConfirmation = true
                } label: {
                    Label("Delete Account", systemImage: "trash")
                }
            }

            Section {
                VStack(spacing: 4) {
                    Text("BE ELITE 365")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(.secondary)
                        .tracking(2)
                    Text("Version 1.0.0")
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                }
                .frame(maxWidth: .infinity)
                .listRowBackground(Color.clear)
            }
        }
        .navigationTitle("Settings")
        .task {
            let desc = FetchDescriptor<PlayerProfile>(sortBy: [SortDescriptor(\.createdAt, order: .reverse)])
            profile = try? modelContext.fetch(desc).first
            checkBiometrics()
        }
        .alert("Delete Account", isPresented: $showDeleteConfirmation) {
            Button("Cancel", role: .cancel) {}
            Button("Delete", role: .destructive) {
                deleteAccount()
            }
        } message: {
            Text("This will permanently delete your account and all associated data. This action cannot be undone.")
        }
        .alert("Export Data", isPresented: $showExportAlert) {
            Button("OK") {}
        } message: {
            Text("Data export will be available in a future update. All your data is stored securely on your device.")
        }
        .sheet(isPresented: $showPaywall) {
            PaywallView()
        }
        .sheet(isPresented: $showLevelPicker) {
            LevelPickerSheet(profile: profile) {
                let desc = FetchDescriptor<PlayerProfile>(sortBy: [SortDescriptor(\.createdAt, order: .reverse)])
                profile = try? modelContext.fetch(desc).first
            }
        }
    }

    private func levelIcon(_ level: PlayingLevel) -> String {
        switch level {
        case .grassroots: "leaf.fill"
        case .academy: "graduationcap.fill"
        case .semiPro: "gearshape.fill"
        case .professional: "crown.fill"
        }
    }

    private func deleteAccount() {
        do {
            try modelContext.delete(model: PlayerProfile.self)
            try modelContext.delete(model: DailyCheckIn.self)
            try modelContext.delete(model: SolutionCard.self)
            try modelContext.delete(model: DrillCompletion.self)
            try modelContext.delete(model: CoachConversation.self)
            try modelContext.delete(model: MatchEvent.self)
            try modelContext.delete(model: GoalItem.self)
        } catch {}

        isSignedIn = false
    }

    private func checkBiometrics() {
        let context = LAContext()
        var error: NSError?
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            biometricType = context.biometryType
        }
    }
}
