import SwiftUI

struct NameStepView: View {
    @Binding var userName: String
    var onContinue: () -> Void

    @State private var appear = false
    @FocusState private var focused: Bool

    private var isValid: Bool {
        userName.trimmingCharacters(in: .whitespacesAndNewlines).count >= 2
    }

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            VStack(spacing: 12) {
                Text("¿Cómo te llamas?")
                    .font(.system(size: 34, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)

                Text("Personaliza la experiencia en tu navegador.")
                    .font(.system(size: 16, weight: .regular, design: .rounded))
                    .foregroundStyle(.white.opacity(0.60))
                    .multilineTextAlignment(.center)
            }
            .opacity(appear ? 1 : 0)
            .offset(y: appear ? 0 : 20)

            Spacer().frame(height: 48)

            VStack(spacing: 10) {
                HStack(spacing: 14) {
                    PersonVectorIcon()
                        .stroke(.white.opacity(0.7), style: .init(lineWidth: 1.8, lineCap: .round, lineJoin: .round))
                        .frame(width: 22, height: 22)

                    TextField("Tu nombre", text: $userName)
                        .font(.system(size: 20, weight: .medium, design: .rounded))
                        .foregroundStyle(.white)
                        .tint(Color(red: 0.35, green: 0.65, blue: 1.0))
                        .focused($focused)
                        .submitLabel(.continue)
                        .onSubmit {
                            if isValid { onContinue() }
                        }

                    if !userName.isEmpty {
                        Button {
                            userName = ""
                        } label: {
                            Circle()
                                .fill(.white.opacity(0.20))
                                .frame(width: 24, height: 24)
                                .overlay(
                                    PlusIcon()
                                        .stroke(.white.opacity(0.85), style: .init(lineWidth: 1.6, lineCap: .round))
                                        .frame(width: 10, height: 10)
                                        .rotationEffect(.degrees(45))
                                )
                        }
                        .transition(.scale.combined(with: .opacity))
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 18)
                .liquidGlass(cornerRadius: 22, intensity: 0.95, specular: 1.1)
                .overlay(
                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                        .strokeBorder(
                            focused ? Color(red: 0.35, green: 0.65, blue: 1.0).opacity(0.8) : Color.clear,
                            lineWidth: 1.5
                        )
                        .animation(.easeInOut(duration: 0.2), value: focused)
                )

                GeometryReader { geo in
                    let ratio = min(Double(userName.count) / 12.0, 1.0)
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 2, style: .continuous)
                            .fill(.white.opacity(0.12))
                        RoundedRectangle(cornerRadius: 2, style: .continuous)
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color(red: 0.25, green: 0.55, blue: 1.0),
                                        Color(red: 0.65, green: 0.30, blue: 0.95)
                                    ],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: geo.size.width * ratio)
                            .animation(.spring(response: 0.3), value: userName.count)
                    }
                }
                .frame(height: 3)
                .padding(.horizontal, 6)
            }
            .padding(.horizontal, 28)
            .opacity(appear ? 1 : 0)
            .offset(y: appear ? 0 : 30)

            Spacer()

            Button(action: onContinue) {
                HStack(spacing: 10) {
                    Text("Continuar")
                        .font(.system(size: 17, weight: .semibold, design: .rounded))
                    ForwardIcon()
                        .stroke(.white, style: .init(lineWidth: 2.2, lineCap: .round, lineJoin: .round))
                        .frame(width: 16, height: 16)
                }
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(
                    Group {
                        if isValid {
                            LinearGradient(
                                colors: [
                                    Color(red: 0.22, green: 0.45, blue: 1.00),
                                    Color(red: 0.52, green: 0.26, blue: 1.00)
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        } else {
                            Color.white.opacity(0.12)
                        }
                    }
                )
                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .strokeBorder(
                            isValid ? .white.opacity(0.4) : .white.opacity(0.15),
                            lineWidth: 0.8
                        )
                )
                .shadow(
                    color: isValid ? Color(red: 0.22, green: 0.45, blue: 1.00).opacity(0.4) : .clear,
                    radius: 16,
                    y: 8
                )
                .animation(.easeInOut(duration: 0.2), value: isValid)
            }
            .disabled(!isValid)
            .padding(.horizontal, 28)
            .opacity(appear ? 1 : 0)

            Spacer().frame(height: 52)
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.1)) {
                appear = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                focused = true
            }
        }
    }
}

private struct PersonVectorIcon: Shape {
    func path(in rect: CGRect) -> Path {
        var p = Path()
        let cx = rect.midX
        let w = rect.width, h = rect.height
        let headR = w * 0.23
        p.addEllipse(in: .init(x: cx - headR, y: h * 0.06, width: headR * 2, height: headR * 2))
        p.move(to: .init(x: w * 0.08, y: h * 0.94))
        p.addQuadCurve(to: .init(x: w * 0.92, y: h * 0.94), control: .init(x: cx, y: h * 0.54))
        return p
    }
}
