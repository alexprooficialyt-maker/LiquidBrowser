import SwiftUI

public struct CreateSpaceSheet: View {
    @Binding var isPresented: Bool
    var onCreated: (String, LiquidIconType) -> Void

    @State private var spaceName: String = ""
    @State private var selectedIcon: LiquidIconType = .spaceFolder

    @Environment(\.colorScheme) private var colorScheme

    private let availableIcons: [LiquidIconType] = [
        .spaceFolder,
        .spaceWork,
        .spaceStudy,
        .spaceCode,
        .spaceStar,
        .bookmark,
        .pin,
        .settings
    ]

    public init(isPresented: Binding<Bool>, onCreated: @escaping (String, LiquidIconType) -> Void) {
        self._isPresented = isPresented
        self.onCreated = onCreated
    }

    public var body: some View {
        let theme = ThemeEngine.shared

        NavigationView {
            ZStack {
                theme.background(for: colorScheme)
                    .ignoresSafeArea()

                VStack(spacing: 24) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Nombre del Espacio")
                            .font(.system(size: 13, weight: .semibold, design: .rounded))
                            .foregroundStyle(theme.textSecondary(for: colorScheme))

                        HStack(spacing: 12) {
                            LiquidIconView(selectedIcon, size: 20, color: theme.textPrimary(for: colorScheme))

                            TextField("Ej. Proyectos, Lecturas…", text: $spaceName)
                                .font(.system(size: 16, weight: .medium, design: .rounded))
                                .foregroundStyle(theme.textPrimary(for: colorScheme))
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 14)
                        .liquidGlass(config: .card)
                    }

                    VStack(alignment: .leading, spacing: 12) {
                        Text("Icono Geométrico")
                            .font(.system(size: 13, weight: .semibold, design: .rounded))
                            .foregroundStyle(theme.textSecondary(for: colorScheme))

                        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 4), spacing: 12) {
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
                                                (colorScheme == .dark ? Color.white.opacity(0.06) : Color.black.opacity(0.04))
                                            )
                                            .frame(height: 52)

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
                                                isSelected ? Color.clear : theme.borderSpecular(for: colorScheme),
                                                lineWidth: 0.5
                                            )
                                    }
                                }
                                .pressableFeedback()
                            }
                        }
                    }

                    Spacer()

                    Button(action: {
                        let trimmed = spaceName.trimmingCharacters(in: .whitespacesAndNewlines)
                        guard !trimmed.isEmpty else { return }
                        HapticManager.shared.notifySuccess()
                        onCreated(trimmed, selectedIcon)
                        isPresented = false
                    }) {
                        Text("Crear Espacio")
                            .font(.system(size: 16, weight: .semibold, design: .rounded))
                            .frame(maxWidth: .infinity)
                            .frame(height: 52)
                            .background {
                                RoundedRectangle(cornerRadius: 18, style: .continuous)
                                    .fill(spaceName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? Color.gray.opacity(0.3) : (colorScheme == .dark ? Color.white : Color.black))
                            }
                            .foregroundStyle(colorScheme == .dark ? Color.black : Color.white)
                    }
                    .disabled(spaceName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    .pressableFeedback()
                }
                .padding(20)
            }
            .navigationTitle("Nuevo Espacio")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") { isPresented = false }
                        .foregroundStyle(theme.textPrimary(for: colorScheme))
                }
            }
        }
    }
}
