import SwiftUI

// MARK: - HistoryView

struct HistoryView: View {
    @Bindable var manager: HistoryManager
    var onSelect: (HistoryItem) -> Void

    @State private var searchQuery = ""
    @Environment(\.dismiss) private var dismiss

    private var grouped: [(HistoryGroup, [HistoryItem])] {
        searchQuery.isEmpty
            ? manager.grouped
            : [(.today, manager.search(query: searchQuery))]
    }

    var body: some View {
        NavigationView {
            List {
                ForEach(grouped, id: \.0) { group, items in
                    Section(group.rawValue) {
                        ForEach(items) { item in
                            Button(action: { onSelect(item) }) {
                                VStack(alignment: .leading, spacing: 3) {
                                    Text(item.title.isEmpty ? item.displayHost : item.title)
                                        .font(.system(size: 14, weight: .medium, design: .rounded))
                                        .foregroundStyle(.primary).lineLimit(1)
                                    Text(item.displayHost)
                                        .font(.system(size: 12, design: .rounded))
                                        .foregroundStyle(.secondary).lineLimit(1)
                                }
                            }
                            .swipeActions(edge: .trailing) {
                                Button(role: .destructive) { manager.remove(id: item.id) } label: {
                                    Label("Eliminar", systemImage: "trash")
                                }
                            }
                        }
                    }
                }
            }
            .searchable(text: $searchQuery, prompt: "Buscar en historial")
            .navigationTitle("Historial")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cerrar") { dismiss() } }
                ToolbarItem(placement: .destructiveAction) {
                    Button("Borrar todo", role: .destructive) { manager.clearAll() }
                }
            }
        }
    }
}
