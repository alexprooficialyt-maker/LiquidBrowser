import SwiftUI

struct WelcomeStepView: View {
    var onContinue: () -> Void

    @State private var logoScale:  CGFloat = 0.3
    @State private var logoAlpha:  Double  = 0
    @State private var bodyAlpha:  Double  = 0
    @State private var btnAlpha:   Double  = 0

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            // Logo
            logoView
                .scaleEffect(logoScale)
                .opacity(logoAlpha)

            Spacer().frame(height: 40)

            // Título y claim
            VStack(spacing: 10) {
                Text("Liquid Browser")
                    .font(.system(size: 38, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)

                Text("Rápido. Privado. Tuyo.")
                    .font(.system(size: 17, weight: .medium, design: .rounded))
                    .foregroundStyle(.white.opacity(0.55))
            }
            .opacity(bodyAlpha)

            Spacer().frame(height: 32)

            // Features
            VStack(spacing: 13) {
                featureRow("30 funciones nativas",   "Navegación completa sin límites")
                featureRow("Cero rastreadores",      "Sin publicidad. Sin IA. Sin datos")
                featureRow("Liquid Glass iOS 26",    "Diseño especular translúcido real")
            }
            .padding(.horizontal, 32)
            .opacity(bodyAlpha)

            Spacer()

            // Botón
            startButton
                .opacity(btnAlpha)

            Spacer().frame(height: 54)
        }
        .onAppear(perform: animateIn)
    }

    // MARK: - Logo

    @ViewBuilder
    private var logoView: some View {
        ZStack {
            // Resplandor difuso detrás
            Circle()
                .fill(
                    RadialGradient(
                        colors: [Color.blue.opacity(0.35), Color.clear],
                        center: .center,
                        startRadius: 0,
                        endRadius: 80
                    )
                )
                .frame(width: 160, height: 160)
                .blur(radius: 18)

            // Superficie de cristal
            Circle()
                .fill(.ultraThinMaterial)
                .frame(width: 100, height: 100)
                .overlay(
                    // Borde especular concéntrico
                    Circle().strokeBorder(
                        LinearGradient(
                            colors: [.white.opacity(0.60), .white.opacity(0.08)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1.0
                    )
                )
                .shadow(color: Color.blue.opacity(0.35), radius: 24, y: 10)

            // Globo vectorial
            GlobeIcon()
                .stroke(
                    LinearGradient(
                        colors: [.white, .white.opacity(0.55)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    style: .init(lineWidth: 1.8, lineCap: .round)
                )
                .frame(width: 46, height: 46)
        }
    }

    // MARK: - Feature row

    @ViewBuilder
    private func featureRow(_ badge: String, _ desc: String) -> some View {
        HStack(alignment: .center, spacing: 14) {
            Text(badge)
                .font(.system(size: 11, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
                .padding(.horizontal, 10).padding(.vertical, 5)
                .background(.white.opacity(0.12))
                .clipShape(Capsule())
                .overlay(Capsule().strokeBorder(.white.opacity(0.25), lineWidth: 0.6))

            Text(desc)
                .font(.system(size: 13, weight: .regular, design: .rounded))
                .foregroundStyle(.white.opacity(0.60))
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    // MARK: - Botón principal

    @ViewBuilder
    private var startButton: some View {
        Button(action: onContinue) {
            Text("Empezar")
                .font(.system(size: 17, weight: .semibold, design: .rounded))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(
                    LinearGradient(
                        colors: [
                            Color(red: 0.22, green: 0.44, blue: 1.00),
                            Color(red: 0.52, green: 0.26, blue: 1.00)
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .strokeBorder(
                            LinearGradient(
                                colors: [.white.opacity(0.45), .white.opacity(0.10)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 0.8
                        )
                )
                .shadow(color: Color(red: 0.22, green: 0.44, blue: 1.0).opacity(0.45), radius: 18, y: 8)
        }
        .padding(.horizontal, 28)
    }

    // MARK: - Animación de entrada

    private func animateIn() {
        withAnimation(.spring(response: 0.72, dampingFraction: 0.62).delay(0.10)) {
            logoScale = 1.0
            logoAlpha = 1.0
        }
        withAnimation(.easeOut(duration: 0.50).delay(0.52)) { bodyAlpha = 1.0 }
        withAnimation(.easeOut(duration: 0.42).delay(0.90)) { btnAlpha  = 1.0 }
    }
}
