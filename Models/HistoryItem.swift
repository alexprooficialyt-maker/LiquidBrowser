import Foundation

// MARK: - HistoryItem

struct HistoryItem: Identifiable, Codable {
    let id: UUID
    var url: URL
    var title: String
    var visitedAt: Date
    var favicon: Data?

    init(id: UUID = UUID(), url: URL, title: String) {
        self.id        = id
        self.url       = url
        self.title     = title
        self.visitedAt = Date()
    }

    var displayHost: String {
        url.host?.replacingOccurrences(of: "www.", with: "") ?? url.absoluteString
    }
}

// MARK: - Agrupación por fecha

enum HistoryGroup: String, CaseIterable {
    case today     = "Hoy"
    case yesterday = "Ayer"
    case thisWeek  = "Esta semana"
    case older     = "Anterior"

    static func group(for date: Date) -> HistoryGroup {
        let cal  = Calendar.current
        let now  = Date()
        if cal.isDateInToday(date)     { return .today }
        if cal.isDateInYesterday(date) { return .yesterday }
        if let week = cal.dateInterval(of: .weekOfYear, for: now),
           week.contains(date)         { return .thisWeek }
        return .older
    }
}
