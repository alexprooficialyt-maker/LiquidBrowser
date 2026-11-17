import Foundation

// MARK: - Space (Carpeta de pestañas)

struct Space: Identifiable, Codable, Equatable {
    let id: UUID
    var name: String
    var emoji: String
    var tabIDs: [UUID]
    var createdAt: Date

    init(id: UUID = UUID(), name: String, emoji: String = "🗂️") {
        self.id        = id
        self.name      = name
        self.emoji     = emoji
        self.tabIDs    = []
        self.createdAt = Date()
    }

    static let `default` = Space(id: UUID(), name: "Principal", emoji: "🌐")
}
