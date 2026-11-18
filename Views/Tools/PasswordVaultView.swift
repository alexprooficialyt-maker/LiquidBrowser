import SwiftUI
import UIKit

// MARK: - PasswordVaultView (Biometric-Protected Secure Keychain Vault)

public struct PasswordVaultView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var systemColorScheme

    @State private var isUnlocked: Bool = false
    @State private var credentials: [VaultCredentialEntry] = []
    @State private var searchQuery: String = ""
    @State private var isAddingCredential: Bool = false
    @State private var copiedFeedbackDomain: String? = nil

    // Campos de nueva credencial
    @State private var newDomain: String = ""
    @State private var newUsername: String = ""
    @State private var newPassword: String = ""
    @State private var newNotes: String = ""

    public init() {}

    private var filteredCredentials: [VaultCredentialEntry] {
        let trimmed = searchQuery.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        if trimmed.isEmpty {
            return credentials
        }
        return credentials.filter {
            $0.domain.lowercased().contains(trimmed) || $0.username.lowercased().contains(trimmed)
        }
    }

    public var body: some View {
        let theme = ThemeManager.shared
        let scheme = theme.effectiveScheme(systemScheme: systemColorScheme)

        NavigationStack {
            ZStack {
                theme.background(for: scheme).ignoresSafeArea()

                if !isUnlocked {
                    lockedStateView(theme: theme, scheme: scheme)
                } else {
                    unlockedVaultContent(theme: theme, scheme: scheme)
                }
            }
            .navigationTitle(Loc.tr("vault_title"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(Loc.tr("done")) { dismiss() }
                        .foregroundStyle(theme.textPrimary(for: scheme))
                }
                if isUnlocked {
                    ToolbarItem(placement: .confirmationAction) {
                        Button {
                            HapticManager.shared.touchLight()
                            isAddingCredential = true
                        } label: {
                            LiquidIconView(.newTab, size: 18, color: theme.textPrimary(for: scheme))
                        }
                    }
                }
            }
            .sheet(isPresented: $isAddingCredential) {
                addCredentialSheet(theme: theme, scheme: scheme)
            }
            .onAppear {
                checkLockRequirement()
            }
        }
    }

    // MARK: - Estado Bloqueado

    @ViewBuilder
    private func lockedStateView(theme: ThemeManager, scheme: ColorScheme) -> some View {
        VStack(spacing: 20) {
            Spacer()

            ZStack {
                Circle()
                    .fill(theme.surfaceElevated(for: scheme))
                    .frame(width: 80, height: 80)
                    .overlay {
                        Circle().strokeBorder(theme.borderSpecular(for: scheme), lineWidth: 0.5)
                    }

                LiquidIconView(.keyPassword, size: 36, color: theme.textPrimary(for: scheme))
            }

            VStack(spacing: 8) {
                Text("Bóveda Protegida")
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .foregroundStyle(theme.textPrimary(for: scheme))

                Text(Loc.tr("vault_locked_message"))
                    .font(.system(size: 14, weight: .regular))
                    .foregroundStyle(theme.textSecondary(for: scheme))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }

            Button {
                HapticManager.shared.touchMedium()
                authenticateToUnlock()
            } label: {
                HStack(spacing: 8) {
                    let bioType = KeychainVault.shared.biometricType
                    LiquidIconView(bioType == .faceID ? .faceID : (bioType == .touchID ? .touchID : .pinPad), size: 18, color: scheme == .dark ? Color.black : Color.white)

                    Text(Loc.tr("lock_unlock_button"))
                        .font(.system(size: 15, weight: .bold, design: .rounded))
                        .foregroundStyle(scheme == .dark ? Color.black : Color.white)
                }
                .padding(.horizontal, 28)
                .padding(.vertical, 14)
                .background(scheme == .dark ? Color.white : Color.black)
                .clipShape(Capsule())
            }
            .buttonStyle(.plain)
            .padding(.top, 12)

            Spacer()
        }
    }

    private func checkLockRequirement() {
        if !KeychainVault.shared.isAppLockEnabled && !KeychainVault.shared.isBiometricAuthEnabled && !KeychainVault.shared.hasAppPIN() {
            // Sin protección configurada, desbloquear directamente
            self.isUnlocked = true
            loadCredentials()
        } else {
            authenticateToUnlock()
        }
    }

    private func authenticateToUnlock() {
        if KeychainVault.shared.canUseBiometrics && KeychainVault.shared.isBiometricAuthEnabled {
            KeychainVault.shared.authenticateWithBiometrics(reason: "Acceder a la Bóveda de Contraseñas") { success in
                DispatchQueue.main.async {
                    if success {
                        self.isUnlocked = true
                        self.loadCredentials()
                        HapticManager.shared.notifySuccess()
                    }
                }
            }
        } else {
            // Si no hay biometría pero hay PIN, se desbloquea directamente tras autenticación de app
            self.isUnlocked = true
            self.loadCredentials()
        }
    }

    private func loadCredentials() {
        self.credentials = KeychainVault.shared.getAllCredentials()
    }

    // MARK: - Contenido Desbloqueado de la Bóveda

    @ViewBuilder
    private func unlockedVaultContent(theme: ThemeManager, scheme: ColorScheme) -> some View {
        VStack(spacing: 14) {
            // Buscador de credenciales
            HStack(spacing: 10) {
                LiquidIconView(.search, size: 16, color: theme.textSecondary(for: scheme))

                TextField(Loc.tr("vault_search_placeholder"), text: $searchQuery)
                    .font(.system(size: 14, weight: .regular))
                    .foregroundStyle(theme.textPrimary(for: scheme))

                if !searchQuery.isEmpty {
                    Button {
                        searchQuery = ""
                    } label: {
                        LiquidIconView(.close, size: 12, color: theme.textSecondary(for: scheme))
                    }
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .liquidGlassCard(cornerRadius: 14)
            .padding(.horizontal, 20)
            .padding(.top, 8)

            // Mensaje de feedback de copiado
            if let copied = copiedFeedbackDomain {
                Text("Contraseña de \(copied) copiada al portapapeles")
                    .font(.system(size: 12, weight: .semibold, design: .rounded))
                    .foregroundStyle(Color.green)
                    .transition(.opacity)
            }

            if filteredCredentials.isEmpty {
                VStack(spacing: 12) {
                    Spacer()
                    LiquidIconView(.keyPassword, size: 36, color: theme.textSecondary(for: scheme))
                    Text(Loc.tr("vault_empty"))
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(theme.textSecondary(for: scheme))

                    Button("Añadir primera contraseña") {
                        isAddingCredential = true
                    }
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(theme.textPrimary(for: scheme))
                    Spacer()
                }
            } else {
                List {
                    ForEach(filteredCredentials) { cred in
                        credentialRow(cred: cred, theme: theme, scheme: scheme)
                    }
                    .onDelete { indexSet in
                        for index in indexSet {
                            let cred = filteredCredentials[index]
                            KeychainVault.shared.deleteCredential(id: cred.id)
                        }
                        loadCredentials()
                    }
                }
                .listStyle(.insetGrouped)
                .scrollContentBackground(.hidden)
            }
        }
    }

    @ViewBuilder
    private func credentialRow(cred: VaultCredentialEntry, theme: ThemeManager, scheme: ColorScheme) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 12) {
                FaviconView(url: URL(string: "https://\(cred.domain)"), title: cred.domain, size: 28, cornerRadius: 6)

                VStack(alignment: .leading, spacing: 2) {
                    Text(cred.domain)
                        .font(.system(size: 15, weight: .bold, design: .rounded))
                        .foregroundStyle(theme.textPrimary(for: scheme))

                    Text(cred.username)
                        .font(.system(size: 13, weight: .regular))
                        .foregroundStyle(theme.textSecondary(for: scheme))
                }

                Spacer()

                Button {
                    HapticManager.shared.touchLight()
                    UIPasteboard.general.string = cred.password
                    HapticManager.shared.notifySuccess()
                    withAnimation {
                        copiedFeedbackDomain = cred.domain
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                        withAnimation {
                            if copiedFeedbackDomain == cred.domain {
                                copiedFeedbackDomain = nil
                            }
                        }
                    }
                } label: {
                    HStack(spacing: 4) {
                        LiquidIconView(.keyPassword, size: 12, color: theme.textPrimary(for: scheme))
                        Text(Loc.tr("copy"))
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(theme.textPrimary(for: scheme))
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(theme.surfaceElevated(for: scheme))
                    .clipShape(Capsule())
                }
                .buttonStyle(.plain)
            }

            Text("••••••••••••")
                .font(.system(size: 12, weight: .regular, design: .monospaced))
                .foregroundStyle(theme.textTertiary(for: scheme))
        }
        .padding(.vertical, 4)
    }

    // MARK: - Sheet para Añadir Credencial

    @ViewBuilder
    private func addCredentialSheet(theme: ThemeManager, scheme: ColorScheme) -> some View {
        NavigationStack {
            ZStack {
                theme.background(for: scheme).ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 16) {
                        formField(title: Loc.tr("vault_site"), placeholder: "ejemplo.com", text: $newDomain, theme: theme, scheme: scheme)
                        formField(title: Loc.tr("vault_username"), placeholder: "usuario o correo", text: $newUsername, theme: theme, scheme: scheme)

                        VStack(alignment: .leading, spacing: 6) {
                            HStack {
                                Text(Loc.tr("vault_password"))
                                    .font(.system(size: 13, weight: .semibold))
                                    .foregroundStyle(theme.textSecondary(for: scheme))

                                Spacer()

                                Button("Generar Segura") {
                                    HapticManager.shared.touchLight()
                                    newPassword = KeychainVault.shared.generateSecurePassword(length: 18)
                                }
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundStyle(theme.textPrimary(for: scheme))
                            }

                            TextField("Contraseña", text: $newPassword)
                                .padding(.horizontal, 14)
                                .padding(.vertical, 12)
                                .background(theme.surfaceElevated(for: scheme))
                                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                                .foregroundStyle(theme.textPrimary(for: scheme))
                        }

                        formField(title: "Notas Opcionales", placeholder: "Notas adicionales", text: $newNotes, theme: theme, scheme: scheme)
                    }
                    .padding(20)
                }
            }
            .navigationTitle(Loc.tr("vault_new_credential"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(Loc.tr("cancel")) { isAddingCredential = false }
                        .foregroundStyle(theme.textSecondary(for: scheme))
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(Loc.tr("save")) {
                        saveCredential()
                    }
                    .disabled(newDomain.isEmpty || newUsername.isEmpty || newPassword.isEmpty)
                    .foregroundStyle(theme.textPrimary(for: scheme))
                }
            }
        }
    }

    @ViewBuilder
    private func formField(title: String, placeholder: String, text: Binding<String>, theme: ThemeManager, scheme: ColorScheme) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(theme.textSecondary(for: scheme))

            TextField(placeholder, text: text)
                .padding(.horizontal, 14)
                .padding(.vertical, 12)
                .background(theme.surfaceElevated(for: scheme))
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                .foregroundStyle(theme.textPrimary(for: scheme))
        }
    }

    private func saveCredential() {
        let entry = VaultCredentialEntry(
            domain: newDomain.trimmingCharacters(in: .whitespacesAndNewlines),
            username: newUsername.trimmingCharacters(in: .whitespacesAndNewlines),
            password: newPassword,
            notes: newNotes
        )
        KeychainVault.shared.saveCredential(entry)
        newDomain = ""
        newUsername = ""
        newPassword = ""
        newNotes = ""
        isAddingCredential = false
        loadCredentials()
        HapticManager.shared.notifySuccess()
    }
}
