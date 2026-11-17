import SwiftUI

// MARK: - StorageEngine (@Observable Persistent Storage Engine)

@Observable
public final class StorageEngine: @unchecked Sendable {
    public static let shared = StorageEngine()

    // Claves de UserDefaults
    private let profilesKey = "smartbot_storage_profiles_v2"
    private let activeProfileIDKey = "smartbot_storage_active_profile_id_v2"
    private let tabsKey = "smartbot_storage_tabs_v2"
    private let spacesKey = "smartbot_storage_spaces_v2"
    private let searchRecordsKey = "smartbot_storage_search_records_v2"
    private let historyKey = "smartbot_storage_history_v2"
    private let savedSitesKey = "smartbot_storage_saved_sites_v2"
    private let onboardingKey = "smartbot_has_completed_onboarding_v2"
    private let activeTabIDKey = "smartbot_storage_active_tab_id_v2"

    // MARK: - In-Memory State

    public var profiles: [UserProfile] = [] {
        didSet { persistProfiles() }
    }

    public var activeProfileID: UUID {
        didSet {
            UserDefaults.standard.set(activeProfileID.uuidString, forKey: activeProfileIDKey)
        }
    }

    public var tabs: [TabModel] = [] {
        didSet { persistTabs() }
    }

    public var spaces: [SpaceModel] = [] {
        didSet { persistSpaces() }
    }

    public var searchRecords: [SearchRecord] = [] {
        didSet { persistSearches() }
    }

    public var historyEntries: [HistoryEntry] = [] {
        didSet { persistHistory() }
    }

    public var savedSites: [SavedSite] = [] {
        didSet { persistSavedSites() }
    }

    public var activeTabID: UUID? {
        didSet {
            if let id = activeTabID {
                UserDefaults.standard.set(id.uuidString, forKey: activeTabIDKey)
            } else {
                UserDefaults.standard.removeObject(forKey: activeTabIDKey)
            }
        }
    }

    public var hasCompletedOnboarding: Bool {
        get { UserDefaults.standard.bool(forKey: onboardingKey) }
        set { UserDefaults.standard.set(newValue, forKey: onboardingKey) }
    }

    // MARK: - Initializer

    public init() {
        // 1. Cargar Perfiles
        let loadedProfiles = Self.loadJSON([UserProfile].self, forKey: profilesKey) ?? []
        if loadedProfiles.isEmpty {
            let defaultProfile = UserProfile.defaultPersonal()
            self.profiles = [defaultProfile]
            self.activeProfileID = defaultProfile.id
        } else {
            self.profiles = loadedProfiles
            if let savedIDStr = UserDefaults.standard.string(forKey: activeProfileIDKey),
               let savedID = UUID(uuidString: savedIDStr),
               loadedProfiles.contains(where: { $0.id == savedID }) {
                self.activeProfileID = savedID
            } else {
                self.activeProfileID = loadedProfiles.first?.id ?? UUID()
            }
        }

        // 2. Cargar Espacios
        let loadedSpaces = Self.loadJSON([SpaceModel].self, forKey: spacesKey) ?? []
        if loadedSpaces.isEmpty {
            self.spaces = SpaceModel.defaultSpaces(for: self.activeProfileID)
        } else {
            self.spaces = loadedSpaces
        }

        // 3. Cargar Pestañas
        let loadedTabs = Self.loadJSON([TabModel].self, forKey: tabsKey) ?? []
        if loadedTabs.isEmpty {
            let initialTab = TabModel(url: nil, title: "Nueva Pestaña", profileID: self.activeProfileID)
            self.tabs = [initialTab]
            self.activeTabID = initialTab.id
        } else {
            self.tabs = loadedTabs
            if let savedTabStr = UserDefaults.standard.string(forKey: activeTabIDKey),
               let savedTabUUID = UUID(uuidString: savedTabStr),
               loadedTabs.contains(where: { $0.id == savedTabUUID }) {
                self.activeTabID = savedTabUUID
            } else {
                self.activeTabID = loadedTabs.first?.id
            }
        }

        // 4. Cargar Búsquedas, Historial y Sitios Guardados
        self.searchRecords = Self.loadJSON([SearchRecord].self, forKey: searchRecordsKey) ?? []
        self.historyEntries = Self.loadJSON([HistoryEntry].self, forKey: historyKey) ?? []
        let loadedSites = Self.loadJSON([SavedSite].self, forKey: savedSitesKey) ?? []
        if loadedSites.isEmpty {
            self.savedSites = SavedSite.defaultSites(for: self.activeProfileID)
        } else {
            self.savedSites = loadedSites
        }
    }

    // MARK: - Computed Properties

    public var activeProfile: UserProfile {
        profiles.first(where: { $0.id == activeProfileID }) ?? profiles.first ?? UserProfile.defaultPersonal()
    }

    public var activeTab: TabModel? {
        tabs.first(where: { $0.id == activeTabID }) ?? tabs.first
    }

    // MARK: - Profile Management

    public func createProfile(name: String, age: Int?, description: String, color: ProfileAccentColor, icon: LiquidIconType = .userProfile) -> UserProfile {
        let profile = UserProfile(
            name: name,
            age: age,
            description: description,
            accentColor: color,
            iconType: icon,
            isDefault: false
        )
        profiles.append(profile)

        // Crear espacios por defecto para el nuevo perfil
        let defaultSpaces = SpaceModel.defaultSpaces(for: profile.id)
        spaces.append(contentsOf: defaultSpaces)

        // Crear sitios guardados por defecto
        let defaultSites = SavedSite.defaultSites(for: profile.id)
        savedSites.append(contentsOf: defaultSites)

        return profile
    }

    public func switchProfile(to id: UUID) {
        guard profiles.contains(where: { $0.id == id }) else { return }
        activeProfileID = id

        // Si no hay pestañas en este perfil, crear una
        let profileTabs = tabs.filter { $0.profileID == id }
        if profileTabs.isEmpty {
            let newTab = TabModel(url: nil, title: "Nueva Pestaña", profileID: id)
            tabs.append(newTab)
            activeTabID = newTab.id
        } else {
            activeTabID = profileTabs.first?.id
        }
    }

    public func updateProfile(_ profile: UserProfile) {
        if let idx = profiles.firstIndex(where: { $0.id == profile.id }) {
            profiles[idx] = profile
        }
    }

    public func deleteProfile(id: UUID) {
        guard profiles.count > 1 else { return } // No eliminar el último
        profiles.removeAll(where: { $0.id == id })
        tabs.removeAll(where: { $0.profileID == id })
        spaces.removeAll(where: { $0.profileID == id })
        searchRecords.removeAll(where: { $0.profileID == id })
        historyEntries.removeAll(where: { $0.profileID == id })
        savedSites.removeAll(where: { $0.profileID == id })
        KeychainVault.shared.deleteProfilePassword(profileID: id)

        if activeProfileID == id {
            activeProfileID = profiles.first?.id ?? UUID()
            activeTabID = tabs.first(where: { $0.profileID == activeProfileID })?.id
        }
    }

    // MARK: - Tabs Management

    public func tabsForActiveProfile() -> [TabModel] {
        tabs.filter { $0.profileID == activeProfileID }
    }

    public func tabsForSpace(_ spaceID: UUID?) -> [TabModel] {
        tabsForActiveProfile().filter { $0.spaceID == spaceID }
    }

    @discardableResult
    public func createTab(url: URL? = nil, title: String = "Nueva Pestaña", spaceID: UUID? = nil, isPrivate: Bool = false) -> TabModel {
        let newTab = TabModel(
            url: url,
            title: title,
            spaceID: spaceID,
            profileID: activeProfileID,
            isPrivate: isPrivate
        )
        tabs.insert(newTab, at: 0)
        activeTabID = newTab.id
        return newTab
    }

    public func closeTab(id: UUID) {
        guard let idx = tabs.firstIndex(where: { $0.id == id }) else { return }
        tabs.remove(at: idx)

        if activeTabID == id {
            let currentProfileTabs = tabsForActiveProfile()
            if let nextTab = currentProfileTabs.first {
                activeTabID = nextTab.id
            } else {
                let fresh = TabModel(url: nil, title: "Nueva Pestaña", profileID: activeProfileID)
                tabs.append(fresh)
                activeTabID = fresh.id
            }
        }
    }

    public func updateTabURL(id: UUID, url: URL?, title: String?) {
        guard let idx = tabs.firstIndex(where: { $0.id == id }) else { return }
        if let url = url { tabs[idx].url = url }
        if let title = title { tabs[idx].title = title }
        tabs[idx].lastAccessedAt = Date()
    }

    public func togglePinTab(id: UUID) {
        guard let idx = tabs.firstIndex(where: { $0.id == id }) else { return }
        tabs[idx].isPinned.toggle()
    }

    public func moveTab(id: UUID, toSpace spaceID: UUID?) {
        guard let idx = tabs.firstIndex(where: { $0.id == id }) else { return }
        tabs[idx].spaceID = spaceID
    }

    // MARK: - Spaces Management

    public func spacesForActiveProfile() -> [SpaceModel] {
        spaces.filter { $0.profileID == activeProfileID }
    }

    @discardableResult
    public func createSpace(name: String, icon: LiquidIconType, isPrivate: Bool = false, color: ProfileAccentColor = .monochrome) -> SpaceModel {
        let newSpace = SpaceModel(
            name: name,
            icon: icon,
            isPrivate: isPrivate,
            isPinned: false,
            profileID: activeProfileID,
            colorAccent: color
        )
        spaces.append(newSpace)
        return newSpace
    }

    public func pinSpaceToFirst(id: UUID) {
        guard let idx = spaces.firstIndex(where: { $0.id == id }) else { return }
        var space = spaces.remove(at: idx)
        space.isPinned = true
        spaces.insert(space, at: 0)
    }

    public func updateSpace(_ space: SpaceModel) {
        if let idx = spaces.firstIndex(where: { $0.id == space.id }) {
            spaces[idx] = space
        }
    }

    public func deleteSpace(id: UUID) {
        // Mover pestañas huérfanas al espacio general (nil)
        for i in 0..<tabs.count where tabs[i].spaceID == id {
            tabs[i].spaceID = nil
        }
        spaces.removeAll(where: { $0.id == id })
    }

    // MARK: - Search Records Management

    public func recordSearch(query: String, engine: SearchEngineType) {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        if let existingIdx = searchRecords.firstIndex(where: { $0.profileID == activeProfileID && $0.query.lowercased() == trimmed.lowercased() }) {
            searchRecords[existingIdx].timestamp = Date()
            searchRecords[existingIdx].visitCount += 1
            searchRecords[existingIdx].engine = engine
            let item = searchRecords.remove(at: existingIdx)
            searchRecords.insert(item, at: 0)
        } else {
            let record = SearchRecord(query: trimmed, engine: engine, profileID: activeProfileID)
            searchRecords.insert(record, at: 0)
        }

        // Mantener últimas 50 búsquedas
        if searchRecords.count > 50 {
            searchRecords = Array(searchRecords.prefix(50))
        }
    }

    public func recentSearches(limit: Int = 10) -> [SearchRecord] {
        searchRecords.filter { $0.profileID == activeProfileID }.prefix(limit).map { $0 }
    }

    public func clearSearches(forProfile profileID: UUID? = nil) {
        let targetID = profileID ?? activeProfileID
        searchRecords.removeAll(where: { $0.profileID == targetID })
    }

    public func deleteSearchRecord(id: UUID) {
        searchRecords.removeAll(where: { $0.id == id })
    }

    // MARK: - Browsing History Management

    public func recordVisit(url: URL, title: String, isSearch: Bool = false, query: String? = nil) {
        let entry = HistoryEntry(
            url: url,
            title: title.isEmpty ? (url.host ?? url.absoluteString) : title,
            visitDate: Date(),
            profileID: activeProfileID,
            isSearchQuery: isSearch,
            searchQuery: query
        )
        historyEntries.insert(entry, at: 0)

        // Limitar a 500 visitas
        if historyEntries.count > 500 {
            historyEntries = Array(historyEntries.prefix(500))
        }
    }

    public func historyForActiveProfile() -> [HistoryEntry] {
        historyEntries.filter { $0.profileID == activeProfileID }
    }

    public func clearHistory(forProfile profileID: UUID? = nil) {
        let targetID = profileID ?? activeProfileID
        historyEntries.removeAll(where: { $0.profileID == targetID })
    }

    public func deleteHistoryEntry(id: UUID) {
        historyEntries.removeAll(where: { $0.id == id })
    }

    // MARK: - Saved Sites Management

    public func savedSitesForActiveProfile() -> [SavedSite] {
        savedSites.filter { $0.profileID == activeProfileID }.sorted(by: { $0.position < $1.position })
    }

    public func addSavedSite(title: String, url: URL) {
        let existing = savedSitesForActiveProfile()
        let newSite = SavedSite(
            title: title,
            url: url,
            profileID: activeProfileID,
            position: existing.count
        )
        savedSites.append(newSite)
    }

    public func deleteSavedSite(id: UUID) {
        savedSites.removeAll(where: { $0.id == id })
    }

    public func updateSavedSite(_ site: SavedSite) {
        if let idx = savedSites.firstIndex(where: { $0.id == site.id }) {
            savedSites[idx] = site
        }
    }

    // MARK: - Factory Reset (Restablecer de Fábrica Todo)

    public func factoryResetAllData() {
        // 1. Limpiar Keychain
        KeychainVault.shared.wipeAllSecureData()

        // 2. Limpiar todos los datos persistentes de UserDefaults
        let keysToRemove = [
            profilesKey,
            activeProfileIDKey,
            tabsKey,
            spacesKey,
            searchRecordsKey,
            historyKey,
            savedSitesKey,
            onboardingKey,
            activeTabIDKey,
            "smartbot_app_language",
            "smartbot_theme_mode",
            "smartbot_theme_accent",
            "smartbot_default_search_engine"
        ]
        for key in keysToRemove {
            UserDefaults.standard.removeObject(forKey: key)
        }
        UserDefaults.standard.synchronize()

        // 3. Recrear estado limpio por defecto
        let defaultProfile = UserProfile.defaultPersonal()
        self.profiles = [defaultProfile]
        self.activeProfileID = defaultProfile.id

        self.spaces = SpaceModel.defaultSpaces(for: defaultProfile.id)
        let initialTab = TabModel(url: nil, title: "Nueva Pestaña", profileID: defaultProfile.id)
        self.tabs = [initialTab]
        self.activeTabID = initialTab.id

        self.searchRecords = []
        self.historyEntries = []
        self.savedSites = SavedSite.defaultSites(for: defaultProfile.id)
        self.hasCompletedOnboarding = false

        // Notificar respuesta háptica y reseteo
        HapticManager.shared.notifyWarning()
    }

    // MARK: - Internal JSON Persistence Helpers

    private func persistProfiles() {
        Self.saveJSON(profiles, forKey: profilesKey)
    }

    private func persistTabs() {
        Self.saveJSON(tabs, forKey: tabsKey)
    }

    private func persistSpaces() {
        Self.saveJSON(spaces, forKey: spacesKey)
    }

    private func persistSearches() {
        Self.saveJSON(searchRecords, forKey: searchRecordsKey)
    }

    private func persistHistory() {
        Self.saveJSON(historyEntries, forKey: historyKey)
    }

    private func persistSavedSites() {
        Self.saveJSON(savedSites, forKey: savedSitesKey)
    }

    private static func saveJSON<T: Encodable>(_ object: T, forKey key: String) {
        guard let data = try? JSONEncoder().encode(object) else { return }
        UserDefaults.standard.set(data, forKey: key)
    }

    private static func loadJSON<T: Decodable>(_ type: T.Type, forKey key: String) -> T? {
        guard let data = UserDefaults.standard.data(forKey: key) else { return nil }
        return try? JSONDecoder().decode(T.self, from: data)
    }
}
