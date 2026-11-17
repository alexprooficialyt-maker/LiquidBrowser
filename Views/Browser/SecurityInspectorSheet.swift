import SwiftUI

// MARK: - SecurityInspectorSheet (Apple SSL Certificate & Anti-Spy Inspector)

public struct SecurityInspectorSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var systemColorScheme

    public let info: SSLCertificateInfo
    public var onToggleShield: (String) -> Void

    @State private var isShieldActive: Bool

    public init(info: SSLCertificateInfo, onToggleShield: @escaping (String) -> Void = { _ in }) {
        self.info = info
        self.onToggleShield = onToggleShield
        self._isShieldActive = State(initialValue: info.isTrackerShieldEnabled)
    }

    public var body: some View {
        let theme = ThemeManager.shared
        let scheme = theme.effectiveScheme(systemScheme: systemColorScheme)

        NavigationStack {
            ZStack {
                theme.background(for: scheme)
                    .ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 20) {
                        // Header de Estado de Conexión
                        connectionStatusHeader(theme: theme, scheme: scheme)

                        // Escudo Anti-Espías y Rastreadores
                        antiTrackerSection(theme: theme, scheme: scheme)

                        // Detalles Técnicos del Certificado
                        certificateDetailsSection(theme: theme, scheme: scheme)

                        // Explicación de Seguridad
                        securityExplanationCard(theme: theme, scheme: scheme)
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 16)
                }
            }
            .navigationTitle(Loc.tr("ssl_inspector_title"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button(Loc.tr("done")) {
                        HapticManager.shared.touchLight()
                        dismiss()
                    }
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(theme.textPrimary(for: scheme))
                }
            }
        }
    }

    // MARK: - Cabecera de Estado de Conexión

    @ViewBuilder
    private func connectionStatusHeader(theme: ThemeManager, scheme: ColorScheme) -> some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(info.isSecure ? theme.surfaceElevated(for: scheme) : Color.red.opacity(0.12))
                    .frame(width: 68, height: 68)

                if info.isSecure {
                    LiquidIconView(.lockSSL, size: 32, color: theme.textPrimary(for: scheme))
                } else {
                    LiquidIconView(.warningSSL, size: 32, color: Color.red)
                }
            }

            VStack(spacing: 4) {
                Text(info.domain)
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundStyle(theme.textPrimary(for: scheme))

                Text(info.isSecure ? Loc.tr("ssl_secure_connection") : Loc.tr("ssl_insecure_connection"))
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(info.isSecure ? theme.textSecondary(for: scheme) : Color.red)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 18)
        .liquidGlassCard(cornerRadius: 20)
    }

    // MARK: - Sección Anti-Espías y Rastreadores

    @ViewBuilder
    private func antiTrackerSection(theme: ThemeManager, scheme: ColorScheme) -> some View {
        VStack(spacing: 14) {
            HStack(spacing: 14) {
                AnimatedShieldIcon(isBlocking: isShieldActive, blockedCount: info.blockedTrackersCount, size: 26)

                VStack(alignment: .leading, spacing: 2) {
                    Text(Loc.tr("ssl_anti_tracker"))
                        .font(.system(size: 15, weight: .semibold, design: .rounded))
                        .foregroundStyle(theme.textPrimary(for: scheme))

                    Text(Loc.tr("ssl_anti_tracker_desc"))
                        .font(.system(size: 12, weight: .regular))
                        .foregroundStyle(theme.textSecondary(for: scheme))
                }

                Spacer()

                Toggle("", isOn: $isShieldActive)
                    .labelsHidden()
                    .tint(theme.textPrimary(for: scheme))
                    .onChange(of: isShieldActive) { _, active in
                        HapticManager.shared.touchSelection()
                        AntiTrackerEngine.shared.toggleShield(for: info.domain)
                        onToggleShield(info.domain)
                    }
            }

            Divider()
                .background(theme.specularBorder(for: scheme))

            HStack {
                Text(Loc.tr("tracker_blocked_page"))
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(theme.textSecondary(for: scheme))

                Spacer()

                Text("\(info.blockedTrackersCount)")
                    .font(.system(size: 15, weight: .bold, design: .rounded))
                    .foregroundStyle(theme.textPrimary(for: scheme))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(theme.surfaceElevated(for: scheme))
                    .clipShape(Capsule())
            }
        }
        .padding(16)
        .liquidGlassCard(cornerRadius: 18)
    }

    // MARK: - Sección de Detalles Técnicos del Certificado

    @ViewBuilder
    private func certificateDetailsSection(theme: ThemeManager, scheme: ColorScheme) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Certificado de Seguridad")
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(theme.textSecondary(for: scheme))
                .padding(.horizontal, 4)

            VStack(spacing: 12) {
                detailRow(label: Loc.tr("ssl_protocol"), value: info.protocolTLS, theme: theme, scheme: scheme)
                Divider().background(theme.specularBorder(for: scheme))

                detailRow(label: Loc.tr("ssl_cipher"), value: info.cipherSuite, theme: theme, scheme: scheme)
                Divider().background(theme.specularBorder(for: scheme))

                detailRow(label: Loc.tr("ssl_issuer"), value: info.issuer, theme: theme, scheme: scheme)
                Divider().background(theme.specularBorder(for: scheme))

                if let validTo = info.validTo {
                    let formatter = DateFormatter()
                    formatter.dateStyle = .medium
                    let dateStr = formatter.string(from: validTo)
                    detailRow(label: Loc.tr("ssl_validity"), value: "Hasta \(dateStr)", theme: theme, scheme: scheme)
                    Divider().background(theme.specularBorder(for: scheme))
                }

                HStack {
                    Text("Confianza de Apple")
                        .font(.system(size: 13, weight: .regular))
                        .foregroundStyle(theme.textSecondary(for: scheme))

                    Spacer()

                    HStack(spacing: 6) {
                        Circle()
                            .fill(info.isAppleTrusted ? Color.green : Color.orange)
                            .frame(width: 8, height: 8)

                        Text(info.isAppleTrusted ? Loc.tr("ssl_trusted") : Loc.tr("ssl_untrusted"))
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(theme.textPrimary(for: scheme))
                    }
                }
            }
            .padding(16)
            .liquidGlassCard(cornerRadius: 18)
        }
    }

    @ViewBuilder
    private func detailRow(label: String, value: String, theme: ThemeManager, scheme: ColorScheme) -> some View {
        HStack(alignment: .top) {
            Text(label)
                .font(.system(size: 13, weight: .regular))
                .foregroundStyle(theme.textSecondary(for: scheme))

            Spacer()

            Text(value)
                .font(.system(size: 13, weight: .medium, design: .rounded))
                .foregroundStyle(theme.textPrimary(for: scheme))
                .multilineTextAlignment(.trailing)
        }
    }

    // MARK: - Explicación de Seguridad

    @ViewBuilder
    private func securityExplanationCard(theme: ThemeManager, scheme: ColorScheme) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(info.isSecure ? "Tus datos están protegidos" : "Precaución al navegar")
                .font(.system(size: 13, weight: .semibold, design: .rounded))
                .foregroundStyle(theme.textPrimary(for: scheme))

            Text(info.isSecure ?
                 "SmartBot Browser ha verificado que los datos transmitidos entre este dispositivo y \(info.domain) están completamente cifrados y no pueden ser leídos por intermediarios." :
                 "Este sitio web no utiliza cifrado HTTPS moderno. Las contraseñas, mensajes o información bancaria introducidos podrían ser interceptados en redes Wi-Fi públicas.")
                .font(.system(size: 12, weight: .regular))
                .foregroundStyle(theme.textSecondary(for: scheme))
                .lineSpacing(2)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .liquidGlassCard(cornerRadius: 16)
    }
}
