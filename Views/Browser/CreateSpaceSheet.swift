import SwiftUI

// MARK: - CreateSpaceSheet (Creación y Edición de Espacios Monocromos)

public struct CreateSpaceSheet: View {
    @Bindable var coordinator: WebEngineCoordinator
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

    public init(coordinator: WebEngineCoordinator, existingSpace: SpaceModel? = nil) {
        self.coordinator = coordinator
        self.existingSpace = existingSpace
        _spaceName = State(initialValue: existingSpace?.name ?? "")
        if let raw = existingSpace?.iconTypeRaw, let icon = LiquidIconType(rawValue: raw) {
            _selectedIcon = State(initialValue: icon)
        }
    }

    public var body: some View {
        let theme = ThemeManager.shared

        NavigationView {
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

                    // Campo de Nombre
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Nombre")
                            .font(.system(size: 13, weight: .semibold, design: .rounded))
                            .foregroundStyle(theme.textSecondary(for: colorScheme))

                        TextField("Ej: Proyectos, Lectura, Noticias", text: $spaceName)
                            .font(.system(size: 16, design: .rounded))
                            .foregroundStyle(theme.textPrimary(for: colorScheme))
                            .padding(.horizontal, 16)
                            .padding(.vertical, 14)
                            .liquidGlass(config: .card)
                    }
                    .padding(.horizontal, 20)

                    // Selector de Iconos Geométricos Monocromos
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Icono Monocromo")
                            .font(.system(size: 13, weight: .semibold, design: .rounded))
                            .foregroundStyle(theme.textSecondary(for: colorScheme))

                        HStack(spacing: 12) {
                            ForEach(availableIcons, id: \.self) { icon in
                                let isSelected = (selectedIcon == icon)

                                Button(action: {
                                    HapticManager.shared.touchLight()
                                    selectedIcon = icon
                                }) {
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                                            .fill(isSelected ? (colorScheme == .dark ? Color.white : Color.black) : theme.cardBackground(for: colorScheme))
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
                                                isSelected ? AnyShapeStyle(Color.clear) : AnyShapeStyle(theme.borderSpecular(for: colorScheme)),
                                                lineWidth: 0.5
                                            )
                                    }
                                }
                                .pressableFeedback()
                            }
                        }
                    }
                    .padding(.horizontal, 20)

                    Spacer()

                    // Botón Guardar
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

        if let existing = existingSpace, let idx = coordinator.spaces.firstIndex(where: { $0.id == existing.id }) {
            coordinator.spaces[idx].name = trimmed
            coordinator.spaces[idx].iconTypeRaw = selectedIcon.rawValue
            coordinator.saveSpaces()
        } else {
            let newSpace = SpaceModel(
                name: trimmed,
                iconTypeRaw: selectedIcon.rawValue,
                orderIndex: coordinator.spaces.count,
                isPinned: false,
                isPrivate: false
            )
            coordinator.spaces.append(newSpace)
            coordinator.activeSpaceID = newSpace.id
            coordinator.saveSpaces()
        }

        HapticManager.shared.notifySuccess()
        dismiss()
    }
}
