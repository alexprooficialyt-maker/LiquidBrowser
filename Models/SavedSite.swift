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
        let sites: [(String, String, Int)] = [
            ("Apple", "https://www.apple.com", 0),
            ("Wikipedia", "https://es.wikipedia.org", 1),
            ("GitHub", "https://github.com", 2),
            ("YouTube", "https://www.youtube.com", 3)
        ]
        return sites.compactMap { title, urlString, pos in
            guard let validURL = URL(string: urlString) else { return nil }
            return SavedSite(title: title, url: validURL, profileID: profileID, position: pos)
        }
    }
}
