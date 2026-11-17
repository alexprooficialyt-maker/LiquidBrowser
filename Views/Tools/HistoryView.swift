import SwiftUI

public struct HistoryView: View {
    @State private var historyEntries: [HistoryEntry] = []
    @State private var searchQuery: String = ""
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme

    var onSelectURL: (URL) -> Void

    public init(onSelectURL: @escaping (URL) -> Void) {
        self.onSelectURL = onSelectURL
    }

    private var groupedEntries: [(HistoryPeriodGroup, [HistoryEntry])] {
        let filtered: [HistoryEntry]
        if searchQuery.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            filtered = historyEntries
        } else {
            let query = searchQuery.lowercased()
            filtered = historyEntries.filter {
                $0.displayTitle.lowercased().contains(query) || $0.displayHost.lowercased().contains(query)
            }
        }

        var dict: [HistoryPeriodGroup: [HistoryEntry]] = [:]
        for entry in filtered {
            let group = HistoryPeriodGroup.group(for: entry.visitedAt)
            dict[group, default: []].append(entry)
        }

        return HistoryPeriodGroup.allCases.compactMap { grp in
            guard let list = dict[grp], !list.isEmpty else { return nil }
            return (grp, list)
        }
    }

    public var body: some View {
        let theme = ThemeEngine.shared

        NavigationView {
            ZStack {
                theme.background(for: colorScheme)
                    .ignoresSafeArea()

                VStack(spacing: 0) {
                    searchBar
                        .padding(.horizontal, 16)
                        .padding(.top, 8)
                        .padding(.bottom, 12)

                    if historyEntries.isEmpty {
                        emptyHistoryView
                    } else {
                        historyListView
                    }
                }
            }
            .navigationTitle("Historial")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cerrar") { dismiss() }
                        .foregroundStyle(theme.textPrimary(for: colorScheme))
                }
                ToolbarItem(placement: .destructiveAction) {
                    if !historyEntries.isEmpty {
                        Button("Borrar Todo") {
                            clearAllHistory()
                        }
                        .foregroundStyle(Color(red: 1.0, green: 0.25, blue: 0.25))
                    }
                }
            }
            .onAppear {
                loadHistory()
            }
        }
    }

    @ViewBuilder
    private var searchBar: some View {
        HStack(spacing: 10) {
            LiquidIconView(.search, size: 14, color: ThemeEngine.shared.textSecondary(for: colorScheme))

            TextField("Buscar en el historial…", text: $searchQuery)
                .font(.system(size: 14, design: .rounded))
                .foregroundStyle(ThemeEngine.shared.textPrimary(for: colorScheme))
                .autocorrectionDisabled()

            if !searchQuery.isEmpty {
                Button(action: { searchQuery = "" }) {
                    LiquidIconView(.close, size: 12, color: ThemeEngine.shared.textSecondary(for: colorScheme))
                }
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .liquidGlass(config: .card)
    }

    @ViewBuilder
    private var emptyHistoryView: some View {
        Spacer()
        VStack(spacing: 14) {
            LiquidIconView(.history, size: 36, color: ThemeEngine.shared.textSecondary(for: colorScheme))
            Text("Historial Vacío")
                .font(.system(size: 16, weight: .semibold, design: .rounded))
                .foregroundStyle(ThemeEngine.shared.textPrimary(for: colorScheme))
            Text("Las páginas que visites aparecerán aquí.")
                .font(.system(size: 13, design: .rounded))
                .foregroundStyle(ThemeEngine.shared.textSecondary(for: colorScheme))
        }
        Spacer()
    }

    @ViewBuilder
    private var historyListView: some View {
        List {
            ForEach(groupedEntries, id: \.0.id) { group, entries in
                Section {
                    ForEach(entries) { entry in
                        Button(action: {
                            HapticManager.shared.touchLight()
                            onSelectURL(entry.url)
                            dismiss()
                        }) {
                            VStack(alignment: .leading, spacing: 3) {
                                Text(entry.displayTitle)
                                    .font(.system(size: 14, weight: .medium, design: .rounded))
                                    .foregroundStyle(ThemeEngine.shared.textPrimary(for: colorScheme))
                                    .lineLimit(1)

                                HStack(spacing: 6) {
                                    Text(entry.displayHost)
                                        .font(.system(size: 11, design: .rounded))
                                        .foregroundStyle(ThemeEngine.shared.textSecondary(for: colorScheme))
                                        .lineLimit(1)

                                    Text("•")
                                        .font(.system(size: 10))
                                        .foregroundStyle(ThemeEngine.shared.textTertiary(for: colorScheme))

                                    Text(formatDate(entry.visitedAt))
                                        .font(.system(size: 11, design: .rounded))
                                        .foregroundStyle(ThemeEngine.shared.textTertiary(for: colorScheme))
                                }
                            }
                            .padding(.vertical, 3)
                        }
                        .swipeActions(edge: .trailing) {
                            Button(role: .destructive) {
                                deleteEntry(entry)
                            } label: {
                                LiquidIconView(.trash, size: 16, color: .white)
                            }
                        }
                    }
                } header: {
                    Text(group.rawValue)
                        .font(.system(size: 12, weight: .semibold, design: .rounded))
                        .foregroundStyle(ThemeEngine.shared.textSecondary(for: colorScheme))
                }
            }
        }
        .listStyle(.insetGrouped)
        .scrollContentBackground(.hidden)
    }

    private func loadHistory() {
        if let stored = StorageEngine.shared.load([HistoryEntry].self, from: "history.json") {
            self.historyEntries = stored
        }
    }

    private func deleteEntry(_ entry: HistoryEntry) {
        historyEntries.removeAll { $0.id == entry.id }
        StorageEngine.shared.save(historyEntries, to: "history.json")
    }

    private func clearAllHistory() {
        HapticManager.shared.touchMedium()
        historyEntries.removeAll()
        StorageEngine.shared.delete(fileName: "history.json")
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }
}
