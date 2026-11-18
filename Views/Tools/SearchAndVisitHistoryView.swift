import SwiftUI

// MARK: - SearchAndVisitHistoryView (Dual Búsquedas & Visitas History)

public struct SearchAndVisitHistoryView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var systemColorScheme

    public var onSelectURL: (URL) -> Void

    @State private var storage = StorageEngine.shared
    @State private var selectedSegment: Int = 0 // 0: Búsquedas, 1: Visitas
    @State private var filterText: String = ""
    @State private var isShowingClearConfirmation: Bool = false

    public init(onSelectURL: @escaping (URL) -> Void) {
        self.onSelectURL = onSelectURL
    }

    private var filteredSearches: [SearchRecord] {
        let list = storage.searchRecords.filter { $0.profileID == storage.activeProfileID }
        let trimmed = filterText.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        if trimmed.isEmpty { return list }
        return list.filter { $0.query.lowercased().contains(trimmed) }
    }

    private var filteredVisits: [HistoryEntry] {
        let list = storage.historyForActiveProfile()
        let trimmed = filterText.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        if trimmed.isEmpty { return list }
        return list.filter { $0.title.lowercased().contains(trimmed) || $0.url.absoluteString.lowercased().contains(trimmed) }
    }

    public var body: some View {
        let theme = ThemeManager.shared
        let scheme = theme.effectiveScheme(systemScheme: systemColorScheme)

        NavigationStack {
            ZStack {
                theme.background(for: scheme).ignoresSafeArea()

                VStack(spacing: 12) {
                    // 1. Selector de Segmento
                    Picker("Historial", selection: $selectedSegment) {
                        Text("Búsquedas").tag(0)
                        Text("Visitas Web").tag(1)
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal, 20)
                    .padding(.top, 8)

                    // 2. Barra de Búsqueda
                    HStack(spacing: 8) {
                        LiquidIconView(.search, size: 14, color: theme.textSecondary(for: scheme))

                        TextField("Filtrar historial...", text: $filterText)
                            .font(.system(size: 14))
                            .foregroundStyle(theme.textPrimary(for: scheme))

                        if !filterText.isEmpty {
                            Button {
                                filterText = ""
                            } label: {
                                LiquidIconView(.close, size: 12, color: theme.textSecondary(for: scheme))
                            }
                        }
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .liquidGlassCard(cornerRadius: 12)
                    .padding(.horizontal, 20)

                    // 3. Lista de Contenido
                    if selectedSegment == 0 {
                        searchesListView(theme: theme, scheme: scheme)
                    } else {
                        visitsListView(theme: theme, scheme: scheme)
                    }
                }
            }
            .navigationTitle("Historial")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(Loc.tr("done")) { dismiss() }
                        .foregroundStyle(theme.textPrimary(for: scheme))
                }
                ToolbarItem(placement: .destructiveAction) {
                    Button("Borrar") {
                        isShowingClearConfirmation = true
                    }
                    .foregroundStyle(Color.red)
                    .disabled(selectedSegment == 0 ? storage.searchRecords.isEmpty : storage.historyEntries.isEmpty)
                }
            }
            .confirmationDialog("Borrar Historial", isPresented: $isShowingClearConfirmation) {
                Button(selectedSegment == 0 ? "Borrar todas las búsquedas" : "Borrar todas las visitas", role: .destructive) {
                    HapticManager.shared.notifyWarning()
                    if selectedSegment == 0 {
                        storage.clearSearches()
                    } else {
                        storage.clearHistory()
                    }
                }
                Button(Loc.tr("cancel"), role: .cancel) {}
            }
        }
    }

    @ViewBuilder
    private func searchesListView(theme: ThemeManager, scheme: ColorScheme) -> some View {
        if filteredSearches.isEmpty {
            emptyState(title: "Sin búsquedas registradas", theme: theme, scheme: scheme)
        } else {
            List {
                ForEach(filteredSearches) { record in
                    Button {
                        HapticManager.shared.touchLight()
                        if let url = record.engine.buildSearchURL(query: record.query) {
                            onSelectURL(url)
                            dismiss()
                        }
                    } label: {
                        HStack(spacing: 12) {
                            BrandLogoView(engine: record.engine, style: .monochrome, size: 18)

                            VStack(alignment: .leading, spacing: 2) {
                                Text(record.query)
                                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                                    .foregroundStyle(theme.textPrimary(for: scheme))

                                Text("Buscado en \(record.engine.displayName)")
                                    .font(.system(size: 11, weight: .regular))
                                    .foregroundStyle(theme.textSecondary(for: scheme))
                            }

                            Spacer()

                            LiquidIconView(.chevronRight, size: 12, color: theme.textSecondary(for: scheme).opacity(0.6))
                        }
                    }
                    .buttonStyle(.plain)
                }
                .onDelete { indexSet in
                    for index in indexSet {
                        let item = filteredSearches[index]
                        storage.deleteSearchRecord(id: item.id)
                    }
                }
            }
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
        }
    }

    @ViewBuilder
    private func visitsListView(theme: ThemeManager, scheme: ColorScheme) -> some View {
        if filteredVisits.isEmpty {
            emptyState(title: "Sin visitas registradas", theme: theme, scheme: scheme)
        } else {
            List {
                ForEach(filteredVisits) { visit in
                    Button {
                        HapticManager.shared.touchLight()
                        onSelectURL(visit.url)
                        dismiss()
                    } label: {
                        HStack(spacing: 12) {
                            FaviconView(url: visit.url, title: visit.title, size: 24, cornerRadius: 6)

                            VStack(alignment: .leading, spacing: 2) {
                                Text(visit.title)
                                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                                    .foregroundStyle(theme.textPrimary(for: scheme))
                                    .lineLimit(1)

                                Text("\(visit.displayHost) • \(visit.formattedTime)")
                                    .font(.system(size: 11, weight: .regular))
                                    .foregroundStyle(theme.textSecondary(for: scheme))
                            }

                            Spacer()

                            LiquidIconView(.chevronRight, size: 12, color: theme.textSecondary(for: scheme).opacity(0.6))
                        }
                    }
                    .buttonStyle(.plain)
                }
                .onDelete { indexSet in
                    for index in indexSet {
                        let item = filteredVisits[index]
                        storage.deleteHistoryEntry(id: item.id)
                    }
                }
            }
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
        }
    }

    @ViewBuilder
    private func emptyState(title: String, theme: ThemeManager, scheme: ColorScheme) -> some View {
        VStack(spacing: 8) {
            Spacer()
            LiquidIconView(.history, size: 36, color: theme.textSecondary(for: scheme))
            Text(title)
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(theme.textSecondary(for: scheme))
            Spacer()
        }
    }
}

// MARK: - Compatibility Bridge
public typealias HistoryView = SearchAndVisitHistoryView
