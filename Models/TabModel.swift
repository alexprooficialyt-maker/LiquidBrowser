import Foundation

// MARK: - TabModel

public struct TabModel: Identifiable, Codable, Sendable, Hashable {
    public let id: UUID
    public var url: URL?
    public var title: String
    public var isPinned: Bool
    public var spaceID: UUID?
    public var profileID: UUID
    public var isPrivate: Bool
    public var createdAt: Date
    public var lastAccessedAt: Date

    public init(
        id: UUID = UUID(),
        url: URL? = nil,
        title: String = "Nueva Pestaña",
        isPinned: Bool = false,
        spaceID: UUID? = nil,
        profileID: UUID,
        isPrivate: Bool = false,
        createdAt: Date = Date(),
        lastAccessedAt: Date = Date()
    ) {
        self.id = id
        self.url = url
        self.title = title
        self.isPinned = isPinned
        self.spaceID = spaceID
        self.profileID = profileID
        self.isPrivate = isPrivate
        self.createdAt = createdAt
        self.lastAccessedAt = lastAccessedAt
    }

    public var displayTitle: String {
        if !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return title
        }
        if let host = url?.host {
            return host.replacingOccurrences(of: "www.", with: "")
        }
        return "Nueva Pestaña"
    }

    public var displayHost: String {
        url?.host?.replacingOccurrences(of: "www.", with: "") ?? ""
    }

    public var isNewTab: Bool {
        url == nil || url?.absoluteString.isEmpty == true
    }
}
