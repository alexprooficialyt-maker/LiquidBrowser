import Foundation

public struct SpaceModel: Identifiable, Codable, Equatable, Sendable {
    public let id: UUID
    public var name: String
    public var iconTypeRaw: String
    public var isPrivate: Bool
    public var isLocked: Bool
    public var createdAt: Date
    public var orderIndex: Int

    public init(
        id: UUID = UUID(),
        name: String,
        iconTypeRaw: String = "spaceFolder",
        isPrivate: Bool = false,
        isLocked: Bool = false,
        createdAt: Date = Date(),
        orderIndex: Int = 0
    ) {
        self.id = id
        self.name = name
        self.iconTypeRaw = iconTypeRaw
        self.isPrivate = isPrivate
        self.isLocked = isLocked
        self.createdAt = createdAt
        self.orderIndex = orderIndex
    }

    public static let defaultSpaceID = UUID(uuidString: "00000000-0000-0000-0000-000000000001") ?? UUID()
    public static let privateSpaceID = UUID(uuidString: "00000000-0000-0000-0000-000000000002") ?? UUID()

    public static let defaultSpace = SpaceModel(
        id: defaultSpaceID,
        name: "General",
        iconTypeRaw: "spaceFolder",
        isPrivate: false,
        isLocked: false,
        orderIndex: 0
    )

    public static let privateSpace = SpaceModel(
        id: privateSpaceID,
        name: "Privado",
        iconTypeRaw: "spacePrivate",
        isPrivate: true,
        isLocked: true,
        orderIndex: 99
    )
}
