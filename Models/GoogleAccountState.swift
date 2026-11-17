import Foundation

// MARK: - GoogleAccountState

public struct GoogleAccountState: Codable, Equatable, Sendable {
    public var isSignedIn: Bool
    public var userEmail: String?
    public var displayName: String?
    public var avatarURL: URL?

    public init(
        isSignedIn: Bool = false,
        userEmail: String? = nil,
        displayName: String? = nil,
        avatarURL: URL? = nil
    ) {
        self.isSignedIn = isSignedIn
        self.userEmail = userEmail
        self.displayName = displayName
        self.avatarURL = avatarURL
    }

    public var initials: String {
        guard let name = displayName, !name.isEmpty else {
            if let email = userEmail, !email.isEmpty {
                return String(email.prefix(1)).uppercased()
            }
            return "G"
        }
        let parts = name.split(separator: " ")
        if parts.count >= 2 {
            return (String(parts[0].prefix(1)) + String(parts[1].prefix(1))).uppercased()
        }
        return String(name.prefix(1)).uppercased()
    }
}
