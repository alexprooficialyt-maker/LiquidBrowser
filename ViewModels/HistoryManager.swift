import Foundation

// MARK: - HistoryManager

@Observable
final class HistoryManager {

    private let key = "history_v1"
    var items: [HistoryItem] = []

    init() { load() }

    // MARK: - Añadir

    func record(url: URL, title: String) {
        // Evitar duplicados recientes (mismo host en los últimos 30 s)
        if let last = items.first,
           last.url.host == url.host,
           Date().timeIntervalSince(last.visitedAt) < 30 { return }

        let item = HistoryItem(url: url, title: title)
        items.insert(item, at: 0)
        if items.count > 1000 { items.removeLast() }
        save()
    }

    // MARK: - Eliminar

    func remove(id: UUID) {
        items.removeAll { $0.id == id }
        save()
    }

    func clearAll() {
        items.removeAll()
        save()
    }

    // MARK: - Búsqueda

    func search(query: String) -> [HistoryItem] {
        guard !query.isEmpty else { return items }
        let q = query.lowercased()
        return items.filter {
            $0.title.lowercased().contains(q) || $0.displayHost.lowercased().contains(q)
        }
    }

    // MARK: - Agrupado por fecha

    var grouped: [(HistoryGroup, [HistoryItem])] {
        var dict: [HistoryGroup: [HistoryItem]] = [:]
        for item in items {
            let g = HistoryGroup.group(for: item.visitedAt)
            dict[g, default: []].append(item)
        }
        return HistoryGroup.allCases.compactMap { group in
            guard let list = dict[group], !list.isEmpty else { return nil }
            return (group, list)
        }
    }

    // MARK: - Persistencia

    private func save() {
        if let data = try? JSONEncoder().encode(items) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }

    private func load() {
        guard let data = UserDefaults.standard.data(forKey: key),
              let decoded = try? JSONDecoder().decode([HistoryItem].self, from: data)
        else { return }
        items = decoded
    }
}
