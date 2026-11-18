import SwiftUI

// MARK: - UserProfile Model (Sin campos obsoletos de edad o descripción)

public struct UserProfile: Identifiable, Codable, Sendable, Hashable {
    public let id: UUID
    public var name: String
    public var accentColor: ProfileAccentColor
    public var iconType: LiquidIconType
    public var hasPIN: Bool
    public var isLocked: Bool
    public var requiresBiometricsOrPIN: Bool
    public var isDefault: Bool
    public var createdAt: Date

    public init(
        id: UUID = UUID(),
        name: String,
        accentColor: ProfileAccentColor = .monochrome,
        iconType: LiquidIconType = .userProfile,
        hasPIN: Bool = false,
        isLocked: Bool = false,
        requiresBiometricsOrPIN: Bool = false,
        isDefault: Bool = false,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.accentColor = accentColor
        self.iconType = iconType
        self.hasPIN = hasPIN
        self.isLocked = isLocked
        self.requiresBiometricsOrPIN = requiresBiometricsOrPIN
        self.isDefault = isDefault
        self.createdAt = createdAt
    }

    // MARK: - Helper Getters

    public var displayName: String {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? "Personal" : trimmed
    }

    public var initials: String {
        let words = displayName.split(separator: " ")
        if let first = words.first?.first {
            if words.count > 1, let second = words.dropFirst().first?.first {
                return "\(first)\(second)".uppercased()
            }
            return String(first).uppercased()
        }
        return "P"
    }

    public var subtitleText: String {
        if isDefault {
            return Loc.tr("profile_default_badge")
        }
        return Loc.tr("profile_custom_badge")
    }

    // MARK: - Factory Defaults

    public static func defaultPersonal(
        name: String = "Personal",
        accent: ProfileAccentColor = .monochrome
    ) -> UserProfile {
        UserProfile(
            id: UUID(),
            name: name,
            accentColor: accent,
            iconType: .userProfile,
            hasPIN: false,
            isLocked: false,
            requiresBiometricsOrPIN: false,
            isDefault: true,
            createdAt: Date()
        )
    }
}
