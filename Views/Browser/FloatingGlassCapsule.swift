import SwiftUI

public struct FloatingGlassCapsule: View {
    @Bindable var coordinator: WebEngineCoordinator
    var onOpenTabs: () -> Void
    var onOpenTools: () -> Void

    @State private var isEditingURL: Bool = false
    @State private var urlInputText: String = ""
    @State private var barDragOffset: CGFloat = 0

    @Environment(\.colorScheme) private var colorScheme
    @FocusState private var isFieldFocused: Bool

    public init(
        coordinator: WebEngineCoordinator,
        onOpenTabs: @escaping () -> Void,
        onOpenTools: @escaping () -> Void
    ) {
        self.coordinator = coordinator
        self.onOpenTabs = onOpenTabs
        self.onOpenTools = onOpenTools
    }

    public var body: some View {
        let theme = ThemeEngine.shared

        VStack(spacing: 0) {
            if coordinator.currentIsLoading {
                progressBar(theme: theme)
            }

            HStack(spacing: 8) {
                if !isEditingURL {
                    LiquidIconButton(.back, size: 36, iconSize: 15) {
                        coordinator.goBack()
                    }
                    .disabled(!coordinator.currentCanGoBack)
                    .opacity(coordinator.currentCanGoBack ? 1.0 : 0.3)

                    LiquidIconButton(.forward, size: 36, iconSize: 15) {
                        coordinator.goForward()
                    }
                    .disabled(!coordinator.currentCanGoForward)
                    .opacity(coordinator.currentCanGoForward ? 1.0 : 0.3)
                }

                centerURLBar(theme: theme)

                if isEditingURL {
                    Button("Cancelar") {
                        HapticManager.shared.touchLight()
                        isFieldFocused = false
                        withAnimation(LiquidAnimation.interactiveSpring) {
                            isEditingURL = false
                        }
                    }
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundStyle(theme.textPrimary(for: colorScheme))
                    .padding(.trailing, 4)
                } else {
                    LiquidIconButton(.share, size: 36, iconSize: 15) {
                        onOpenTools()
                    }

                    LiquidIconButton(.tabs, size: 36, iconSize: 15) {
                        onOpenTabs()
                    }
                    .overlay(alignment: .topTrailing) {
                        let count = coordinator.tabsInActiveSpace.count
                        if count > 1 {
                            Text("\(count)")
                                .font(.system(size: 9, weight: .bold, design: .rounded))
                                .foregroundStyle(colorScheme == .dark ? Color.black : Color.white)
                                .padding(.horizontal, 4)
                                .padding(.vertical, 1)
                                .background {
                                    Capsule().fill(colorScheme == .dark ? Color.white : Color.black)
                                }
                                .offset(x: 2, y: -2)
                        }
                    }
                }
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 8)
        }
        .liquidGlass(config: .capsuleBar)
        .padding(.horizontal, 16)
        .gesture(
            DragGesture(minimumDistance: 25)
                .onChanged { val in
                    barDragOffset = val.translation.width
                }
                .onEnded { val in
                    handleHorizontalSwipe(dx: val.translation.width)
                    barDragOffset = 0
                }
        )
    }

    @ViewBuilder
    private func progressBar(theme: ThemeEngine) -> some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                Rectangle()
                    .fill(Color.clear)

                RoundedRectangle(cornerRadius: 1, style: .continuous)
                    .fill(theme.progressHighlight(for: colorScheme))
                    .frame(width: max(0, geo.size.width * coordinator.currentProgress), height: 2.0)
                    .animation(LiquidAnimation.progressEase, value: coordinator.currentProgress)
            }
        }
        .frame(height: 2.0)
        .padding(.horizontal, 19)
    }

    @ViewBuilder
    private func centerURLBar(theme: ThemeEngine) -> some View {
        HStack(spacing: 8) {
            LiquidIconView(
                coordinator.currentIsSecure ? .lockSSL : .unlockSSL,
                size: 13,
                color: theme.textSecondary(for: colorScheme)
            )

            if isEditingURL {
                TextField("Buscar o escribir URL…", text: $urlInputText)
                    .font(.system(size: 15, weight: .medium, design: .rounded))
                    .foregroundStyle(theme.textPrimary(for: colorScheme))
                    .focused($isFieldFocused)
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.never)
                    .keyboardType(.webSearch)
                    .submitLabel(.go)
                    .onSubmit {
                        commitNavigation()
                    }

                if !urlInputText.isEmpty {
                    Button(action: { urlInputText = "" }) {
                        LiquidIconView(.close, size: 12, color: theme.textSecondary(for: colorScheme))
                    }
                }
            } else {
                Button(action: {
                    HapticManager.shared.touchLight()
                    urlInputText = coordinator.currentURLString
                    withAnimation(LiquidAnimation.interactiveSpring) {
                        isEditingURL = true
                        isFieldFocused = true
                    }
                }) {
                    Text(displayTitleOrHost)
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundStyle(theme.textPrimary(for: colorScheme))
                        .lineLimit(1)
                        .frame(maxWidth: .infinity, alignment: .center)
                }
                .buttonStyle(.plain)

                if coordinator.currentIsLoading {
                    Button(action: {
                        coordinator.stop()
                    }) {
                        LiquidIconView(.close, size: 12, color: theme.textSecondary(for: colorScheme))
                            .padding(4)
                    }
                } else {
                    Button(action: {
                        coordinator.reload()
                    }) {
                        LiquidIconView(.reload, size: 12, color: theme.textSecondary(for: colorScheme))
                            .padding(4)
                    }
                }
            }
        }
        .padding(.horizontal, 12)
        .frame(height: 36)
        .background {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(colorScheme == .dark ? Color.white.opacity(0.06) : Color.black.opacity(0.04))
        }
        .overlay {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .strokeBorder(theme.borderSpecular(for: colorScheme), lineWidth: 0.5)
        }
    }

    private var displayTitleOrHost: String {
        if let tab = coordinator.activeTab {
            return tab.displayHost
        }
        return "Buscar o URL"
    }

    private func commitNavigation() {
        let input = urlInputText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !input.isEmpty else { return }
        HapticManager.shared.touchMedium()
        isFieldFocused = false
        withAnimation(LiquidAnimation.interactiveSpring) {
            isEditingURL = false
        }
        coordinator.navigate(to: input)
    }

    private func handleHorizontalSwipe(dx: CGFloat) {
        let inSpace = coordinator.tabsInActiveSpace
        guard inSpace.count > 1, let curID = coordinator.activeTabID,
              let idx = inSpace.firstIndex(where: { $0.id == curID }) else { return }

        if dx < -40 && idx < inSpace.count - 1 {
            HapticManager.shared.selectionChanged()
            coordinator.selectTab(id: inSpace[idx + 1].id)
        } else if dx > 40 && idx > 0 {
            HapticManager.shared.selectionChanged()
            coordinator.selectTab(id: inSpace[idx - 1].id)
        }
    }
}
