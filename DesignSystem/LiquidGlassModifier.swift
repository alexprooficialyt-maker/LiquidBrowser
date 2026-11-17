import SwiftUI

// MARK: - Configuración

struct LiquidGlassStyle {
    var cornerRadius: CGFloat     = 24
    var intensity: Double         = 1.0
    var specularIntensity: Double = 1.0
    var shadowRadius: CGFloat     = 18
    var shadowY: CGFloat          = 10
    var shadowOpacity: Double     = 0.20
}

// MARK: - Modificador principal — Liquid Glass

struct LiquidGlassModifier: ViewModifier {
    @Environment(\.colorScheme) private var scheme
    var style: LiquidGlassStyle

    private var fillAlpha: Double {
        scheme == .dark
            ? 0.07 * style.intensity
            : 0.13 * style.intensity
    }

    func body(content: Content) -> some View {
        content
            .background(glassStack)
            .clipShape(RoundedRectangle(cornerRadius: style.cornerRadius, style: .continuous))
            .overlay(specularRing)
            .shadow(
                color: Color.black.opacity(style.shadowOpacity),
                radius: style.shadowRadius,
                x: 0, y: style.shadowY
            )
    }

    @ViewBuilder
    private var glassStack: some View {
        ZStack {
            // 1. Material base (desenfoque real del sistema)
            RoundedRectangle(cornerRadius: style.cornerRadius, style: .continuous)
                .fill(.ultraThinMaterial)

            // 2. Fill de color translúcido (tono claro/oscuro)
            RoundedRectangle(cornerRadius: style.cornerRadius, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(fillAlpha * 1.6),
                            Color.white.opacity(fillAlpha * 0.4)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )

            // 3. Brillo interior muy difuso (profundidad)
            RoundedRectangle(cornerRadius: style.cornerRadius, style: .continuous)
                .fill(
                    RadialGradient(
                        colors: [Color.white.opacity(0.08), Color.clear],
                        center: .topLeading,
                        startRadius: 0,
                        endRadius: 120
                    )
                )
        }
    }

    // Borde especular: línea de luz en el filo del cristal
    @ViewBuilder
    private var specularRing: some View {
        RoundedRectangle(cornerRadius: style.cornerRadius, style: .continuous)
            .strokeBorder(
                LinearGradient(
                    stops: [
                        .init(color: Color.white.opacity(0.55 * style.specularIntensity), location: 0.00),
                        .init(color: Color.white.opacity(0.20 * style.specularIntensity), location: 0.40),
                        .init(color: Color.white.opacity(0.05 * style.specularIntensity), location: 1.00)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ),
                lineWidth: 0.8
            )
    }
}

// MARK: - Cápsula Glass (barra flotante inferior)

struct LiquidCapsuleModifier: ViewModifier {
    @Environment(\.colorScheme) private var scheme

    private var alpha: Double { scheme == .dark ? 0.07 : 0.12 }

    func body(content: Content) -> some View {
        content
            .background(capsuleStack)
            .clipShape(Capsule())
            .overlay(capsuleSpecular)
            .shadow(color: .black.opacity(0.22), radius: 24, x: 0, y: 12)
    }

    @ViewBuilder
    private var capsuleStack: some View {
        ZStack {
            Capsule().fill(.ultraThinMaterial)
            Capsule().fill(
                LinearGradient(
                    colors: [Color.white.opacity(alpha * 1.5), Color.white.opacity(alpha * 0.3)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
        }
    }

    @ViewBuilder
    private var capsuleSpecular: some View {
        Capsule().strokeBorder(
            LinearGradient(
                stops: [
                    .init(color: .white.opacity(0.52), location: 0.0),
                    .init(color: .white.opacity(0.08), location: 1.0)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            ),
            lineWidth: 0.8
        )
    }
}

// MARK: - View Extensions

extension View {
    func liquidGlass(
        cornerRadius: CGFloat = 24,
        intensity: Double = 1.0,
        specular: Double = 1.0,
        shadowRadius: CGFloat = 18,
        shadowY: CGFloat = 10
    ) -> some View {
        modifier(LiquidGlassModifier(style: .init(
            cornerRadius: cornerRadius,
            intensity: intensity,
            specularIntensity: specular,
            shadowRadius: shadowRadius,
            shadowY: shadowY
        )))
    }

    func liquidCapsule() -> some View {
        modifier(LiquidCapsuleModifier())
    }
}

// MARK: - Fondo oscuro con gradiente negro profundo

struct DarkGradientBackground: View {
    var body: some View {
        ZStack {
            // Gradiente base oscuro
            LinearGradient(
                colors: [
                    AppColors.bgDarkTop,
                    AppColors.bgDarkMid,
                    AppColors.bgDarkBot
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            // Orbe 1 — azul profundo
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            Color(red: 0.20, green: 0.35, blue: 1.00).opacity(0.30),
                            Color.clear
                        ],
                        center: .center,
                        startRadius: 0,
                        endRadius: 180
                    )
                )
                .frame(width: 360, height: 360)
                .offset(x: -110, y: -220)
                .blur(radius: 10)

            // Orbe 2 — violeta
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            Color(red: 0.55, green: 0.20, blue: 0.90).opacity(0.22),
                            Color.clear
                        ],
                        center: .center,
                        startRadius: 0,
                        endRadius: 160
                    )
                )
                .frame(width: 300, height: 300)
                .offset(x: 140, y: 160)
                .blur(radius: 8)

            // Orbe 3 — cian suave
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            Color(red: 0.10, green: 0.65, blue: 0.90).opacity(0.14),
                            Color.clear
                        ],
                        center: .center,
                        startRadius: 0,
                        endRadius: 140
                    )
                )
                .frame(width: 240, height: 240)
                .offset(x: 60, y: -60)
                .blur(radius: 6)

            // Velo superior negro→transparente
            LinearGradient(
                colors: [.black.opacity(0.45), .clear],
                startPoint: .top,
                endPoint: .init(x: 0.5, y: 0.35)
            )

            // Velo inferior negro→transparente
            LinearGradient(
                colors: [.black.opacity(0.55), .clear],
                startPoint: .bottom,
                endPoint: .init(x: 0.5, y: 0.65)
            )
        }
    }
}
