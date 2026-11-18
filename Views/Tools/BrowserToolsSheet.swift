import SwiftUI

// MARK: - BrowserToolsSheet (Comprehensive Modular Safari Tools Menu)

public struct BrowserToolsSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var systemColorScheme

    public var coordinator: WebEngineCoordinator
    public var onOpenReader: () -> Void
    public var onOpenFindInPage: () -> Void
    public var onOpenQR: () -> Void
    public var onExportPDF: () -> Void
    public var onOpenHistory: () -> Void
    public var onOpenBookmarks: () -> Void
    public var onOpenDownloads: () -> Void
    public var onOpenPasswordVault: () -> Void
    public var onOpenAntiSpy: () -> Void
    public var onOpenSettings: () -> Void
    public var onOpenAbout: () -> Void
    public var onShare: () -> Void

    public init(
        coordinator: WebEngineCoordinator,
        onOpenReader: @escaping () -> Void = {},
        onOpenFindInPage: @escaping () -> Void = {},
        onOpenQR: @escaping () -> Void = {},
        onExportPDF: @escaping () -> Void = {},
        onOpenHistory: @escaping () -> Void = {},
        onOpenBookmarks: @escaping () -> Void = {},
        onOpenDownloads: @escaping () -> Void = {},
        onOpenPasswordVault: @escaping () -> Void = {},
        onOpenAntiSpy: @escaping () -> Void = {},
        onOpenSettings: @escaping () -> Void = {},
        onOpenAbout: @escaping () -> Void = {},
        onShare: @escaping () -> Void = {}
    ) {
        self.coordinator = coordinator
        self.onOpenReader = onOpenReader
        self.onOpenFindInPage = onOpenFindInPage
        self.onOpenQR = onOpenQR
        self.onExportPDF = onExportPDF
        self.onOpenHistory = onOpenHistory
        self.onOpenBookmarks = onOpenBookmarks
        self.onOpenDownloads = onOpenDownloads
        self.onOpenPasswordVault = onOpenPasswordVault
        self.onOpenAntiSpy = onOpenAntiSpy
        self.onOpenSettings = onOpenSettings
        self.onOpenAbout = onOpenAbout
        self.onShare = onShare
    }

    public var body: some View {
        let theme = ThemeManager.shared
        let scheme = theme.effectiveScheme(systemScheme: systemColorScheme)

        NavigationStack {
            ZStack {
                theme.background(for: scheme).ignoresSafeArea()

                List {
                    // Sección 1: Lectura y Utilidades de Página
                    Section {
                        Button {
                            dismiss()
                            onOpenReader()
                        } label: {
                            toolRow(icon: .readerMode, title: Loc.tr("tools_reader_mode"), theme: theme, scheme: scheme)
                        }

                        Button {
                            dismiss()
                            onOpenFindInPage()
                        } label: {
                            toolRow(icon: .search, title: Loc.tr("tools_find_in_page"), theme: theme, scheme: scheme)
                        }

                        Button {
                            coordinator.toggleDarkMode()
                        } label: {
                            toolRow(
                                icon: .palette,
                                title: coordinator.isDarkModeInjected ? "Desactivar Web Oscura" : Loc.tr("tools_force_dark"),
                                theme: theme,
                                scheme: scheme
                            )
                        }

                        Button {
                            dismiss()
                            onOpenQR()
                        } label: {
                            toolRow(icon: .qrCode, title: Loc.tr("tools_qr_code"), theme: theme, scheme: scheme)
                        }

                        Button {
                            dismiss()
                            onExportPDF()
                        } label: {
                            toolRow(icon: .pdfExport, title: Loc.tr("tools_pdf_export"), theme: theme, scheme: scheme)
                        }
                    }

                    // Sección 2: Navegación y Bóveda de Datos
                    Section {
                        Button {
                            dismiss()
                            onOpenHistory()
                        } label: {
                            toolRow(icon: .history, title: Loc.tr("tools_history"), theme: theme, scheme: scheme)
                        }

                        Button {
                            dismiss()
                            onOpenBookmarks()
                        } label: {
                            toolRow(icon: .bookmarks, title: Loc.tr("tools_bookmarks"), theme: theme, scheme: scheme)
                        }

                        Button {
                            dismiss()
                            onOpenDownloads()
                        } label: {
                            toolRow(icon: .downloads, title: Loc.tr("tools_downloads"), theme: theme, scheme: scheme)
                        }

                        Button {
                            dismiss()
                            onOpenPasswordVault()
                        } label: {
                            toolRow(icon: .keyPassword, title: Loc.tr("tools_password_vault"), theme: theme, scheme: scheme)
                        }

                        Button {
                            dismiss()
                            onOpenAntiSpy()
                        } label: {
                            toolRow(icon: .shieldActive, title: Loc.tr("tools_anti_spy"), theme: theme, scheme: scheme)
                        }
                    }

                    // Sección 3: Compartir, Ajustes y Acerca de
                    Section {
                        Button {
                            dismiss()
                            onShare()
                        } label: {
                            toolRow(icon: .share, title: Loc.tr("bar_share"), theme: theme, scheme: scheme)
                        }

                        Button {
                            dismiss()
                            onOpenSettings()
                        } label: {
                            toolRow(icon: .settings, title: Loc.tr("tools_settings"), theme: theme, scheme: scheme)
                        }

                        Button {
                            dismiss()
                            onOpenAbout()
                        } label: {
                            toolRow(icon: .userProfile, title: Loc.tr("tools_about"), subtitle: "Hecho por Rubén Aguilarte", theme: theme, scheme: scheme)
                        }
                    }
                }
                .listStyle(.insetGrouped)
                .scrollContentBackground(.hidden)
            }
            .navigationTitle(Loc.tr("bar_tools"))
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
    private func toolRow(icon: LiquidIconType, title: String, subtitle: String? = nil, theme: ThemeManager, scheme: ColorScheme) -> some View {
        HStack(spacing: 14) {
            LiquidIconView(icon, size: 18, color: theme.textPrimary(for: scheme))

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 15, weight: .regular, design: .rounded))
                    .foregroundStyle(theme.textPrimary(for: scheme))

                if let sub = subtitle {
                    Text(sub)
                        .font(.system(size: 11, weight: .medium))
                        .foregroundStyle(theme.textSecondary(for: scheme))
                }
            }

            Spacer()
            LiquidIconView(.chevronRight, size: 12, color: theme.textSecondary(for: scheme).opacity(0.4))
        }
    }
}
