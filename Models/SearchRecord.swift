import Foundation

// MARK: - SearchRecord Model

public struct SearchRecord: Identifiable, Codable, Sendable, Hashable {
    public let id: UUID
    public var query: String
    public var engine: SearchEngineType
    public var profileID: UUID
    public var timestamp: Date
    public var visitCount: Int

    public init(
        id: UUID = UUID(),
        query: String,
        engine: SearchEngineType = .google,
        profileID: UUID,
        timestamp: Date = Date(),
        visitCount: Int = 1
    ) {
        self.id = id
        self.query = query
        self.engine = engine
        self.profileID = profileID
        self.timestamp = timestamp
        self.visitCount = visitCount
    }
}
