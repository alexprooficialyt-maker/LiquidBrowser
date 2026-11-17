import SwiftUI

// MARK: - HistoryView (Historial de Navegación y Búsquedas Monocromo)

public struct HistoryView: View {
    @State private var selectedTab: Int = 0 // 0: Páginas, 1: Búsquedas
    @State private var historyEntries: [HistoryEntry] = []
    @State private var searchHistoryEntries: [SearchHistoryEntry] = []
    @State private var searchQuery: String = ""
    @State private var showingClearConfirmation: Bool = false

    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme

    var onSelectURL: (URL) -> Void

    public init(onSelectURL: @escaping (URL) -> Void) {
        self.onSelectURL = onSelectURL
    }

    private var groupedWebHistory: [(HistoryPeriodGroup, [HistoryEntry])] {
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

    private var filteredSearches: [SearchHistoryEntry] {
        if searchQuery.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return searchHistoryEntries
        } else {
            let q = searchQuery.lowercased()
            return searchHistoryEntries.filter { $0.query.lowercased().contains(q) }
        }
    }

    public var body: some View {
        let theme = ThemeManager.shared

        NavigationView {
            ZStack {
                theme.background(for: colorScheme)
                    .ignoresSafeArea()

                VStack(spacing: 0) {
                    // Selector de Segmento Monocromo
                    segmentPicker(theme: theme)
                        .padding(.horizontal, 16)
                        .padding(.top, 12)
                        .padding(.bottom, 8)

                    // Barra de Búsqueda Interna
                    searchField(theme: theme)
                        .padding(.horizontal, 16)
                        .padding(.bottom, 12)

                    // Lista de Páginas o Búsquedas
                    if selectedTab == 0 {
                        if historyEntries.isEmpty {
                            emptyState(title: "Sin historial de navegación", subtitle: "Las páginas visitadas se guardarán aquí.")
                        } else {
                            webHistoryListView(theme: theme)
                        }
                    } else {
                        if searchHistoryEntries.isEmpty {
                            emptyState(title: "Sin búsquedas registradas", subtitle: "Tus búsquedas recientes aparecerán aquí.")
                        } else {
                            searchHistoryListView(theme: theme)
                        }
                    }
                }
            }
            .navigationTitle("Historial")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cerrar") {
                        HapticManager.shared.touchLight()
                        dismiss()
                    }
                    .font(.system(size: 15, weight: .medium, design: .rounded))
                    .foregroundStyle(theme.textPrimary(for: colorScheme))
                }

                ToolbarItem(placement: .primaryAction) {
                    if (selectedTab == 0 && !historyEntries.isEmpty) || (selectedTab == 1 && !searchHistoryEntries.isEmpty) {
                        Button("Borrar") {
                            HapticManager.shared.touchMedium()
                            showingClearConfirmation = true
                        }
                        .font(.system(size: 14, weight: .regular, design: .rounded))
                        .foregroundStyle(Color.red)
                    }
                }
            }
            .alert("¿Borrar historial?", isPresented: $showingClearConfirmation) {
                Button("Cancelar", role: .cancel) {}
                Button("Borrar Todo", role: .destructive) {
                    clearCurrentHistory()
                }
            } message: {
                Text(selectedTab == 0 ? "Se eliminarán todas las páginas web visitadas." : "Se borrarán todas las consultas de búsqueda registradas.")
            }
        }
        .onAppear {
            loadAllHistory()
        }
    }

    // MARK: - Segment Picker

    @ViewBuilder
    private func segmentPicker(theme: ThemeManager) -> some View {
        HStack(spacing: 6) {
            segmentButton(title: "Páginas Visitadas", index: 0, theme: theme)
            segmentButton(title: "Búsquedas", index: 1, theme: theme)
        }
        .padding(4)
        .liquidGlass(config: .chip)
    }

    @ViewBuilder
    private func segmentButton(title: String, index: Int, theme: ThemeManager) -> some View {
        let isSelected = (selectedTab == index)

        Button(action: {
            HapticManager.shared.touchLight()
            withAnimation(LiquidAnimation.interactiveSpring) {
                selectedTab = index
            }
        }) {
            Text(title)
                .font(.system(size: 13, weight: isSelected ? .semibold : .medium, design: .rounded))
                .foregroundStyle(isSelected ? (colorScheme == .dark ? Color.black : Color.white) : theme.textPrimary(for: colorScheme))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
                .background {
                    if isSelected {
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .fill(colorScheme == .dark ? Color.white : Color.black)
                    }
                }
        }
        .pressableFeedback()
    }

    // MARK: - Search Field

    @ViewBuilder
    private func searchField(theme: ThemeManager) -> some View {
        HStack(spacing: 8) {
            LiquidIconView(.search, size: 14, color: theme.textSecondary(for: colorScheme))

            TextField("Filtrar historial...", text: $searchQuery)
                .font(.system(size: 14, design: .rounded))
                .foregroundStyle(theme.textPrimary(for: colorScheme))

            if !searchQuery.isEmpty {
                Button(action: {
                    HapticManager.shared.touchLight()
                    searchQuery = ""
                }) {
                    LiquidIconView(.close, size: 12, color: theme.textSecondary(for: colorScheme))
                }
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 9)
        .liquidGlass(config: .card)
    }

    // MARK: - Web History List

    @ViewBuilder
    private func webHistoryListView(theme: ThemeManager) -> some View {
        List {
            ForEach(groupedWebHistory, id: \.0) { group, entries in
                Section {
                    ForEach(entries) { entry in
                        Button(action: {
                            HapticManager.shared.touchMedium()
                            dismiss()
                            onSelectURL(entry.url)
                        }) {
                            HStack(spacing: 12) {
                                LiquidIconView(.desktopMode, size: 16, color: theme.textSecondary(for: colorScheme))

                                VStack(alignment: .leading, spacing: 3) {
                                    Text(entry.displayTitle)
                                        .font(.system(size: 15, weight: .medium, design: .rounded))
                                        .foregroundStyle(theme.textPrimary(for: colorScheme))
                                        .lineLimit(1)

                                    HStack(spacing: 6) {
                                        Text(entry.displayHost)
                                            .font(.system(size: 12, design: .rounded))
                                            .foregroundStyle(theme.textSecondary(for: colorScheme))

                                        Text("•")
                                            .font(.system(size: 10))
                                            .foregroundStyle(theme.textTertiary(for: colorScheme))

                                        Text(entry.formattedTime)
                                            .font(.system(size: 12, design: .rounded))
                                            .foregroundStyle(theme.textTertiary(for: colorScheme))
                                    }
                                }

                                Spacer()

                                LiquidIconView(.chevronRight, size: 12, color: theme.textTertiary(for: colorScheme))
                            }
                            .padding(.vertical, 4)
                        }
                        .listRowBackground(theme.cardBackground(for: colorScheme))
                        .swipeActions(edge: .trailing) {
                            Button(role: .destructive) {
                                deleteWebEntry(entry)
                            } label: {
                                Label("Eliminar", systemImage: "trash")
                            }
                        }
                    }
                } header: {
                    Text(group.rawValue)
                        .font(.system(size: 12, weight: .semibold, design: .rounded))
                        .foregroundStyle(theme.textSecondary(for: colorScheme))
                }
            }
        }
        .scrollContentBackground(.hidden)
    }

    // MARK: - Search History List

    @ViewBuilder
    private func searchHistoryListView(theme: ThemeManager) -> some View {
        List {
            ForEach(filteredSearches) { item in
                Button(action: {
                    HapticManager.shared.touchMedium()
                    dismiss()
                    let url = URLResolver.resolve(input: item.query)
                    onSelectURL(url)
                }) {
                    HStack(spacing: 12) {
                        LiquidIconView(.search, size: 16, color: theme.textSecondary(for: colorScheme))

                        VStack(alignment: .leading, spacing: 3) {
                            Text(item.query)
                                .font(.system(size: 15, weight: .medium, design: .rounded))
                                .foregroundStyle(theme.textPrimary(for: colorScheme))

                            Text("Buscado en \(item.engineUsed)")
                                .font(.system(size: 12, design: .rounded))
                                .foregroundStyle(theme.textSecondary(for: colorScheme))
                        }

                        Spacer()

                        LiquidIconView(.chevronRight, size: 12, color: theme.textTertiary(for: colorScheme))
                    }
                    .padding(.vertical, 4)
                }
                .listRowBackground(theme.cardBackground(for: colorScheme))
                .swipeActions(edge: .trailing) {
                    Button(role: .destructive) {
                        deleteSearchEntry(item)
                    } label: {
                        Label("Eliminar", systemImage: "trash")
                    }
                }
            }
        }
        .scrollContentBackground(.hidden)
    }

    // MARK: - Empty State

    @ViewBuilder
    private func emptyState(title: String, subtitle: String) -> some View {
        let theme = ThemeManager.shared

        VStack(spacing: 14) {
            Spacer()

            LiquidIconView(.history, size: 48, color: theme.textSecondary(for: colorScheme).opacity(0.6))

            Text(title)
                .font(.system(size: 17, weight: .semibold, design: .rounded))
                .foregroundStyle(theme.textPrimary(for: colorScheme))

            Text(subtitle)
                .font(.system(size: 14, design: .rounded))
                .foregroundStyle(theme.textSecondary(for: colorScheme))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)

            Spacer()
        }
    }

    // MARK: - Data Operations

    private func loadAllHistory() {
        if let stored: [HistoryEntry] = StorageEngine.shared.loadJSON(from: "history.json") {
            self.historyEntries = stored
        }
        if let searches: [SearchHistoryEntry] = StorageEngine.shared.loadJSON(from: "search_history.json") {
            self.searchHistoryEntries = searches
        }
    }

    private func deleteWebEntry(_ entry: HistoryEntry) {
        historyEntries.removeAll { $0.id == entry.id }
        StorageEngine.shared.saveJSON(historyEntries, to: "history.json")
        HapticManager.shared.touchLight()
    }

    private func deleteSearchEntry(_ entry: SearchHistoryEntry) {
        searchHistoryEntries.removeAll { $0.id == entry.id }
        StorageEngine.shared.saveJSON(searchHistoryEntries, to: "search_history.json")
        HapticManager.shared.touchLight()
    }

    private func clearCurrentHistory() {
        if selectedTab == 0 {
            historyEntries.removeAll()
            StorageEngine.shared.saveJSON(historyEntries, to: "history.json")
        } else {
            searchHistoryEntries.removeAll()
            StorageEngine.shared.saveJSON(searchHistoryEntries, to: "search_history.json")
        }
        HapticManager.shared.notifySuccess()
    }
}
