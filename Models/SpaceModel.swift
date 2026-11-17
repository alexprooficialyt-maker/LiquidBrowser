import Foundation

// MARK: - SpaceModel

public struct SpaceModel: Identifiable, Codable, Equatable, Sendable {
    public let id: UUID
    public var name: String
    public var iconTypeRaw: String
    public var orderIndex: Int
    public var isPinned: Bool
    public var isPrivate: Bool
    public var createdAt: Date

    public init(
        id: UUID = UUID(),
        name: String,
        iconTypeRaw: String = "spaceFolder",
        orderIndex: Int = 0,
        isPinned: Bool = false,
        isPrivate: Bool = false,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.iconTypeRaw = iconTypeRaw
        self.orderIndex = orderIndex
        self.isPinned = isPinned
        self.isPrivate = isPrivate
        self.createdAt = createdAt
    }

    // Identificadores fijos para espacios predeterminados
    public static let defaultSpaceID = UUID(uuidString: "11111111-1111-1111-1111-111111111111")!
    public static let privateSpaceID = UUID(uuidString: "99999999-9999-9999-9999-999999999999")!

    public static let defaultSpace = SpaceModel(
        id: defaultSpaceID,
        name: "Principal",
        iconTypeRaw: "spaceFolder",
        orderIndex: 0,
        isPinned: true,
        isPrivate: false
    )

    public static let workSpace = SpaceModel(
        id: UUID(uuidString: "22222222-2222-2222-2222-222222222222")!,
        name: "Trabajo",
        iconTypeRaw: "spaceWork",
        orderIndex: 1,
        isPinned: false,
        isPrivate: false
    )

    public static let privateSpace = SpaceModel(
        id: privateSpaceID,
        name: "Privado",
        iconTypeRaw: "spacePrivate",
        orderIndex: 999,
        isPinned: false,
        isPrivate: true
    )
}
