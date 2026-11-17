import SwiftUI

// MARK: - SettingsView (Ajustes de Producción en Cristal Monocromo)

public struct SettingsView: View {
    @AppStorage("userName") private var userName = ""
    @AppStorage("userAge") private var userAge = 24
    @AppStorage("searchEngine") private var searchEngine = "Google"
    @AppStorage("adBlockEnabled") private var adBlockEnabled = true
    @AppStorage("forceHTTPS") private var forceHTTPS = true

    @State private var themeManager = ThemeManager.shared
    @State private var showingCredits = false
    @State private var showingBurnConfirmation = false
    @State private var showingPINChangeSheet = false
    @State private var newPINInput = ""

    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme

    private let searchEngines = ["Google", "DuckDuckGo", "Brave", "Ecosia"]

    public init() {}

    public var body: some View {
        let theme = ThemeManager.shared

        NavigationView {
            ZStack {
                theme.background(for: colorScheme)
                    .ignoresSafeArea()

                Form {
                    // SECCIÓN: PERFIL DEL USUARIO
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

                    // SECCIÓN: APARIENCIA Y TEMA EN VIVO
                    Section {
                        Picker("Modo Visual", selection: $themeManager.currentMode) {
                            ForEach(AppThemeMode.allCases, id: \.self) { mode in
                                Text(mode.title).tag(mode)
                            }
                        }
                        .pickerStyle(.menu)
                        .tint(theme.textPrimary(for: colorScheme))

                        Picker("Matiz Monocromo", selection: $themeManager.accentTone) {
                            ForEach(MonochromeAccentTone.allCases, id: \.self) { tone in
                                Text(tone.displayName).tag(tone)
                            }
                        }
                        .pickerStyle(.menu)
                        .tint(theme.textPrimary(for: colorScheme))
                    } header: {
                        Text("Apariencia y Cristal")
                            .font(.system(size: 12, weight: .semibold, design: .rounded))
                            .foregroundStyle(theme.textSecondary(for: colorScheme))
                    }
                    .listRowBackground(theme.cardBackground(for: colorScheme))

                    // SECCIÓN: NAVEGACIÓN Y BÚSQUEDA
                    Section {
                        Picker("Buscador por defecto", selection: $searchEngine) {
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

                    // SECCIÓN: CUENTA DE GOOGLE
                    Section {
                        let googleState = GoogleAuthManager.shared.accountState

                        HStack(spacing: 12) {
                            LiquidIconView(.googleAccount, size: 24, color: theme.textPrimary(for: colorScheme))

                            VStack(alignment: .leading, spacing: 2) {
                                Text(googleState.isSignedIn ? (googleState.displayName ?? "Conectado") : "No iniciada")
                                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                                    .foregroundStyle(theme.textPrimary(for: colorScheme))

                                if let email = googleState.userEmail {
                                    Text(email)
                                        .font(.system(size: 12, design: .rounded))
                                        .foregroundStyle(theme.textSecondary(for: colorScheme))
                                } else {
                                    Text("Inicia sesión para sincronizar YouTube y Google")
                                        .font(.system(size: 12, design: .rounded))
                                        .foregroundStyle(theme.textSecondary(for: colorScheme))
                                }
                            }

                            Spacer()

                            Button(googleState.isSignedIn ? "Cerrar" : "Conectar") {
                                HapticManager.shared.touchLight()
                                if googleState.isSignedIn {
                                    GoogleAuthManager.shared.signOut()
                                } else {
                                    dismiss()
                                    WebEngineCoordinator.shared.loadURL(GoogleAuthManager.shared.googleSignInURL)
                                }
                            }
                            .font(.system(size: 13, weight: .semibold, design: .rounded))
                            .foregroundStyle(theme.textPrimary(for: colorScheme))
                        }
                    } header: {
                        Text("Cuenta de Google")
                            .font(.system(size: 12, weight: .semibold, design: .rounded))
                            .foregroundStyle(theme.textSecondary(for: colorScheme))
                    }
                    .listRowBackground(theme.cardBackground(for: colorScheme))

                    // SECCIÓN: SEGURIDAD Y ACCESO
                    Section {
                        Toggle(isOn: Binding(
                            get: { KeychainSecurityHelper.shared.isAppLockEnabled },
                            set: { KeychainSecurityHelper.shared.isAppLockEnabled = $0 }
                        )) {
                            HStack(spacing: 12) {
                                LiquidIconView(.lockSSL, size: 16, color: theme.textPrimary(for: colorScheme))
                                Text("Bloquear app con PIN")
                                    .font(.system(size: 15, design: .rounded))
                                    .foregroundStyle(theme.textPrimary(for: colorScheme))
                            }
                        }
                        .tint(theme.textPrimary(for: colorScheme))

                        if KeychainSecurityHelper.shared.canEvaluateBiometrics {
                            Toggle(isOn: Binding(
                                get: { KeychainSecurityHelper.shared.isBiometricAuthEnabled },
                                set: { KeychainSecurityHelper.shared.isBiometricAuthEnabled = $0 }
                            )) {
                                HStack(spacing: 12) {
                                    LiquidIconView(KeychainSecurityHelper.shared.biometricType == .faceID ? .faceID : .touchID,
                                                   size: 16,
                                                   color: theme.textPrimary(for: colorScheme))
                                    Text(KeychainSecurityHelper.shared.biometricType == .faceID ? "Usar Face ID" : "Usar Touch ID")
                                        .font(.system(size: 15, design: .rounded))
                                        .foregroundStyle(theme.textPrimary(for: colorScheme))
                                }
                            }
                            .tint(theme.textPrimary(for: colorScheme))
                        }

                        Button("Cambiar código PIN de 4 dígitos") {
                            HapticManager.shared.touchLight()
                            showingPINChangeSheet = true
                        }
                        .font(.system(size: 14, design: .rounded))
                        .foregroundStyle(theme.textPrimary(for: colorScheme))
                    } header: {
                        Text("Seguridad y Acceso")
                            .font(.system(size: 12, weight: .semibold, design: .rounded))
                            .foregroundStyle(theme.textSecondary(for: colorScheme))
                    }
                    .listRowBackground(theme.cardBackground(for: colorScheme))

                    // SECCIÓN: PRIVACIDAD Y LIMPIEZA
                    Section {
                        Toggle(isOn: $adBlockEnabled) {
                            HStack(spacing: 12) {
                                LiquidIconView(.shieldBlocker, size: 16, color: theme.textPrimary(for: colorScheme))
                                Text("Bloquear rastreadores y anuncios")
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
                        Text("Privacidad Estricta")
                            .font(.system(size: 12, weight: .semibold, design: .rounded))
                            .foregroundStyle(theme.textSecondary(for: colorScheme))
                    } footer: {
                        Text("Quemar sesión elimina inmediatamente todas las cookies de navegación, el historial, las pestañas y la caché.")
                            .font(.system(size: 12, design: .rounded))
                            .foregroundStyle(theme.textSecondary(for: colorScheme))
                    }
                    .listRowBackground(theme.cardBackground(for: colorScheme))

                    // SECCIÓN: AUTOR Y CRÉDITOS
                    Section {
                        Button(action: {
                            HapticManager.shared.touchLight()
                            showingCredits = true
                        }) {
                            HStack(spacing: 12) {
                                LiquidIconView(.creditsAuthor, size: 18, color: theme.textPrimary(for: colorScheme))

                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Hecho por Rubén Aguilarte")
                                        .font(.system(size: 15, weight: .semibold, design: .rounded))
                                        .foregroundStyle(theme.textPrimary(for: colorScheme))

                                    Text("Diseño de Sistemas y Arquitectura")
                                        .font(.system(size: 12, design: .rounded))
                                        .foregroundStyle(theme.textSecondary(for: colorScheme))
                                }

                                Spacer()

                                LiquidIconView(.chevronRight, size: 12, color: theme.textTertiary(for: colorScheme))
                            }
                            .padding(.vertical, 4)
                        }
                    } header: {
                        Text("Créditos y Versión")
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
            .sheet(isPresented: $showingCredits) {
                CreditsView()
            }
            .alert("Nuevo PIN de 4 Dígitos", isPresented: $showingPINChangeSheet) {
                TextField("PIN", text: $newPINInput)
                Button("Guardar") {
                    if newPINInput.count == 4 {
                        KeychainSecurityHelper.shared.savePIN(newPINInput)
                        HapticManager.shared.notifySuccess()
                    }
                    newPINInput = ""
                }
                Button("Cancelar", role: .cancel) {
                    newPINInput = ""
                }
            } message: {
                Text("Introduce el nuevo código PIN numérico para el bloqueo de la aplicación.")
            }
            .alert("¿Quemar sesión?", isPresented: $showingBurnConfirmation) {
                Button("Cancelar", role: .cancel) {}
                Button("Quemar y Limpiar Todo", role: .destructive) {
                    HapticManager.shared.notifyWarning()
                    WebEngineCoordinator.shared.burnSession()
                    dismiss()
                }
            } message: {
                Text("Se cerrarán todas las pestañas, se borrarán las cookies temporales, la caché y el historial.")
            }
        }
    }
}
