import SwiftUI

// MARK: - FindInPageBar (Búsqueda en Página en Cristal Líquido)

public struct FindInPageBar: View {
    @Binding var searchText: String
    @Binding var currentMatch: Int
    @Binding var totalMatches: Int

    var onNext: () -> Void
    var onPrevious: () -> Void
    var onClose: () -> Void

    @Environment(\.colorScheme) private var colorScheme
    @FocusState private var isSearchFocused: Bool

    public init(
        searchText: Binding<String>,
        currentMatch: Binding<Int>,
        totalMatches: Binding<Int>,
        onNext: @escaping () -> Void,
        onPrevious: @escaping () -> Void,
        onClose: @escaping () -> Void
    ) {
        self._searchText = searchText
        self._currentMatch = currentMatch
        self._totalMatches = totalMatches
        self.onNext = onNext
        self.onPrevious = onPrevious
        self.onClose = onClose
    }

    public var body: some View {
        let theme = ThemeManager.shared

        HStack(spacing: 8) {
            LiquidIconView(.search, size: 14, color: theme.textSecondary(for: colorScheme))

            TextField("Buscar en página...", text: $searchText)
                .font(.system(size: 14, design: .rounded))
                .foregroundStyle(theme.textPrimary(for: colorScheme))
                .focused($isSearchFocused)
                .autocorrectionDisabled()
                .textInputAutocapitalization(.never)
                .submitLabel(.search)
                .onSubmit {
                    onNext()
                }

            if totalMatches > 0 {
                Text("\(currentMatch)/\(totalMatches)")
                    .font(.system(size: 11, weight: .semibold, design: .rounded))
                    .foregroundStyle(theme.textSecondary(for: colorScheme))
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(theme.cardBackground(for: colorScheme))
                    .clipShape(Capsule())
            }

            // Anterior
            Button(action: {
                HapticManager.shared.touchLight()
                onPrevious()
            }) {
                LiquidIconView(.chevronUp, size: 12, color: theme.textPrimary(for: colorScheme))
                    .padding(6)
                    .background(theme.cardBackground(for: colorScheme))
                    .clipShape(Circle())
            }
            .pressableFeedback()

            // Siguiente
            Button(action: {
                HapticManager.shared.touchLight()
                onNext()
            }) {
                LiquidIconView(.chevronDown, size: 12, color: theme.textPrimary(for: colorScheme))
                    .padding(6)
                    .background(theme.cardBackground(for: colorScheme))
                    .clipShape(Circle())
            }
            .pressableFeedback()

            // Cerrar
            Button(action: {
                HapticManager.shared.touchLight()
                onClose()
            }) {
                LiquidIconView(.close, size: 12, color: theme.textSecondary(for: colorScheme))
                    .padding(6)
            }
            .pressableFeedback()
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 8)
        .liquidGlass(config: .chip)
        .onAppear {
            isSearchFocused = true
        }
    }
}
