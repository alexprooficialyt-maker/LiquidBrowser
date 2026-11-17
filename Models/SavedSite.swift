import Foundation

// MARK: - SavedSite Model (Páginas Guardadas y Favoritos)

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
        url.host?.replacingOccurrences(of: "www.", with: "") ?? url.absoluteString
    }

    public static func defaultSites(for profileID: UUID) -> [SavedSite] {
        [
            SavedSite(title: "Apple", url: URL(string: "https://www.apple.com")!, profileID: profileID, position: 0),
            SavedSite(title: "Wikipedia", url: URL(string: "https://es.wikipedia.org")!, profileID: profileID, position: 1),
            SavedSite(title: "GitHub", url: URL(string: "https://github.com")!, profileID: profileID, position: 2),
            SavedSite(title: "Hacker News", url: URL(string: "https://news.ycombinator.com")!, profileID: profileID, position: 3)
        ]
    }
}
