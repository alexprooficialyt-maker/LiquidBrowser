import Foundation

// MARK: - HistoryPeriodGroup

public enum HistoryPeriodGroup: String, CaseIterable, Sendable {
    case today = "Hoy"
    case yesterday = "Ayer"
    case thisWeek = "Esta semana"
    case thisMonth = "Este mes"
    case older = "Más antiguo"

    public static func group(for date: Date) -> HistoryPeriodGroup {
        let calendar = Calendar.current
        if calendar.isDateInToday(date) { return .today }
        if calendar.isDateInYesterday(date) { return .yesterday }
        if let weekAgo = calendar.date(byAdding: .day, value: -7, to: Date()), date >= weekAgo {
            return .thisWeek
        }
        if let monthAgo = calendar.date(byAdding: .day, value: -30, to: Date()), date >= monthAgo {
            return .thisMonth
        }
        return .older
    }
}

// MARK: - HistoryEntry (Navegación Web)

public struct HistoryEntry: Identifiable, Codable, Equatable, Sendable {
    public let id: UUID
    public var url: URL
    public var title: String
    public var visitedAt: Date
    public var searchQuery: String?

    public init(
        id: UUID = UUID(),
        url: URL,
        title: String = "",
        visitedAt: Date = Date(),
        searchQuery: String? = nil
    ) {
        self.id = id
        self.url = url
        self.title = title
        self.visitedAt = visitedAt
        self.searchQuery = searchQuery
    }

    public var displayTitle: String {
        if !title.isEmpty { return title }
        return displayHost
    }

    public var displayHost: String {
        guard let host = url.host else { return url.absoluteString }
        return host.replacingOccurrences(of: "www.", with: "")
    }

    public var formattedTime: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: visitedAt)
    }
}

// MARK: - SearchHistoryEntry (Búsquedas Realizadas)

public struct SearchHistoryEntry: Identifiable, Codable, Equatable, Sendable {
    public let id: UUID
    public var query: String
    public var engineUsed: String
    public var timestamp: Date

    public init(
        id: UUID = UUID(),
        query: String,
        engineUsed: String = "Google",
        timestamp: Date = Date()
    ) {
        self.id = id
        self.query = query
        self.engineUsed = engineUsed
        self.timestamp = timestamp
    }
}
