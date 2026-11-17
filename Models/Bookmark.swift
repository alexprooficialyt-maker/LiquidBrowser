import Foundation

// MARK: - Bookmark

struct Bookmark: Identifiable, Codable {
    let id: UUID
    var title: String
    var url: URL
    var favicon: Data?
    var folderID: UUID?
    var createdAt: Date

    init(id: UUID = UUID(), title: String, url: URL, folderID: UUID? = nil) {
        self.id        = id
        self.title     = title
        self.url       = url
        self.folderID  = folderID
        self.createdAt = Date()
    }
}

// MARK: - BookmarkFolder

struct BookmarkFolder: Identifiable, Codable {
    let id: UUID
    var name: String
    var createdAt: Date

    init(id: UUID = UUID(), name: String) {
        self.id        = id
        self.name      = name
        self.createdAt = Date()
    }
}
