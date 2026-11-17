import SwiftUI
import WebKit
import Combine

// MARK: - TabManager

@Observable
final class TabManager {

    var tabs:          [BrowserTab] = []
    var activeTabID:   UUID?
    var spaces:        [Space]      = [.default]
    var activeSpaceID: UUID         = Space.default.id
    var recentlyClosed: [BrowserTab] = []   // papelera de pestañas

    // MARK: - Acceso conveniente

    var activeTab: BrowserTab? {
        get { tabs.first { $0.id == activeTabID } }
        set {
            guard let v = newValue,
                  let idx = tabs.firstIndex(where: { $0.id == v.id })
            else { return }
            tabs[idx] = v
        }
    }

    var pinnedTabs: [BrowserTab]  { tabs.filter { $0.isPinned && !$0.isPrivate } }
    var normalTabs: [BrowserTab]  { tabs.filter { !$0.isPinned && !$0.isPrivate } }
    var privateTabs: [BrowserTab] { tabs.filter { $0.isPrivate } }

    var tabsInActiveSpace: [BrowserTab] {
        guard let space = spaces.first(where: { $0.id == activeSpaceID }) else { return normalTabs }
        return tabs.filter { space.tabIDs.contains($0.id) && !$0.isPrivate }
    }

    // MARK: - CRUD Pestañas

    func newTab(url: URL? = nil, isPrivate: Bool = false) -> UUID {
        let tab = BrowserTab(url: url, isPrivate: isPrivate)
        tabs.append(tab)
        activeTabID = tab.id

        // Añadir al espacio activo si no es privada
        if !isPrivate, let idx = spaces.firstIndex(where: { $0.id == activeSpaceID }) {
            spaces[idx].tabIDs.append(tab.id)
        }
        return tab.id
    }

    func close(tabID: UUID) {
        guard let tab = tabs.first(where: { $0.id == tabID }) else { return }
        recentlyClosed.insert(tab, at: 0)
        if recentlyClosed.count > 20 { recentlyClosed.removeLast() }

        tabs.removeAll { $0.id == tabID }
        for i in spaces.indices { spaces[i].tabIDs.removeAll { $0 == tabID } }

        // Seleccionar siguiente pestaña
        if activeTabID == tabID {
            activeTabID = tabs.last?.id
        }
    }

    func restoreLastClosed() {
        guard let tab = recentlyClosed.first else { return }
        recentlyClosed.removeFirst()
        tabs.append(tab)
        activeTabID = tab.id
    }

    func pin(tabID: UUID) {
        guard let idx = tabs.firstIndex(where: { $0.id == tabID }) else { return }
        tabs[idx].isPinned.toggle()
    }

    func update(tabID: UUID, title: String? = nil, url: URL? = nil,
                isLoading: Bool? = nil, progress: Double? = nil, snapshot: UIImage? = nil) {
        guard let idx = tabs.firstIndex(where: { $0.id == tabID }) else { return }
        if let v = title    { tabs[idx].title        = v }
        if let v = url      { tabs[idx].url          = v }
        if let v = isLoading { tabs[idx].isLoading   = v }
        if let v = progress { tabs[idx].loadProgress = v }
        if let v = snapshot { tabs[idx].snapshot     = v }
        tabs[idx].lastAccessed = Date()
    }

    // MARK: - Búsqueda de pestañas

    func searchTabs(query: String) -> [BrowserTab] {
        guard !query.isEmpty else { return tabs }
        let q = query.lowercased()
        return tabs.filter {
            $0.title.lowercased().contains(q) || ($0.displayHost.lowercased().contains(q))
        }
    }

    // MARK: - Cierre automático

    func autoCloseInactiveTabs(olderThanDays days: Int) {
        guard days > 0 else { return }
        let cutoff = Calendar.current.date(byAdding: .day, value: -days, to: Date()) ?? Date()
        let toClose = tabs.filter { !$0.isPinned && $0.lastAccessed < cutoff }
        toClose.forEach { close(tabID: $0.id) }
    }

    // MARK: - Espacios / Carpetas

    func createSpace(name: String, emoji: String) -> UUID {
        let space = Space(name: name, emoji: emoji)
        spaces.append(space)
        return space.id
    }

    func move(tabID: UUID, toSpace spaceID: UUID) {
        for i in spaces.indices { spaces[i].tabIDs.removeAll { $0 == tabID } }
        guard let idx = spaces.firstIndex(where: { $0.id == spaceID }) else { return }
        spaces[idx].tabIDs.append(tabID)
    }
}
