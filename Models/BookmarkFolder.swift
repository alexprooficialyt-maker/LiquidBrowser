import Foundation

public struct BookmarkItem: Identifiable, Codable, Equatable, Sendable {
    public let id: UUID
    public var title: String
    public var url: URL
    public var folderID: UUID?
    public var createdAt: Date
    public var orderIndex: Int

    public init(
        id: UUID = UUID(),
        title: String,
        url: URL,
        folderID: UUID? = nil,
        createdAt: Date = Date(),
        orderIndex: Int = 0
    ) {
        self.id = id
        self.title = title
        self.url = url
        self.folderID = folderID
        self.createdAt = createdAt
        self.orderIndex = orderIndex
    }

    public var displayHost: String {
        url.host()?.replacingOccurrences(of: "www.", with: "") ?? url.absoluteString
    }
}

public struct BookmarkFolder: Identifiable, Codable, Equatable, Sendable {
    public let id: UUID
    public var name: String
    public var parentFolderID: UUID?
    public var createdAt: Date
    public var orderIndex: Int

    public init(
        id: UUID = UUID(),
        name: String,
        parentFolderID: UUID? = nil,
        createdAt: Date = Date(),
        orderIndex: Int = 0
    ) {
        self.id = id
        self.name = name
        self.parentFolderID = parentFolderID
        self.createdAt = createdAt
        self.orderIndex = orderIndex
    }

    public static let favoritesFolderID = UUID(uuidString: "10000000-0000-0000-0000-000000000001") ?? UUID()

    public static let favoritesFolder = BookmarkFolder(
        id: favoritesFolderID,
        name: "Favoritos Rápidos",
        orderIndex: 0
    )
}
