import SwiftUI

// MARK: - AntiSpyPrivacyDashboardView (Live Anti-Tracking & Privacy Control Panel)

public struct AntiSpyPrivacyDashboardView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var systemColorScheme

    @State private var engine = AntiTrackerEngine.shared

    public init() {}

    public var body: some View {
        let theme = ThemeManager.shared
        let scheme = theme.effectiveScheme(systemScheme: systemColorScheme)

        NavigationStack {
            ZStack {
                theme.background(for: scheme).ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 20) {
                        // 1. Escudo Principal & Contador en Vivo
                        mainShieldCard(theme: theme, scheme: scheme)

                        // 2. Protecciones Activas
                        activeProtectionsSection(theme: theme, scheme: scheme)

                        // 3. Dominios con Rastreadores Neutralizados
                        blockedDomainsSection(theme: theme, scheme: scheme)
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 16)
                }
            }
            .navigationTitle(Loc.tr("settings_privacy"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button(Loc.tr("done")) { dismiss() }
                        .foregroundStyle(theme.textPrimary(for: scheme))
                }
            }
        }
    }

    // MARK: - 1. Escudo Principal y Contador

    @ViewBuilder
    private func mainShieldCard(theme: ThemeManager, scheme: ColorScheme) -> some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(theme.surfaceElevated(for: scheme))
                    .frame(width: 88, height: 88)
                    .overlay {
                        Circle().strokeBorder(theme.borderSpecular(for: scheme), lineWidth: 0.5)
                    }

                AnimatedShieldIcon(isBlocking: engine.isShieldEnabledGlobally, blockedCount: engine.sessionTrackersBlocked, size: 44)
            }

            VStack(spacing: 4) {
                Text("\(engine.sessionTrackersBlocked)")
                    .font(.system(size: 42, weight: .bold, design: .rounded))
                    .foregroundStyle(theme.textPrimary(for: scheme))

                Text(Loc.tr("tracker_blocked_session"))
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(theme.textSecondary(for: scheme))
                    .multilineTextAlignment(.center)
            }

            Toggle("Escudo Anti-Espías Global", isOn: $engine.isShieldEnabledGlobally)
                .font(.system(size: 15, weight: .semibold, design: .rounded))
                .foregroundStyle(theme.textPrimary(for: scheme))
                .tint(theme.textPrimary(for: scheme))
                .padding(.top, 8)
                .padding(.horizontal, 8)
        }
        .padding(20)
        .frame(maxWidth: .infinity)
        .liquidGlassCard(cornerRadius: 22)
    }

    // MARK: - 2. Protecciones Activas

    @ViewBuilder
    private func activeProtectionsSection(theme: ThemeManager, scheme: ColorScheme) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Capas de Protección de Apple")
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(theme.textSecondary(for: scheme))
                .padding(.horizontal, 4)

            VStack(spacing: 12) {
                protectionRow(icon: .shieldBlocker, title: Loc.tr("tracker_cookie_shield"), desc: "Aislamiento total de cookies de seguimiento entre pestañas", theme: theme, scheme: scheme)
                Divider().background(theme.specularBorder(for: scheme))

                protectionRow(icon: .shieldActive, title: Loc.tr("tracker_fingerprint_shield"), desc: "Oculta parámetros de GPU y Canvas a scripts de perfilado", theme: theme, scheme: scheme)
                Divider().background(theme.specularBorder(for: scheme))

                protectionRow(icon: .stop, title: Loc.tr("tracker_adblock"), desc: "Filtro nativo de ventanas emergentes y redirecciones no solicitadas", theme: theme, scheme: scheme)
            }
            .padding(16)
            .liquidGlassCard(cornerRadius: 18)
        }
    }

    @ViewBuilder
    private func protectionRow(icon: LiquidIconType, title: String, desc: String, theme: ThemeManager, scheme: ColorScheme) -> some View {
        HStack(spacing: 14) {
            LiquidIconView(icon, size: 20, color: theme.textPrimary(for: scheme))

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundStyle(theme.textPrimary(for: scheme))

                Text(desc)
                    .font(.system(size: 12, weight: .regular))
                    .foregroundStyle(theme.textSecondary(for: scheme))
            }

            Spacer()

            LiquidIconView(.checkmark, size: 14, color: theme.textPrimary(for: scheme))
        }
    }

    // MARK: - 3. Dominios con Rastreadores Bloqueados

    @ViewBuilder
    private func blockedDomainsSection(theme: ThemeManager, scheme: ColorScheme) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Rastreadores Neutralizados por Sitio")
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(theme.textSecondary(for: scheme))
                .padding(.horizontal, 4)

            if engine.domainBlockedCount.isEmpty {
                HStack {
                    Text("No se han detectado rastreadores todavía en esta sesión.")
                        .font(.system(size: 13, weight: .regular))
                        .foregroundStyle(theme.textSecondary(for: scheme))
                    Spacer()
                }
                .padding(16)
                .liquidGlassCard(cornerRadius: 16)
            } else {
                VStack(spacing: 10) {
                    ForEach(Array(engine.domainBlockedCount.keys.sorted()), id: \.self) { domain in
                        HStack {
                            Text(domain)
                                .font(.system(size: 14, weight: .medium, design: .rounded))
                                .foregroundStyle(theme.textPrimary(for: scheme))

                            Spacer()

                            Text("\(engine.domainBlockedCount[domain] ?? 0) bloqueados")
                                .font(.system(size: 12, weight: .bold, design: .rounded))
                                .foregroundStyle(theme.textSecondary(for: scheme))
                                .padding(.horizontal, 10)
                                .padding(.vertical, 4)
                                .background(theme.surfaceElevated(for: scheme))
                                .clipShape(Capsule())
                        }
                    }
                }
                .padding(16)
                .liquidGlassCard(cornerRadius: 18)
            }
        }
    }
}
