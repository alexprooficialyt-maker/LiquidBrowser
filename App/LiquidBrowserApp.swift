import SwiftUI

@main
struct LiquidBrowserApp: App {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @State private var themeManager = ThemeManager.shared
    @Environment(\.scenePhase) private var scenePhase

    @State private var isAppLocked: Bool = KeychainSecurityHelper.shared.isAppLockEnabled

    var body: some Scene {
        WindowGroup {
            ZStack {
                Group {
                    if hasCompletedOnboarding {
                        BrowserRootView()
                    } else {
                        OnboardingView {
                            hasCompletedOnboarding = true
                        }
                    }
                }

                if hasCompletedOnboarding && isAppLocked && KeychainSecurityHelper.shared.isAppLockEnabled {
                    AppLockScreenView {
                        withAnimation(LiquidAnimation.interactiveSpring) {
                            isAppLocked = false
                        }
                    }
                    .transition(.opacity)
                    .zIndex(999)
                }
            }
            .preferredColorScheme(themeManager.preferredColorScheme)
            .onChange(of: scenePhase) { _, newPhase in
                if newPhase == .background && KeychainSecurityHelper.shared.isAppLockEnabled {
                    isAppLocked = true
                }
            }
        }
    }
}
