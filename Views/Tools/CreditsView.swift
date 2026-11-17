import SwiftUI

// MARK: - CreditsView (Créditos y Autoría en Liquid Glass)

public struct CreditsView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme

    public init() {}

    public var body: some View {
        let theme = ThemeManager.shared

        NavigationView {
            ZStack {
                theme.background(for: colorScheme)
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 28) {
                        // Tarjeta Principal de Autoría en Cristal Líquido
                        authorCard(theme: theme)
                            .padding(.top, 24)
                            .padding(.horizontal, 20)

                        // Especificaciones de Ingeniería y Arquitectura
                        architectureSpecs(theme: theme)
                            .padding(.horizontal, 20)

                        // Manifiesto de Calidad y Cero Relleno
                        manifestoCard(theme: theme)
                            .padding(.horizontal, 20)

                        // Versión y Licencia
                        footerInfo(theme: theme)
                            .padding(.bottom, 32)
                    }
                }
            }
            .navigationTitle("Acerca de")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cerrar") {
                        HapticManager.shared.touchLight()
                        dismiss()
                    }
                    .font(.system(size: 15, weight: .medium, design: .rounded))
                    .foregroundStyle(theme.textPrimary(for: colorScheme))
                }
            }
        }
    }

    // MARK: - Tarjeta Principal de Autor

    @ViewBuilder
    private func authorCard(theme: ThemeManager) -> some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(theme.cardBackground(for: colorScheme))
                    .frame(width: 84, height: 84)
                    .overlay {
                        Circle().strokeBorder(theme.specularBorder(for: colorScheme), lineWidth: 1.0)
                    }

                LiquidIconView(.creditsAuthor, size: 44, color: theme.textPrimary(for: colorScheme))
            }
            .shadow(color: theme.shadowColor(for: colorScheme), radius: 12, y: 4)

            VStack(spacing: 6) {
                Text("Hecho por Rubén Aguilarte")
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .foregroundStyle(theme.textPrimary(for: colorScheme))
                    .multilineTextAlignment(.center)

                Text("Diseño de Sistemas y Arquitectura de Software")
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundStyle(theme.textSecondary(for: colorScheme))

                Text("LiquidBrowser — Native Liquid Glass Edition")
                    .font(.system(size: 12, design: .monospaced))
                    .foregroundStyle(theme.textTertiary(for: colorScheme))
                    .padding(.top, 2)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 28)
        .padding(.horizontal, 20)
        .liquidGlass(config: .card)
    }

    // MARK: - Especificaciones de Arquitectura

    @ViewBuilder
    private func architectureSpecs(theme: ThemeManager) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Arquitectura y Rendimiento")
                .font(.system(size: 13, weight: .semibold, design: .rounded))
                .foregroundStyle(theme.textSecondary(for: colorScheme))

            VStack(spacing: 10) {
                specRow(title: "Motor Web", value: "WebKit Multi-Instancia en RAM", icon: .desktopMode, theme: theme)
                specRow(title: "Iconografía", value: "45+ Curvas de Bézier a Mano", icon: .spaceCode, theme: theme)
                specRow(title: "Seguridad", value: "iOS Keychain Services + Face ID", icon: .lockSSL, theme: theme)
                specRow(title: "Diseño Visual", value: "Monocromo Puro & Liquid Glass", icon: .sliderAdjust, theme: theme)
                specRow(title: "Almacenamiento", value: "StorageEngine Atómico en Disco", icon: .download, theme: theme)
            }
            .padding(14)
            .liquidGlass(config: .card)
        }
    }

    @ViewBuilder
    private func specRow(title: String, value: String, icon: LiquidIconType, theme: ThemeManager) -> some View {
        HStack(spacing: 12) {
            LiquidIconView(icon, size: 16, color: theme.textPrimary(for: colorScheme))

            Text(title)
                .font(.system(size: 14, design: .rounded))
                .foregroundStyle(theme.textPrimary(for: colorScheme))

            Spacer()

            Text(value)
                .font(.system(size: 12, weight: .medium, design: .rounded))
                .foregroundStyle(theme.textSecondary(for: colorScheme))
        }
    }

    // MARK: - Manifiesto

    @ViewBuilder
    private func manifestoCard(theme: ThemeManager) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Principios de Diseño")
                .font(.system(size: 13, weight: .semibold, design: .rounded))
                .foregroundStyle(theme.textSecondary(for: colorScheme))

            Text("Construido sin dependencias de terceros, sin marcos externos y sin código de relleno. Cada vista, animación y trazo responde a los principios de ergonomía, privacidad estricta y velocidad nativa en dispositivos iOS.")
                .font(.system(size: 13, design: .rounded))
                .foregroundStyle(theme.textSecondary(for: colorScheme))
                .lineSpacing(4)
                .padding(16)
                .liquidGlass(config: .card)
        }
    }

    // MARK: - Footer

    @ViewBuilder
    private func footerInfo(theme: ThemeManager) -> some View {
        VStack(spacing: 4) {
            Text("Versión 1.0 (Build Producción)")
                .font(.system(size: 12, weight: .medium, design: .rounded))
                .foregroundStyle(theme.textTertiary(for: colorScheme))

            Text("Desarrollado para iPhone — iOS 17+")
                .font(.system(size: 11, design: .rounded))
                .foregroundStyle(theme.textTertiary(for: colorScheme))
        }
    }
}
