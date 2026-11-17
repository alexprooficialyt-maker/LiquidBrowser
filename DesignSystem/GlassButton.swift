import SwiftUI

struct GlassButton: View {
    let icon: AnyView
    var size: CGFloat    = 44
    var isActive: Bool   = false
    var isDestructive: Bool = false
    var action: () -> Void

    @State private var isPressed = false
    @Environment(\.colorScheme) private var colorScheme

    private var tintColor: Color {
        if isDestructive { return AppColors.danger }
        if isActive      { return .blue }
        return AppColors.primary
    }

    var body: some View {
        Button(action: {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) { isPressed = true }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                isPressed = false
                action()
            }
        }) {
            icon
                .foregroundStyle(tintColor)
                .frame(width: size, height: size)
                .contentShape(Rectangle())
        }
        .scaleEffect(isPressed ? 0.88 : 1.0)
        .animation(.spring(response: 0.25, dampingFraction: 0.65), value: isPressed)
        .buttonStyle(.plain)
    }
}
