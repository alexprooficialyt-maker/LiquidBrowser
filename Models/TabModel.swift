import Foundation
import UIKit

public struct TabModel: Identifiable, Codable, Equatable, Sendable {
    public let id: UUID
    public var url: URL?
    public var title: String
    public var isPinned: Bool
    public var isPrivate: Bool
    public var spaceID: UUID
    public var lastAccessed: Date
    public var createdAt: Date
    public var snapshotFileName: String?

    public init(
        id: UUID = UUID(),
        url: URL? = nil,
        title: String = "Nueva Pestaña",
        isPinned: Bool = false,
        isPrivate: Bool = false,
        spaceID: UUID,
        lastAccessed: Date = Date(),
        createdAt: Date = Date(),
        snapshotFileName: String? = nil
    ) {
        self.id = id
        self.url = url
        self.title = title
        self.isPinned = isPinned
        self.isPrivate = isPrivate
        self.spaceID = spaceID
        self.lastAccessed = lastAccessed
        self.createdAt = createdAt
        self.snapshotFileName = snapshotFileName
    }

    public var displayTitle: String {
        if !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && title != "Nueva Pestaña" {
            return title
        }
        if let host = url?.host() {
            return host.replacingOccurrences(of: "www.", with: "")
        }
        return "Nueva Pestaña"
    }

    public var displayHost: String {
        guard let host = url?.host() else { return "liquid://inicio" }
        return host.replacingOccurrences(of: "www.", with: "")
    }

    public var isSecure: Bool {
        url?.scheme?.lowercased() == "https"
    }

    public static func == (lhs: TabModel, rhs: TabModel) -> Bool {
        lhs.id == rhs.id &&
        lhs.url == rhs.url &&
        lhs.title == rhs.title &&
        lhs.isPinned == rhs.isPinned &&
        lhs.isPrivate == rhs.isPrivate &&
        lhs.spaceID == rhs.spaceID &&
        lhs.snapshotFileName == rhs.snapshotFileName
    }
}
