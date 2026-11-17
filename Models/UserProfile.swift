import SwiftUI

// MARK: - UserProfile Model

public struct UserProfile: Identifiable, Codable, Sendable, Hashable {
    public let id: UUID
    public var name: String
    public var age: Int?
    public var description: String
    public var accentColor: ProfileAccentColor
    public var iconType: LiquidIconType
    public var hasPIN: Bool
    public var isDefault: Bool
    public var createdAt: Date

    public init(
        id: UUID = UUID(),
        name: String,
        age: Int? = nil,
        description: String = "",
        accentColor: ProfileAccentColor = .monochrome,
        iconType: LiquidIconType = .userProfile,
        hasPIN: Bool = false,
        isDefault: Bool = false,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.age = age
        self.description = description
        self.accentColor = accentColor
        self.iconType = iconType
        self.hasPIN = hasPIN
        self.isDefault = isDefault
        self.createdAt = createdAt
    }

    public static func defaultPersonal(name: String = "Personal", age: Int? = nil, accent: ProfileAccentColor = .monochrome) -> UserProfile {
        UserProfile(
            id: UUID(),
            name: name,
            age: age,
            description: "Perfil Principal de Navegación",
            accentColor: accent,
            iconType: .userProfile,
            hasPIN: false,
            isDefault: true,
            createdAt: Date()
        )
    }
}
