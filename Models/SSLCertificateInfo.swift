import Foundation

// MARK: - SSLCertificateInfo Model

public struct SSLCertificateInfo: Identifiable, Codable, Sendable, Hashable {
    public let id: UUID
    public var domain: String
    public var isSecure: Bool
    public var protocolTLS: String
    public var cipherSuite: String
    public var issuer: String
    public var validFrom: Date?
    public var validTo: Date?
    public var isAppleTrusted: Bool
    public var blockedTrackersCount: Int
    public var isTrackerShieldEnabled: Bool

    public init(
        id: UUID = UUID(),
        domain: String,
        isSecure: Bool = true,
        protocolTLS: String = "TLS 1.3",
        cipherSuite: String = "ChaCha20-Poly1305 / AES-GCM",
        issuer: String = "Apple Public CA / Let's Encrypt",
        validFrom: Date? = nil,
        validTo: Date? = nil,
        isAppleTrusted: Bool = true,
        blockedTrackersCount: Int = 0,
        isTrackerShieldEnabled: Bool = true
    ) {
        self.id = id
        self.domain = domain
        self.isSecure = isSecure
        self.protocolTLS = protocolTLS
        self.cipherSuite = cipherSuite
        self.issuer = issuer
        self.validFrom = validFrom
        self.validTo = validTo
        self.isAppleTrusted = isAppleTrusted
        self.blockedTrackersCount = blockedTrackersCount
        self.isTrackerShieldEnabled = isTrackerShieldEnabled
    }

    public static func placeholder(domain: String) -> SSLCertificateInfo {
        SSLCertificateInfo(
            domain: domain,
            isSecure: true,
            protocolTLS: "TLS 1.3 (Cifrado de Alta Seguridad)",
            cipherSuite: "TLS_AES_256_GCM_SHA384",
            issuer: "Certificado Raíz Autorizado de Apple",
            validFrom: Date(),
            validTo: Calendar.current.date(byAdding: .year, value: 1, to: Date()),
            isAppleTrusted: true,
            blockedTrackersCount: 0,
            isTrackerShieldEnabled: true
        )
    }
}
