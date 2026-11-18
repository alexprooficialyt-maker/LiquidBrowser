import Foundation

// MARK: - SavedSite Model (Páginas Favoritas con Soporte de Favicon Oficial)

public struct SavedSite: Identifiable, Codable, Sendable, Hashable {
    public let id: UUID
    public var title: String
    public var url: URL
    public var iconName: String?
    public var profileID: UUID
    public var position: Int
    public var createdAt: Date

    public init(
        id: UUID = UUID(),
        title: String,
        url: URL,
        iconName: String? = nil,
        profileID: UUID,
        position: Int = 0,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.title = title
        self.url = url
        self.iconName = iconName
        self.profileID = profileID
        self.position = position
        self.createdAt = createdAt
    }

    public var displayHost: String {
        guard let host = url.host else { return url.absoluteString }
        return host.replacingOccurrences(of: "www.", with: "")
    }

    public var domain: String {
        displayHost
    }

    /// URL para descarga directa de Favicon en alta resolución desde Google S2
    public var googleFaviconURL: URL? {
        guard let host = url.host else { return nil }
        return URL(string: "https://www.google.com/s2/favicons?domain=\(host)&sz=128")
    }

    /// URL del favicon nativo del sitio
    public var directFaviconURL: URL? {
        guard let scheme = url.scheme, let host = url.host else { return nil }
        return URL(string: "\(scheme)://\(host)/favicon.ico")
    }

    /// Sitios Predeterminados de SmartBot Browser (Apple, Wikipedia, GitHub, YouTube)
    public static func defaultSites(for profileID: UUID) -> [SavedSite] {
        [
            SavedSite(
                title: "Apple",
                url: URL(string: "https://www.apple.com")!,
                profileID: profileID,
                position: 0
            ),
            SavedSite(
                title: "Wikipedia",
                url: URL(string: "https://es.wikipedia.org")!,
                profileID: profileID,
                position: 1
            ),
            SavedSite(
                title: "GitHub",
                url: URL(string: "https://github.com")!,
                profileID: profileID,
                position: 2
            ),
            SavedSite(
                title: "YouTube",
                url: URL(string: "https://www.youtube.com")!,
                profileID: profileID,
                position: 3
            )
        ]
    }
}
