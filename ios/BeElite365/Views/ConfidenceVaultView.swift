import SwiftUI
import SwiftData

struct ConfidenceVaultView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query(sort: \ConfidenceVaultEntry.date, order: .reverse) private var entries: [ConfidenceVaultEntry]
    @State private var showAddEntry: Bool = false
    @State private var selectedFilter: VaultEntryType?

    private var filteredEntries: [ConfidenceVaultEntry] {
        guard let filter = selectedFilter else { return entries }
        return entries.filter { $0.entryType == filter }
    }

    private var pinnedEntries: [ConfidenceVaultEntry] {
        filteredEntries.filter(\.isPinned)
    }

    private var unpinnedEntries: [ConfidenceVaultEntry] {
        filteredEntries.filter { !$0.isPinned }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    vaultHeader

                    filterBar

                    if entries.isEmpty {
                        emptyState
                    } else {
                        if !pinnedEntries.isEmpty {
                            sectionView(title: "PINNED", entries: pinnedEntries)
                        }
                        if !unpinnedEntries.isEmpty {
                            sectionView(title: pinnedEntries.isEmpty ? nil : "ALL ENTRIES", entries: unpinnedEntries)
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 24)
            }
            .background(
                LinearGradient(
                    colors: [Color(.systemBackground), Color(red: 0.06, green: 0.06, blue: 0.08)],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .navigationTitle("Confidence Vault")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                        .foregroundStyle(.secondary)
                }
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showAddEntry = true
                    } label: {
                        Image(systemName: "plus")
                            .foregroundStyle(AppTheme.gold)
                    }
                }
            }
            .sheet(isPresented: $showAddEntry) {
                AddVaultEntryView()
            }
        }
    }

    private var vaultHeader: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(AppTheme.gold.opacity(0.1))
                    .frame(width: 64, height: 64)
                Image(systemName: "lock.shield")
                    .font(.system(size: 28))
                    .foregroundStyle(AppTheme.gold)
            }

            Text("Your private evidence bank")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Text("\(entries.count) \(entries.count == 1 ? "entry" : "entries")")
                .font(.caption.weight(.bold).monospacedDigit())
                .foregroundStyle(AppTheme.gold)
        }
        .padding(.top, 8)
    }

    private var filterBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                filterChip(label: "All", type: nil)
                ForEach(VaultEntryType.allCases) { type in
                    filterChip(label: type.rawValue, type: type)
                }
            }
            .contentMargins(.horizontal, 0)
        }
    }

    private func filterChip(label: String, type: VaultEntryType?) -> some View {
        Button {
            selectedFilter = type
        } label: {
            Text(label)
                .font(.caption.weight(.semibold))
                .foregroundStyle(selectedFilter == type ? .black : .primary)
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(selectedFilter == type ? AppTheme.gold : Color(.secondarySystemGroupedBackground))
                .clipShape(Capsule())
        }
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "tray")
                .font(.system(size: 36))
                .foregroundStyle(.tertiary)

            Text("Your vault is empty")
                .font(.subheadline.weight(.semibold))

            Text("Save moments, compliments, milestones,\nand anything that proves you belong here.")
                .font(.caption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            Button {
                showAddEntry = true
            } label: {
                Text("Add First Entry")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(.black)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .background(AppTheme.gold)
                    .clipShape(Capsule())
            }
        }
        .padding(.top, 40)
    }

    private func sectionView(title: String?, entries: [ConfidenceVaultEntry]) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            if let title {
                Text(title)
                    .font(.caption2.weight(.bold))
                    .foregroundStyle(.secondary)
                    .tracking(1)
            }

            ForEach(entries) { entry in
                vaultEntryCard(entry)
            }
        }
    }

    private func vaultEntryCard(_ entry: ConfidenceVaultEntry) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 10) {
                Image(systemName: entry.entryType.icon)
                    .font(.caption.weight(.bold))
                    .foregroundStyle(AppTheme.gold)
                    .frame(width: 24)

                VStack(alignment: .leading, spacing: 2) {
                    Text(entry.title)
                        .font(.subheadline.weight(.semibold))
                        .lineLimit(1)
                    Text(entry.entryType.rawValue)
                        .font(.caption2.weight(.medium))
                        .foregroundStyle(.secondary)
                }

                Spacer()

                if entry.isPinned {
                    Image(systemName: "pin.fill")
                        .font(.caption2)
                        .foregroundStyle(AppTheme.gold)
                }

                Text(entry.date.formatted(.dateTime.day().month(.abbreviated)))
                    .font(.caption2.weight(.medium))
                    .foregroundStyle(.tertiary)
            }

            if !entry.content.isEmpty {
                Text(entry.content)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(3)
            }

            if !entry.matchMomentOpponent.isEmpty {
                HStack(spacing: 4) {
                    Image(systemName: "sportscourt")
                        .font(.caption2)
                    Text("vs \(entry.matchMomentOpponent)")
                        .font(.caption2.weight(.semibold))
                }
                .foregroundStyle(AppTheme.gold.opacity(0.7))
            }
        }
        .padding(14)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(.rect(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .strokeBorder(entry.isPinned ? AppTheme.gold.opacity(0.2) : .clear, lineWidth: 1)
        )
        .contextMenu {
            Button {
                entry.isPinned.toggle()
            } label: {
                Label(entry.isPinned ? "Unpin" : "Pin to Top", systemImage: entry.isPinned ? "pin.slash" : "pin")
            }
            Button(role: .destructive) {
                modelContext.delete(entry)
            } label: {
                Label("Delete", systemImage: "trash")
            }
        }
    }
}

struct AddVaultEntryView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @State private var selectedType: VaultEntryType = .textEntry
    @State private var title: String = ""
    @State private var content: String = ""
    @State private var opponent: String = ""

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("TYPE")
                            .font(.caption2.weight(.bold))
                            .foregroundStyle(.secondary)

                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                ForEach(VaultEntryType.allCases) { type in
                                    Button {
                                        selectedType = type
                                    } label: {
                                        HStack(spacing: 6) {
                                            Image(systemName: type.icon)
                                                .font(.caption2)
                                            Text(type.rawValue)
                                                .font(.caption.weight(.semibold))
                                        }
                                        .foregroundStyle(selectedType == type ? .black : .primary)
                                        .padding(.horizontal, 14)
                                        .padding(.vertical, 10)
                                        .background(selectedType == type ? AppTheme.gold : Color(.secondarySystemGroupedBackground))
                                        .clipShape(Capsule())
                                    }
                                }
                            }
                            .contentMargins(.horizontal, 0)
                        }
                    }

                    VStack(alignment: .leading, spacing: 6) {
                        Text("TITLE")
                            .font(.caption2.weight(.bold))
                            .foregroundStyle(.secondary)
                        TextField("", text: $title, prompt: Text(titlePlaceholder).foregroundStyle(.white.opacity(0.3)))
                            .font(.body)
                            .padding(14)
                            .background(Color(.secondarySystemGroupedBackground))
                            .clipShape(.rect(cornerRadius: 10))
                    }

                    VStack(alignment: .leading, spacing: 6) {
                        Text("DETAILS")
                            .font(.caption2.weight(.bold))
                            .foregroundStyle(.secondary)
                        TextField("", text: $content, prompt: Text("Describe the moment...").foregroundStyle(.white.opacity(0.3)), axis: .vertical)
                            .font(.body)
                            .lineLimit(3...6)
                            .padding(14)
                            .background(Color(.secondarySystemGroupedBackground))
                            .clipShape(.rect(cornerRadius: 10))
                    }

                    if selectedType == .matchMoment {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("OPPONENT")
                                .font(.caption2.weight(.bold))
                                .foregroundStyle(.secondary)
                            TextField("", text: $opponent, prompt: Text("e.g. City FC").foregroundStyle(.white.opacity(0.3)))
                                .font(.body)
                                .padding(14)
                                .background(Color(.secondarySystemGroupedBackground))
                                .clipShape(.rect(cornerRadius: 10))
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.top, 16)
                .padding(.bottom, 24)
            }
            .scrollDismissesKeyboard(.interactively)
            .background(Color(.systemBackground))
            .navigationTitle("New Entry")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .foregroundStyle(.secondary)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveEntry()
                        dismiss()
                    }
                    .fontWeight(.semibold)
                    .foregroundStyle(AppTheme.gold)
                    .disabled(title.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
        .presentationDetents([.medium, .large])
    }

    private var titlePlaceholder: String {
        switch selectedType {
        case .textEntry: "What happened?"
        case .coachCompliment: "What did they say?"
        case .matchMoment: "Describe the moment"
        case .milestone: "e.g. First goal for the team"
        case .proudMoment: "What are you proud of?"
        }
    }

    private func saveEntry() {
        let entry = ConfidenceVaultEntry(
            type: selectedType,
            title: title.trimmingCharacters(in: .whitespaces),
            content: content.trimmingCharacters(in: .whitespaces),
            matchMomentOpponent: opponent.trimmingCharacters(in: .whitespaces)
        )
        modelContext.insert(entry)
    }
}
