import SwiftUI
import SwiftData

struct MatchCalendarView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \MatchEvent.date) private var matches: [MatchEvent]
    @State private var showAddMatch = false
    @State private var selectedMatch: MatchEvent?

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("MATCH CALENDAR")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(.secondary)
                        .tracking(1)
                    Text("Plan ahead. Prepare mentally.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                Button {
                    showAddMatch = true
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .font(.title3)
                        .foregroundStyle(AppTheme.gold)
                }
            }

            if matches.isEmpty {
                VStack(spacing: 8) {
                    Image(systemName: "calendar.badge.plus")
                        .font(.title2)
                        .foregroundStyle(.secondary)
                    Text("No matches scheduled")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 20)
            } else {
                let upcoming = matches.filter { $0.date >= Calendar.current.startOfDay(for: Date()) }
                let past = matches.filter { $0.date < Calendar.current.startOfDay(for: Date()) }

                if !upcoming.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("UPCOMING")
                            .font(.caption2.weight(.bold))
                            .foregroundStyle(.secondary)
                        ForEach(upcoming.prefix(5)) { match in
                            matchRow(match, isUpcoming: true)
                        }
                    }
                }

                if !past.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("RECENT")
                            .font(.caption2.weight(.bold))
                            .foregroundStyle(.secondary)
                        ForEach(past.suffix(3).reversed()) { match in
                            matchRow(match, isUpcoming: false)
                        }
                    }
                }
            }
        }
        .sheet(isPresented: $showAddMatch) {
            AddMatchView()
        }
    }

    private func matchRow(_ match: MatchEvent, isUpcoming: Bool) -> some View {
        HStack(spacing: 12) {
            VStack(spacing: 2) {
                Text(match.date.formatted(.dateTime.day()))
                    .font(.title3.weight(.bold))
                    .foregroundStyle(isUpcoming ? AppTheme.gold : .secondary)
                Text(match.date.formatted(.dateTime.month(.abbreviated)))
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(.secondary)
            }
            .frame(width: 40)

            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 6) {
                    Text(match.opponent.isEmpty ? "Match" : "vs \(match.opponent)")
                        .font(.subheadline.weight(.semibold))
                    if match.isHome {
                        Text("H")
                            .font(.caption2.weight(.bold))
                            .foregroundStyle(.black)
                            .padding(.horizontal, 4)
                            .padding(.vertical, 1)
                            .background(AppTheme.gold)
                            .clipShape(Capsule())
                    } else {
                        Text("A")
                            .font(.caption2.weight(.bold))
                            .foregroundStyle(.white)
                            .padding(.horizontal, 4)
                            .padding(.vertical, 1)
                            .background(Color.white.opacity(0.15))
                            .clipShape(Capsule())
                    }
                }
                Text(match.date.formatted(date: .omitted, time: .shortened))
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            if isUpcoming {
                let hoursUntil = Calendar.current.dateComponents([.hour], from: Date(), to: match.date).hour ?? 0
                if hoursUntil <= 24 && hoursUntil > 0 {
                    Text("TODAY")
                        .font(.caption2.weight(.black))
                        .foregroundStyle(AppTheme.gold)
                        .tracking(0.5)
                }
            }
        }
        .padding(12)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(.rect(cornerRadius: 10))
    }
}

struct AddMatchView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @State private var opponent: String = ""
    @State private var date: Date = Date()
    @State private var isHome: Bool = true

    var body: some View {
        NavigationStack {
            Form {
                Section("Match Details") {
                    TextField("Opponent", text: $opponent)
                    DatePicker("Date & Time", selection: $date)
                    Toggle("Home Match", isOn: $isHome)
                }
            }
            .navigationTitle("Add Match")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        let match = MatchEvent(
                            date: date,
                            opponent: opponent,
                            isHome: isHome
                        )
                        modelContext.insert(match)
                        NotificationService.scheduleMatchReminder(match: match)
                        dismiss()
                    }
                    .fontWeight(.semibold)
                    .foregroundStyle(AppTheme.gold)
                }
            }
        }
        .presentationDetents([.medium])
    }
}
