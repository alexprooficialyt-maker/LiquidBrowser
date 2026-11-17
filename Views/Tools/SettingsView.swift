import SwiftUI

// MARK: - SettingsView (Strict Monochrome Liquid Glass)

public struct SettingsView: View {
    @AppStorage("userName") private var userName = ""
    @AppStorage("userAge") private var userAge = 24
    @AppStorage("searchEngine") private var searchEngine = "Google"
    @AppStorage("monochromeTone") private var monochromeTone = "Titanium"
    @AppStorage("autoCloseTabsDays") private var autoCloseDays = 0
    @AppStorage("adBlockEnabled") private var adBlockEnabled = true
    @AppStorage("forceHTTPS") private var forceHTTPS = true

    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme

    @State private var showingBurnConfirmation = false

    private let searchEngines = ["Google", "DuckDuckGo", "Brave", "Ecosia"]
    private let toneOptions = [
        ("Titanio", "Titanium"),
        ("Grafito", "Graphite"),
        ("Plata", "Silver")
    ]

    public init() {}

    public var body: some View {
        let theme = ThemeEngine.shared

        NavigationView {
            ZStack {
                theme.background(for: colorScheme)
                    .ignoresSafeArea()

                Form {
                    // SECCIÓN: PERFIL
                    Section {
                        HStack {
                            Text("Nombre")
                                .font(.system(size: 15, design: .rounded))
                                .foregroundStyle(theme.textPrimary(for: colorScheme))
                            Spacer()
                            TextField("Tu nombre", text: $userName)
                                .multilineTextAlignment(.trailing)
                                .font(.system(size: 15, design: .rounded))
                                .foregroundStyle(theme.textSecondary(for: colorScheme))
                        }

                        HStack {
                            Text("Edad")
                                .font(.system(size: 15, design: .rounded))
                                .foregroundStyle(theme.textPrimary(for: colorScheme))
                            Spacer()
                            Stepper("\(userAge) años", value: $userAge, in: 10...99)
                                .font(.system(size: 15, design: .rounded))
                                .foregroundStyle(theme.textSecondary(for: colorScheme))
                        }
                    } header: {
                        Text("Perfil")
                            .font(.system(size: 12, weight: .semibold, design: .rounded))
                            .foregroundStyle(theme.textSecondary(for: colorScheme))
                    }
                    .listRowBackground(theme.cardBackground(for: colorScheme))

                    // SECCIÓN: BÚSQUEDA
                    Section {
                        Picker("Motor de búsqueda", selection: $searchEngine) {
                            ForEach(searchEngines, id: \.self) { engine in
                                Text(engine).tag(engine)
                            }
                        }
                        .pickerStyle(.menu)
                        .tint(theme.textPrimary(for: colorScheme))
                    } header: {
                        Text("Navegación")
                            .font(.system(size: 12, weight: .semibold, design: .rounded))
                            .foregroundStyle(theme.textSecondary(for: colorScheme))
                    }
                    .listRowBackground(theme.cardBackground(for: colorScheme))

                    // SECCIÓN: ESTILO MONOCROMO & MATERIAL
                    Section {
                        Picker("Matiz Monocromo", selection: $monochromeTone) {
                            ForEach(toneOptions, id: \.1) { name, key in
                                Text(name).tag(key)
                            }
                        }
                        .pickerStyle(.menu)
                        .tint(theme.textPrimary(for: colorScheme))

                        HStack {
                            Text("Material de interfaz")
                                .font(.system(size: 15, design: .rounded))
                                .foregroundStyle(theme.textPrimary(for: colorScheme))
                            Spacer()
                            Text("Liquid Glass")
                                .font(.system(size: 14, weight: .medium, design: .rounded))
                                .foregroundStyle(theme.textSecondary(for: colorScheme))
                        }
                    } header: {
                        Text("Diseño y Acabado")
                            .font(.system(size: 12, weight: .semibold, design: .rounded))
                            .foregroundStyle(theme.textSecondary(for: colorScheme))
                    }
                    .listRowBackground(theme.cardBackground(for: colorScheme))

                    // SECCIÓN: PRIVACIDAD Y SEGURIDAD
                    Section {
                        Toggle(isOn: $adBlockEnabled) {
                            HStack(spacing: 12) {
                                LiquidIconView(.shieldBlocker, size: 16, color: theme.textPrimary(for: colorScheme))
                                Text("Bloquear rastreadores y publicidad")
                                    .font(.system(size: 15, design: .rounded))
                                    .foregroundStyle(theme.textPrimary(for: colorScheme))
                            }
                        }
                        .tint(theme.textPrimary(for: colorScheme))

                        Toggle(isOn: $forceHTTPS) {
                            HStack(spacing: 12) {
                                LiquidIconView(.lockSSL, size: 16, color: theme.textPrimary(for: colorScheme))
                                Text("Forzar HTTPS seguro")
                                    .font(.system(size: 15, design: .rounded))
                                    .foregroundStyle(theme.textPrimary(for: colorScheme))
                            }
                        }
                        .tint(theme.textPrimary(for: colorScheme))

                        Button(role: .destructive) {
                            HapticManager.shared.touchMedium()
                            showingBurnConfirmation = true
                        } label: {
                            HStack(spacing: 12) {
                                LiquidIconView(.burnSession, size: 16, color: Color.red)
                                Text("Quemar sesión y borrar datos")
                                    .font(.system(size: 15, weight: .medium, design: .rounded))
                                    .foregroundStyle(Color.red)
                            }
                        }
                    } header: {
                        Text("Privacidad")
                            .font(.system(size: 12, weight: .semibold, design: .rounded))
                            .foregroundStyle(theme.textSecondary(for: colorScheme))
                    } footer: {
                        Text("Quemar sesión borra cookies, caché web, historial y pestañas abiertas inmediatamente.")
                            .font(.system(size: 12, design: .rounded))
                            .foregroundStyle(theme.textSecondary(for: colorScheme))
                    }
                    .listRowBackground(theme.cardBackground(for: colorScheme))

                    // SECCIÓN: PESTAÑAS
                    Section {
                        Picker("Cierre automático de inactivas", selection: $autoCloseDays) {
                            Text("Nunca").tag(0)
                            Text("Tras 24 horas").tag(1)
                            Text("Tras 7 días").tag(7)
                            Text("Tras 30 días").tag(30)
                        }
                        .pickerStyle(.menu)
                        .tint(theme.textPrimary(for: colorScheme))
                    } header: {
                        Text("Gestión de Pestañas")
                            .font(.system(size: 12, weight: .semibold, design: .rounded))
                            .foregroundStyle(theme.textSecondary(for: colorScheme))
                    }
                    .listRowBackground(theme.cardBackground(for: colorScheme))

                    // SECCIÓN: ACERCA DE
                    Section {
                        HStack {
                            Text("Versión")
                                .font(.system(size: 15, design: .rounded))
                                .foregroundStyle(theme.textPrimary(for: colorScheme))
                            Spacer()
                            Text("1.0.0 (Liquid Glass Native)")
                                .font(.system(size: 14, design: .rounded))
                                .foregroundStyle(theme.textSecondary(for: colorScheme))
                        }

                        HStack {
                            Text("Motor Web")
                                .font(.system(size: 15, design: .rounded))
                                .foregroundStyle(theme.textPrimary(for: colorScheme))
                            Spacer()
                            Text("WebKit Multi-Instancia")
                                .font(.system(size: 14, design: .rounded))
                                .foregroundStyle(theme.textSecondary(for: colorScheme))
                        }
                    } header: {
                        Text("Acerca de LiquidBrowser")
                            .font(.system(size: 12, weight: .semibold, design: .rounded))
                            .foregroundStyle(theme.textSecondary(for: colorScheme))
                    }
                    .listRowBackground(theme.cardBackground(for: colorScheme))
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("Ajustes")
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
            .alert("¿Quemar sesión?", isPresented: $showingBurnConfirmation) {
                Button("Cancelar", role: .cancel) {}
                Button("Quemar y Limpiar", role: .destructive) {
                    burnSession()
                }
            } message: {
                Text("Se cerrarán todas las pestañas, se borrarán las cookies temporales, la caché y el historial.")
            }
        }
    }

    private func burnSession() {
        HapticManager.shared.notifyWarning()
        WebEngineCoordinator.shared.burnSession()
        dismiss()
    }
}
