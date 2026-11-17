import SwiftUI

struct AgeStepView: View {
    @Binding var userAge: Int
    var onContinue: () -> Void

    @State private var appear = false
    @State private var selectedAge: Int = 24
    private let availableAges = Array(12...99)

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            VStack(spacing: 12) {
                Text("Tu edad")
                    .font(.system(size: 34, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)

                Text("Ajusta los parámetros de visualización recomendados.")
                    .font(.system(size: 16, weight: .regular, design: .rounded))
                    .foregroundStyle(.white.opacity(0.60))
                    .multilineTextAlignment(.center)
            }
            .opacity(appear ? 1 : 0)
            .offset(y: appear ? 0 : 20)

            Spacer().frame(height: 40)

            ZStack {
                RoundedRectangle(cornerRadius: 26, style: .continuous)
                    .fill(.ultraThinMaterial)
                    .frame(height: 220)
                    .overlay(
                        RoundedRectangle(cornerRadius: 26, style: .continuous)
                            .strokeBorder(
                                LinearGradient(
                                    colors: [.white.opacity(0.55), .white.opacity(0.08)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 0.8
                            )
                    )

                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(.white.opacity(0.12))
                    .frame(height: 48)
                    .overlay(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .strokeBorder(.white.opacity(0.35), lineWidth: 0.8)
                    )
                    .padding(.horizontal, 20)

                Picker("Edad", selection: $selectedAge) {
                    ForEach(availableAges, id: \.self) { age in
                        Text("\(age)")
                            .font(.system(size: 26, weight: .semibold, design: .rounded))
                            .foregroundStyle(.white)
                            .tag(age)
                    }
                }
                .pickerStyle(.wheel)
                .frame(height: 200)
                .clipped()
                .padding(.horizontal, 20)
            }
            .padding(.horizontal, 28)
            .opacity(appear ? 1 : 0)
            .offset(y: appear ? 0 : 30)

            Text("\(selectedAge) años")
                .font(.system(size: 44, weight: .bold, design: .rounded))
                .foregroundStyle(
                    LinearGradient(
                        colors: [.white, .white.opacity(0.65)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .padding(.top, 24)
                .opacity(appear ? 1 : 0)
                .animation(.spring(response: 0.3), value: selectedAge)

            Spacer()

            Button(action: {
                userAge = selectedAge
                onContinue()
            }) {
                HStack(spacing: 10) {
                    Text("Empezar a navegar")
                        .font(.system(size: 17, weight: .semibold, design: .rounded))

                    SpeedArrowIcon()
                        .stroke(.white, style: .init(lineWidth: 2.2, lineCap: .round, lineJoin: .round))
                        .frame(width: 18, height: 18)
                }
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(
                    LinearGradient(
                        colors: [
                            Color(red: 0.22, green: 0.45, blue: 1.00),
                            Color(red: 0.58, green: 0.22, blue: 0.95)
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .strokeBorder(.white.opacity(0.35), lineWidth: 0.8)
                )
                .shadow(color: Color(red: 0.40, green: 0.30, blue: 0.95).opacity(0.40), radius: 16, y: 8)
            }
            .padding(.horizontal, 28)
            .opacity(appear ? 1 : 0)

            Button(action: {
                userAge = 25
                onContinue()
            }) {
                Text("Omitir")
                    .font(.system(size: 15, weight: .medium, design: .rounded))
                    .foregroundStyle(.white.opacity(0.45))
            }
            .padding(.top, 14)
            .opacity(appear ? 1 : 0)

            Spacer().frame(height: 50)
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.1)) {
                appear = true
            }
        }
    }
}

private struct SpeedArrowIcon: Shape {
    func path(in rect: CGRect) -> Path {
        var p = Path()
        let w = rect.width, h = rect.height
        p.move(to: .init(x: w * 0.15, y: h * 0.50))
        p.addLine(to: .init(x: w * 0.82, y: h * 0.50))
        p.move(to: .init(x: w * 0.52, y: h * 0.20))
        p.addLine(to: .init(x: w * 0.82, y: h * 0.50))
        p.addLine(to: .init(x: w * 0.52, y: h * 0.80))
        return p
    }
}
