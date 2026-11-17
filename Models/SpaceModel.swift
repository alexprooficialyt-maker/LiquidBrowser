import SwiftUI

// MARK: - SpaceModel

public struct SpaceModel: Identifiable, Codable, Sendable, Hashable {
    public let id: UUID
    public var name: String
    public var icon: LiquidIconType
    public var isPrivate: Bool
    public var isPinned: Bool
    public var profileID: UUID
    public var colorAccent: ProfileAccentColor
    public var createdAt: Date

    public init(
        id: UUID = UUID(),
        name: String,
        icon: LiquidIconType = .spaceFolder,
        isPrivate: Bool = false,
        isPinned: Bool = false,
        profileID: UUID,
        colorAccent: ProfileAccentColor = .monochrome,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.icon = icon
        self.isPrivate = isPrivate
        self.isPinned = isPinned
        self.profileID = profileID
        self.colorAccent = colorAccent
        self.createdAt = createdAt
    }

    public static func defaultSpaces(for profileID: UUID) -> [SpaceModel] {
        [
            SpaceModel(name: "General", icon: .spaceFolder, isPrivate: false, isPinned: true, profileID: profileID, colorAccent: .monochrome),
            SpaceModel(name: "Trabajo", icon: .spaceWork, isPrivate: false, isPinned: false, profileID: profileID, colorAccent: .titanium),
            SpaceModel(name: "Estudio", icon: .spaceStudy, isPrivate: false, isPinned: false, profileID: profileID, colorAccent: .sapphire),
            SpaceModel(name: "Código", icon: .spaceCode, isPrivate: false, isPinned: false, profileID: profileID, colorAccent: .emerald),
            SpaceModel(name: "Privado", icon: .spacePrivate, isPrivate: true, isPinned: false, profileID: profileID, colorAccent: .amethyst)
        ]
    }
}
