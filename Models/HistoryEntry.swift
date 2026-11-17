import Foundation

public struct HistoryEntry: Identifiable, Codable, Equatable, Sendable {
    public let id: UUID
    public var url: URL
    public var title: String
    public var visitedAt: Date
    public var visitCount: Int

    public init(
        id: UUID = UUID(),
        url: URL,
        title: String,
        visitedAt: Date = Date(),
        visitCount: Int = 1
    ) {
        self.id = id
        self.url = url
        self.title = title
        self.visitedAt = visitedAt
        self.visitCount = visitCount
    }

    public var displayHost: String {
        url.host()?.replacingOccurrences(of: "www.", with: "") ?? url.absoluteString
    }

    public var displayTitle: String {
        let trimmed = title.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? displayHost : trimmed
    }
}

public enum HistoryPeriodGroup: String, CaseIterable, Identifiable, Sendable {
    case today = "Hoy"
    case yesterday = "Ayer"
    case thisWeek = "Esta semana"
    case thisMonth = "Este mes"
    case older = "Anteriores"

    public var id: String { rawValue }

    public static func group(for date: Date) -> HistoryPeriodGroup {
        let calendar = Calendar.current
        let now = Date()

        if calendar.isDateInToday(date) {
            return .today
        }
        if calendar.isDateInYesterday(date) {
            return .yesterday
        }
        if let weekInterval = calendar.dateInterval(of: .weekOfYear, for: now), weekInterval.contains(date) {
            return .thisWeek
        }
        if let monthInterval = calendar.dateInterval(of: .month, for: now), monthInterval.contains(date) {
            return .thisMonth
        }
        return .older
    }
}
