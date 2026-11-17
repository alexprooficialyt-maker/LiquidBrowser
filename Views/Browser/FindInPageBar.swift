import SwiftUI

public struct FindInPageBar: View {
    @Binding var searchText: String
    @Binding var currentMatch: Int
    @Binding var totalMatches: Int
    var onNext: () -> Void
    var onPrevious: () -> Void
    var onClose: () -> Void

    @Environment(\.colorScheme) private var colorScheme
    @FocusState private var isFieldFocused: Bool

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
        let theme = ThemeEngine.shared

        HStack(spacing: 12) {
            LiquidIconView(.search, size: 16, color: theme.textSecondary(for: colorScheme))

            TextField("Buscar en la página…", text: $searchText)
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundStyle(theme.textPrimary(for: colorScheme))
                .focused($isFieldFocused)
                .autocorrectionDisabled()
                .submitLabel(.search)
                .onSubmit { onNext() }

            if totalMatches > 0 {
                Text("\(currentMatch)/\(totalMatches)")
                    .font(.system(size: 12, weight: .semibold, design: .rounded))
                    .foregroundStyle(theme.textSecondary(for: colorScheme))
            }

            HStack(spacing: 4) {
                Button(action: onPrevious) {
                    LiquidIconView(.chevronUp, size: 14)
                        .padding(6)
                }
                .disabled(totalMatches == 0)

                Button(action: onNext) {
                    LiquidIconView(.chevronDown, size: 14)
                        .padding(6)
                }
                .disabled(totalMatches == 0)

                Button(action: onClose) {
                    LiquidIconView(.close, size: 14)
                        .padding(6)
                }
            }
            .foregroundStyle(theme.textPrimary(for: colorScheme))
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .liquidGlass(config: .card)
        .onAppear { isFieldFocused = true }
    }
}
