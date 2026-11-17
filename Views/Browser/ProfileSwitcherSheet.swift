import SwiftUI

// MARK: - ProfileSwitcherSheet (Multi-Profile Selector & Manager)

public struct ProfileSwitcherSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var systemColorScheme

    @State private var storage = StorageEngine.shared
    @State private var isCreatingProfile: Bool = false
    @State private var newProfileName: String = ""
    @State private var newProfileDesc: String = ""
    @State private var newProfileColor: ProfileAccentColor = .sapphire
    @State private var newProfileIcon: LiquidIconType = .briefcase

    public init() {}

    public var body: some View {
        let theme = ThemeManager.shared
        let scheme = theme.effectiveScheme(systemScheme: systemColorScheme)

        NavigationStack {
            ZStack {
                theme.background(for: scheme).ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 16) {
                        ForEach(storage.profiles) { profile in
                            profileCard(profile: profile, isSelected: profile.id == storage.activeProfileID, theme: theme, scheme: scheme)
                        }

                        // Botón Nuevo Perfil
                        Button {
                            HapticManager.shared.touchLight()
                            isCreatingProfile = true
                        } label: {
                            HStack(spacing: 12) {
                                LiquidIconView(.newTab, size: 18, color: theme.textPrimary(for: scheme))

                                Text(Loc.tr("profile_new"))
                                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                                    .foregroundStyle(theme.textPrimary(for: scheme))

                                Spacer()
                            }
                            .padding(16)
                            .liquidGlassCard(cornerRadius: 18)
                        }
                        .buttonStyle(.plain)
                        .padding(.top, 4)
                    }
                    .padding(20)
                }
            }
            .navigationTitle(Loc.tr("profile_title"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button(Loc.tr("done")) {
                        dismiss()
                    }
                    .foregroundStyle(theme.textPrimary(for: scheme))
                }
            }
            .sheet(isPresented: $isCreatingProfile) {
                createProfileView(theme: theme, scheme: scheme)
            }
        }
    }

    @ViewBuilder
    private func profileCard(profile: UserProfile, isSelected: Bool, theme: ThemeManager, scheme: ColorScheme) -> some View {
        Button {
            HapticManager.shared.touchMedium()
            storage.switchProfile(to: profile.id)
            dismiss()
        } label: {
            HStack(spacing: 16) {
                // Icono del Perfil con su color
                ZStack {
                    Circle()
                        .fill(profile.accentColor.swatchColor.opacity(0.18))
                        .frame(width: 44, height: 44)

                    LiquidIconView(profile.iconType, size: 22, color: profile.accentColor.color(for: scheme))
                }

                VStack(alignment: .leading, spacing: 3) {
                    HStack(spacing: 6) {
                        Text(profile.name)
                            .font(.system(size: 16, weight: .bold, design: .rounded))
                            .foregroundStyle(theme.textPrimary(for: scheme))

                        if profile.hasPIN {
                            LiquidIconView(.lockSSL, size: 12, color: theme.textSecondary(for: scheme))
                        }
                    }

                    Text(profile.description.isEmpty ? "Perfil independiente" : profile.description)
                        .font(.system(size: 12, weight: .regular))
                        .foregroundStyle(theme.textSecondary(for: scheme))
                }

                Spacer()

                if isSelected {
                    LiquidIconView(.checkmark, size: 16, color: theme.textPrimary(for: scheme))
                }
            }
            .padding(16)
            .liquidGlassCard(cornerRadius: 18)
            .overlay {
                if isSelected {
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .strokeBorder(theme.textPrimary(for: scheme), lineWidth: 1.5)
                }
            }
        }
        .buttonStyle(.plain)
    }

    @ViewBuilder
    private func createProfileView(theme: ThemeManager, scheme: ColorScheme) -> some View {
        NavigationStack {
            ZStack {
                theme.background(for: scheme).ignoresSafeArea()

                VStack(spacing: 20) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text(Loc.tr("profile_name"))
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(theme.textSecondary(for: scheme))

                        TextField("Ej. Trabajo, Estudio", text: $newProfileName)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 12)
                            .background(theme.surfaceElevated(for: scheme))
                            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                            .foregroundStyle(theme.textPrimary(for: scheme))
                    }

                    VStack(alignment: .leading, spacing: 6) {
                        Text("Descripción")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(theme.textSecondary(for: scheme))

                        TextField("Ej. Pestañas y proyectos laborales", text: $newProfileDesc)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 12)
                            .background(theme.surfaceElevated(for: scheme))
                            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                            .foregroundStyle(theme.textPrimary(for: scheme))
                    }

                    // Selector de color
                    VStack(alignment: .leading, spacing: 8) {
                        Text(Loc.tr("profile_color"))
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(theme.textSecondary(for: scheme))

                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                ForEach(ProfileAccentColor.allCases) { color in
                                    Circle()
                                        .fill(color.swatchColor)
                                        .frame(width: 32, height: 32)
                                        .overlay {
                                            if newProfileColor == color {
                                                Circle()
                                                    .strokeBorder(theme.textPrimary(for: scheme), lineWidth: 2)
                                                    .padding(-4)
                                            }
                                        }
                                        .onTapGesture {
                                            newProfileColor = color
                                        }
                                }
                            }
                            .padding(.vertical, 4)
                        }
                    }

                    Spacer()
                }
                .padding(20)
            }
            .navigationTitle(Loc.tr("profile_new"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(Loc.tr("cancel")) { isCreatingProfile = false }
                        .foregroundStyle(theme.textSecondary(for: scheme))
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(Loc.tr("save")) {
                        let name = newProfileName.trimmingCharacters(in: .whitespacesAndNewlines)
                        guard !name.isEmpty else { return }
                        _ = storage.createProfile(
                            name: name,
                            age: nil,
                            description: newProfileDesc,
                            color: newProfileColor,
                            icon: newProfileIcon
                        )
                        isCreatingProfile = false
                    }
                    .disabled(newProfileName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    .foregroundStyle(theme.textPrimary(for: scheme))
                }
            }
        }
    }
}
