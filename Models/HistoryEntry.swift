import Foundation

// MARK: - HistoryEntry Model

public struct HistoryEntry: Identifiable, Codable, Sendable, Hashable {
    public let id: UUID
    public var url: URL
    public var title: String
    public var visitDate: Date
    public var profileID: UUID
    public var isSearchQuery: Bool
    public var searchQuery: String?

    public init(
        id: UUID = UUID(),
        url: URL,
        title: String,
        visitDate: Date = Date(),
        profileID: UUID,
        isSearchQuery: Bool = false,
        searchQuery: String? = nil
    ) {
        self.id = id
        self.url = url
        self.title = title
        self.visitDate = visitDate
        self.profileID = profileID
        self.isSearchQuery = isSearchQuery
        self.searchQuery = searchQuery
    }

    public var displayHost: String {
        url.host?.replacingOccurrences(of: "www.", with: "") ?? url.absoluteString
    }

    public var formattedTime: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        formatter.dateStyle = .none
        return formatter.string(from: visitDate)
    }

    public var formattedDate: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .none
        formatter.dateStyle = .medium
        return formatter.string(from: visitDate)
    }
}
