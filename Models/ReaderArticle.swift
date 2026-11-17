import Foundation

public struct ReaderArticle: Identifiable, Codable, Equatable, Sendable {
    public let id: UUID
    public var url: URL
    public var title: String
    public var byline: String?
    public var siteName: String?
    public var contentHTML: String
    public var textContent: String
    public var excerpt: String
    public var savedAt: Date
    public var readingTimeMinutes: Int

    public init(
        id: UUID = UUID(),
        url: URL,
        title: String,
        byline: String? = nil,
        siteName: String? = nil,
        contentHTML: String,
        textContent: String,
        excerpt: String,
        savedAt: Date = Date(),
        readingTimeMinutes: Int = 1
    ) {
        self.id = id
        self.url = url
        self.title = title
        self.byline = byline
        self.siteName = siteName
        self.contentHTML = contentHTML
        self.textContent = textContent
        self.excerpt = excerpt
        self.savedAt = savedAt
        self.readingTimeMinutes = readingTimeMinutes
    }

    public static func estimateReadingMinutes(from text: String) -> Int {
        let words = text.components(separatedBy: .whitespacesAndNewlines).filter { !$0.isEmpty }.count
        return max(1, Int(ceil(Double(words) / 200.0)))
    }
}
