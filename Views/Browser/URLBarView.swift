import SwiftUI

// MARK: - URLBarView

struct URLBarView: View {
    @Binding var text: String
    var isEditing: Bool
    var isLoading: Bool
    var isSecure: Bool
    var progress: Double
    var blockedCount: Int
    var onCommit: (String) -> Void
    var onTap: () -> Void
    var onCancel: () -> Void

    @FocusState private var focused: Bool
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        ZStack(alignment: .bottom) {
            mainBar
            // Barra de progreso ultrafina en el borde inferior
            if isLoading {
                progressBar
            }
        }
    }

    // MARK: - Barra principal

    @ViewBuilder
    private var mainBar: some View {
        HStack(spacing: 10) {
            // Icono seguridad / candado
            if !isEditing {
                BrowserIconView(icon: .lock(!isSecure),
                                size: 16,
                                color: isSecure ? AppColors.secure : AppColors.insecure,
                                lineWidth: 1.6)
                    .transition(.scale.combined(with: .opacity))
            }

            // Input / display
            if isEditing {
                TextField("Buscar o introducir URL", text: $text)
                    .font(.system(size: 15, design: .rounded))
                    .foregroundStyle(colorScheme == .dark ? .white : .primary)
                    .tint(.blue)
                    .focused($focused)
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.never)
                    .keyboardType(.URL)
                    .submitLabel(.go)
                    .onSubmit { onCommit(text) }
                    .onAppear { focused = true; text = text }
            } else {
                Button(action: onTap) {
                    Text(displayText)
                        .font(.system(size: 15, weight: .medium, design: .rounded))
                        .foregroundStyle(colorScheme == .dark ? .white : .primary)
                        .lineLimit(1)
                        .frame(maxWidth: .infinity, alignment: .center)
                }
                .buttonStyle(.plain)
            }

            // Contador de bloqueados
            if !isEditing && blockedCount > 0 {
                Text("\(blockedCount)")
                    .font(.system(size: 11, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 6).padding(.vertical, 2)
                    .background(AppColors.secure)
                    .clipShape(Capsule())
                    .transition(.scale.combined(with: .opacity))
            }

            // Botón cancelar
            if isEditing {
                Button("Cancelar", action: onCancel)
                    .font(.system(size: 14, design: .rounded))
                    .foregroundStyle(.blue)
                    .transition(.move(edge: .trailing).combined(with: .opacity))
            }
        }
        .padding(.horizontal, isEditing ? 12 : 10)
        .padding(.vertical, 10)
        .animation(.spring(response: 0.3, dampingFraction: 0.75), value: isEditing)
    }

    // MARK: - Barra de progreso

    @ViewBuilder
    private var progressBar: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(Color.blue.opacity(0.15))
                    .frame(height: 2.5)
                Capsule()
                    .fill(LinearGradient(
                        colors: [.blue, Color(red: 0.4, green: 0.6, blue: 1.0)],
                        startPoint: .leading, endPoint: .trailing
                    ))
                    .frame(width: geo.size.width * progress, height: 2.5)
                    .animation(.linear(duration: 0.2), value: progress)
            }
        }
        .frame(height: 2.5)
        .transition(.opacity)
    }

    // MARK: - Display text

    private var displayText: String {
        if text.isEmpty { return "Buscar o introducir URL" }
        if let url = URL(string: text), let host = url.host {
            return host.replacingOccurrences(of: "www.", with: "")
        }
        return text
    }
}
