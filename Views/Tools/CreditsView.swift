import SwiftUI

// MARK: - CreditsView (SmartBot Browser Apple-Grade Credits)

public struct CreditsView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var systemColorScheme

    public init() {}

    public var body: some View {
        let theme = ThemeManager.shared
        let scheme = theme.effectiveScheme(systemScheme: systemColorScheme)

        NavigationStack {
            ZStack {
                theme.background(for: scheme).ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {
                        // 1. Icono y Versión Central
                        VStack(spacing: 12) {
                            ZStack {
                                Circle()
                                    .fill(theme.surfaceElevated(for: scheme))
                                    .frame(width: 84, height: 84)
                                    .overlay {
                                        Circle().strokeBorder(theme.borderSpecular(for: scheme), lineWidth: 0.5)
                                    }

                                LiquidIconView(.shieldActive, size: 40, color: theme.textPrimary(for: scheme))
                            }

                            VStack(spacing: 4) {
                                Text("SmartBot Browser")
                                    .font(.system(size: 24, weight: .bold, design: .rounded))
                                    .foregroundStyle(theme.textPrimary(for: scheme))

                                Text("Versión 1.0.0 (Build Producción)")
                                    .font(.system(size: 13, weight: .regular))
                                    .foregroundStyle(theme.textSecondary(for: scheme))
                            }
                        }
                        .padding(.top, 16)

                        // 2. Tarjeta Destacada de Autoría Oficial
                        VStack(spacing: 8) {
                            Text(Loc.tr("credits_author_label").uppercased())
                                .font(.system(size: 11, weight: .semibold, design: .monospaced))
                                .foregroundStyle(theme.textSecondary(for: scheme))
                                .tracking(1.5)

                            Text("Hecho por Rubén Aguilarte")
                                .font(.system(size: 22, weight: .bold, design: .rounded))
                                .foregroundStyle(theme.textPrimary(for: scheme))

                            Text("Arquitecto Principal de iOS & Diseñador de Sistemas")
                                .font(.system(size: 13, weight: .medium))
                                .foregroundStyle(theme.textSecondary(for: scheme))
                        }
                        .padding(20)
                        .frame(maxWidth: .infinity)
                        .liquidGlassCard(cornerRadius: 20)

                        // 3. Especificaciones de Ingeniería y Privacidad
                        VStack(alignment: .leading, spacing: 14) {
                            Text(Loc.tr("credits_tech_title"))
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundStyle(theme.textSecondary(for: scheme))
                                .padding(.horizontal, 4)

                            VStack(spacing: 12) {
                                specRow(title: "Lenguaje y Framework", value: "Swift 5.9 + SwiftUI Nativo", theme: theme, scheme: scheme)
                                Divider().background(theme.specularBorder(for: scheme))

                                specRow(title: "Motor Web", value: "WebKit Aislado en Memoria", theme: theme, scheme: scheme)
                                Divider().background(theme.specularBorder(for: scheme))

                                specRow(title: "Seguridad y Cifrado", value: "Apple Secure Enclave + Keychain", theme: theme, scheme: scheme)
                                Divider().background(theme.specularBorder(for: scheme))

                                specRow(title: "Aceleración Gráfica", value: "Metal GPU + Liquid Glass", theme: theme, scheme: scheme)
                                Divider().background(theme.specularBorder(for: scheme))

                                specRow(title: "Privacidad", value: "Sin telemetría externa ni rastreo", theme: theme, scheme: scheme)
                            }
                            .padding(16)
                            .liquidGlassCard(cornerRadius: 18)
                        }

                        // 4. Manifiesto de Diseño
                        Text(Loc.tr("credits_tech_desc"))
                            .font(.system(size: 12, weight: .regular))
                            .foregroundStyle(theme.textTertiary(for: scheme))
                            .multilineTextAlignment(.center)
                            .lineSpacing(3)
                            .padding(.horizontal, 16)
                            .padding(.bottom, 24)
                    }
                    .padding(.horizontal, 20)
                }
            }
            .navigationTitle(Loc.tr("credits_title"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button(Loc.tr("done")) { dismiss() }
                        .foregroundStyle(theme.textPrimary(for: scheme))
                }
            }
        }
    }

    @ViewBuilder
    private func specRow(title: String, value: String, theme: ThemeManager, scheme: ColorScheme) -> some View {
        HStack {
            Text(title)
                .font(.system(size: 13, weight: .regular))
                .foregroundStyle(theme.textSecondary(for: scheme))

            Spacer()

            Text(value)
                .font(.system(size: 13, weight: .medium, design: .rounded))
                .foregroundStyle(theme.textPrimary(for: scheme))
        }
    }
}
