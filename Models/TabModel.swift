import Foundation

// MARK: - TabModel

public struct TabModel: Identifiable, Codable, Equatable, Sendable {
    public let id: UUID
    public var url: URL?
    public var title: String
    public var customTitle: String?
    public var spaceID: UUID
    public var isPinned: Bool
    public var isPrivate: Bool
    public var lastAccessed: Date
    public var snapshotFileName: String?
    public var isSecure: Bool
    public var isDesktopMode: Bool
    public var forcedDarkMode: Bool

    public init(
        id: UUID = UUID(),
        url: URL? = nil,
        title: String = "Nueva Pestaña",
        customTitle: String? = nil,
        spaceID: UUID = UUID(),
        isPinned: Bool = false,
        isPrivate: Bool = false,
        lastAccessed: Date = Date(),
        snapshotFileName: String? = nil,
        isSecure: Bool = false,
        isDesktopMode: Bool = false,
        forcedDarkMode: Bool = false
    ) {
        self.id = id
        self.url = url
        self.title = title
        self.customTitle = customTitle
        self.spaceID = spaceID
        self.isPinned = isPinned
        self.isPrivate = isPrivate
        self.lastAccessed = lastAccessed
        self.snapshotFileName = snapshotFileName
        self.isSecure = isSecure
        self.isDesktopMode = isDesktopMode
        self.forcedDarkMode = forcedDarkMode
    }

    // MARK: - Computed Properties

    public var displayTitle: String {
        if let custom = customTitle, !custom.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return custom
        }
        if !title.isEmpty && title != "about:blank" {
            return title
        }
        if let host = url?.host {
            return host.replacingOccurrences(of: "www.", with: "")
        }
        return "Nueva Pestaña"
    }

    public var displayHost: String {
        guard let host = url?.host else { return "liquid://inicio" }
        return host.replacingOccurrences(of: "www.", with: "")
    }

    public var faviconURL: URL? {
        guard let host = url?.host else { return nil }
        return URL(string: "https://www.google.com/s2/favicons?domain=\(host)&sz=64")
    }
}
