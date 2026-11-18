import SwiftUI

// MARK: - WelcomeLetterAnimationView (Cinematic Letter-by-Letter Apple Welcome)

public struct WelcomeLetterAnimationView: View {
    public let userName: String
    public var onComplete: () -> Void

    @Environment(\.colorScheme) private var systemColorScheme
    @State private var revealedIndices: Set<Int> = []
    @State private var isGlowActive: Bool = false
    @State private var isFadingOut: Bool = false

    private var fullGreeting: String {
        let trimmed = userName.trimmingCharacters(in: .whitespacesAndNewlines)
        let name = trimmed.isEmpty ? "SmartBot" : trimmed
        let format = Loc.tr("welcome_title") // "Hola, %@" o "Bienvenido"
        if format.contains("%@") {
            return String(format: format, name)
        }
        return "\(format), \(name)"
    }

    public init(userName: String, onComplete: @escaping () -> Void) {
        self.userName = userName
        self.onComplete = onComplete
    }

    public var body: some View {
        let theme = ThemeManager.shared
        let scheme = theme.effectiveScheme(systemScheme: systemColorScheme)
        let characters = Array(fullGreeting)

        ZStack {
            // Fondo monocromo puro con desenfoque de cristal
            theme.background(for: scheme)
                .ignoresSafeArea()

            VStack(spacing: 36) {
                Spacer()

                // Icono Central de SmartBot con Reflejo Especular Líquido
                ZStack {
                    Circle()
                        .fill(theme.glassMaterialFill(for: scheme))
                        .frame(width: 88, height: 88)
                        .overlay {
                            Circle().strokeBorder(theme.borderSpecular(for: scheme), lineWidth: 0.5)
                        }

                    LiquidIconView(.shieldActive, size: 40, color: theme.textPrimary(for: scheme))
                }
                .scaleEffect(revealedIndices.count > 0 ? 1.0 : 0.6)
                .opacity(revealedIndices.count > 0 ? 1.0 : 0.0)
                .animation(LiquidAnimation.cinematicEntrance, value: revealedIndices.count > 0)

                // Texto Cinemático Letra por Letra
                FlowLayout(spacing: 0) {
                    ForEach(Array(characters.enumerated()), id: \.offset) { idx, char in
                        let isRevealed = revealedIndices.contains(idx)
                        let charString = String(char)

                        Text(charString == " " ? "\u{00A0}" : charString)
                            .font(.system(size: 32, weight: .bold, design: .rounded))
                            .foregroundStyle(theme.textPrimary(for: scheme))
                            .opacity(isRevealed ? 1.0 : 0.0)
                            .blur(radius: isRevealed ? 0 : 8)
                            .scaleEffect(isRevealed ? 1.0 : 0.75)
                            .offset(y: isRevealed ? 0 : 12)
                            .animation(.spring(response: 0.45, dampingFraction: 0.75), value: isRevealed)
                    }
                }
                .padding(.horizontal, 32)
                .multilineTextAlignment(.center)

                // Subtítulo con desvanecimiento elegante
                Text(Loc.tr("app_tagline"))
                    .font(.system(size: 15, weight: .medium, design: .default))
                    .foregroundStyle(theme.textSecondary(for: scheme))
                    .opacity(isGlowActive ? 1.0 : 0.0)
                    .offset(y: isGlowActive ? 0 : 8)
                    .animation(LiquidAnimation.smoothSpring, value: isGlowActive)

                Spacer()
            }
            .opacity(isFadingOut ? 0.0 : 1.0)
            .animation(.easeInOut(duration: 0.4), value: isFadingOut)
        }
        .onAppear {
            startLetterSequence(total: characters.count)
        }
    }

    private func startLetterSequence(total: Int) {
        let baseDelay = 0.032

        for i in 0..<total {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * baseDelay + 0.15) {
                _ = revealedIndices.insert(i)
                if i % 5 == 0 {
                    HapticManager.shared.touchSoft()
                }
            }
        }

        let totalTime = Double(total) * baseDelay + 0.30

        // Activar subtítulo y brillo
        DispatchQueue.main.asyncAfter(deadline: .now() + totalTime) {
            HapticManager.shared.notifySuccess()
            withAnimation(LiquidAnimation.smoothSpring) {
                isGlowActive = true
            }
        }

        // Transición fluida e instantánea al navegador
        DispatchQueue.main.asyncAfter(deadline: .now() + totalTime + 1.4) {
            withAnimation(.easeInOut(duration: 0.4)) {
                isFadingOut = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.45) {
                onComplete()
            }
        }
    }
}

// MARK: - FlowLayout Helper para Wrap Natural de Caracteres

private struct FlowLayout: Layout {
    var spacing: CGFloat = 0

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let width = proposal.width ?? 320
        var height: CGFloat = 0
        var x: CGFloat = 0
        var y: CGFloat = 0
        var maxHeightInRow: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if x + size.width > width && x > 0 {
                x = 0
                y += maxHeightInRow
                maxHeightInRow = 0
            }
            maxHeightInRow = max(maxHeightInRow, size.height)
            x += size.width + spacing
        }
        height = y + maxHeightInRow
        return CGSize(width: width, height: height)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        var x = bounds.minX
        var y = bounds.minY
        var maxHeightInRow: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if x + size.width > bounds.maxX && x > bounds.minX {
                x = bounds.minX
                y += maxHeightInRow
                maxHeightInRow = 0
            }
            subview.place(at: CGPoint(x: x, y: y), proposal: .unspecified)
            maxHeightInRow = max(maxHeightInRow, size.height)
            x += size.width + spacing
        }
    }
}
