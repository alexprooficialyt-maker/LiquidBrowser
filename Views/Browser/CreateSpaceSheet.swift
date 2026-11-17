import SwiftUI

// MARK: - CreateSpaceSheet (Creación y Edición de Espacios Monocromos)

public struct CreateSpaceSheet: View {
    public var coordinator: WebEngineCoordinator
    public var existingSpace: SpaceModel?

    @State private var spaceName: String = ""
    @State private var selectedIcon: LiquidIconType = .spaceFolder
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme

    private let availableIcons: [LiquidIconType] = [
        .spaceFolder,
        .spaceWork,
        .spaceStudy,
        .spaceCode,
        .spaceStar,
        .spacePrivate
    ]

    public init(coordinator: WebEngineCoordinator = .shared, existingSpace: SpaceModel? = nil) {
        self.coordinator = coordinator
        self.existingSpace = existingSpace
        _spaceName = State(initialValue: existingSpace?.name ?? "")
        if let icon = existingSpace?.icon {
            _selectedIcon = State(initialValue: icon)
        }
    }

    public var body: some View {
        let theme = ThemeManager.shared

        NavigationStack {
            ZStack {
                theme.background(for: colorScheme)
                    .ignoresSafeArea()

                VStack(spacing: 24) {
                    // Previsualización de la Carpeta en Cristal
                    VStack(spacing: 12) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 22, style: .continuous)
                                .fill(theme.cardBackground(for: colorScheme))
                                .frame(width: 76, height: 76)
                                .overlay {
                                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                                        .strokeBorder(theme.specularBorder(for: colorScheme), lineWidth: 0.5)
                                }

                            LiquidIconView(selectedIcon, size: 36, color: theme.textPrimary(for: colorScheme))
                        }

                        Text(spaceName.isEmpty ? "Nombre del Espacio" : spaceName)
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                            .foregroundStyle(theme.textPrimary(for: colorScheme))
                    }
                    .padding(.top, 16)

                    // Campo de Texto Monocromo
                    VStack(alignment: .leading, spacing: 8) {
                        Text("NOMBRE")
                            .font(.system(size: 11, weight: .semibold, design: .rounded))
                            .foregroundStyle(theme.textSecondary(for: colorScheme))
                            .padding(.leading, 4)

                        TextField("Ej. Trabajo, Estudio, Personal", text: $spaceName)
                            .font(.system(size: 16, weight: .medium, design: .rounded))
                            .foregroundStyle(theme.textPrimary(for: colorScheme))
                            .padding(.horizontal, 16)
                            .padding(.vertical, 14)
                            .background {
                                RoundedRectangle(cornerRadius: 16, style: .continuous)
                                    .fill(theme.cardBackground(for: colorScheme))
                            }
                            .overlay {
                                RoundedRectangle(cornerRadius: 16, style: .continuous)
                                    .strokeBorder(theme.borderSpecular(for: colorScheme), lineWidth: 0.5)
                            }
                    }
                    .padding(.horizontal, 20)

                    // Selector de Iconos Artesanales
                    VStack(alignment: .leading, spacing: 10) {
                        Text("ICONO VECTORIAL")
                            .font(.system(size: 11, weight: .semibold, design: .rounded))
                            .foregroundStyle(theme.textSecondary(for: colorScheme))
                            .padding(.leading, 4)

                        HStack(spacing: 12) {
                            ForEach(availableIcons, id: \.self) { icon in
                                let isSelected = (selectedIcon == icon)

                                Button(action: {
                                    HapticManager.shared.touchLight()
                                    selectedIcon = icon
                                }) {
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                                            .fill(
                                                isSelected ?
                                                (colorScheme == .dark ? Color.white : Color.black) :
                                                theme.cardBackground(for: colorScheme)
                                            )
                                            .frame(width: 46, height: 46)

                                        LiquidIconView(
                                            icon,
                                            size: 20,
                                            color: isSelected ?
                                            (colorScheme == .dark ? Color.black : Color.white) :
                                            theme.textPrimary(for: colorScheme)
                                        )
                                    }
                                    .overlay {
                                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                                            .strokeBorder(
                                                theme.specularBorder(for: colorScheme),
                                                lineWidth: 0.5
                                            )
                                    }
                                }
                                .buttonStyle(.plain)
                                .pressableFeedback()
                            }
                        }
                    }
                    .padding(.horizontal, 20)

                    Spacer()

                    // Botón de Confirmación
                    Button(action: {
                        saveSpace()
                    }) {
                        Text(existingSpace != nil ? "Guardar Cambios" : "Crear Espacio")
                            .font(.system(size: 16, weight: .semibold, design: .rounded))
                            .frame(maxWidth: .infinity)
                            .frame(height: 52)
                            .background {
                                RoundedRectangle(cornerRadius: 18, style: .continuous)
                                    .fill(colorScheme == .dark ? Color.white : Color.black)
                            }
                            .foregroundStyle(colorScheme == .dark ? Color.black : Color.white)
                            .shadow(color: theme.shadowColor(for: colorScheme), radius: 10, y: 4)
                    }
                    .pressableFeedback()
                    .disabled(spaceName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    .opacity(spaceName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? 0.4 : 1.0)
                    .padding(.horizontal, 20)
                    .padding(.bottom, 24)
                }
            }
            .navigationTitle(existingSpace != nil ? "Editar Espacio" : "Nuevo Espacio")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") {
                        dismiss()
                    }
                    .font(.system(size: 15, weight: .medium, design: .rounded))
                    .foregroundStyle(theme.textPrimary(for: colorScheme))
                }
            }
        }
    }

    private func saveSpace() {
        let trimmed = spaceName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        if let existing = existingSpace {
            var updated = existing
            updated.name = trimmed
            updated.icon = selectedIcon
            StorageEngine.shared.updateSpace(updated)
        } else {
            _ = StorageEngine.shared.createSpace(
                name: trimmed,
                icon: selectedIcon,
                isPrivate: false,
                color: .monochrome
            )
        }

        HapticManager.shared.notifySuccess()
        dismiss()
    }
}
