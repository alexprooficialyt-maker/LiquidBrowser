import Foundation

// MARK: - BookmarkItem

public struct BookmarkItem: Identifiable, Codable, Equatable, Sendable {
    public let id: UUID
    public var title: String
    public var url: URL
    public var folderID: UUID?
    public var createdAt: Date

    public init(
        id: UUID = UUID(),
        title: String,
        url: URL,
        folderID: UUID? = nil,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.title = title
        self.url = url
        self.folderID = folderID
        self.createdAt = createdAt
    }

    public var displayTitle: String {
        title.isEmpty ? (url.host ?? url.absoluteString) : title
    }
}

// MARK: - BookmarkFolder

public struct BookmarkFolder: Identifiable, Codable, Equatable, Sendable {
    public let id: UUID
    public var name: String
    public var iconTypeRaw: String
    public var orderIndex: Int

    public init(
        id: UUID = UUID(),
        name: String,
        iconTypeRaw: String = "spaceFolder",
        orderIndex: Int = 0
    ) {
        self.id = id
        self.name = name
        self.iconTypeRaw = iconTypeRaw
        self.orderIndex = orderIndex
    }

    public static let favoritesFolderID = UUID(uuidString: "F0F0F0F0-0000-0000-0000-000000000001")!

    public static let favoritesFolder = BookmarkFolder(
        id: favoritesFolderID,
        name: "Favoritos",
        iconTypeRaw: "spaceStar",
        orderIndex: 0
    )
}
