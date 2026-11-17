import SwiftUI

@main
struct LiquidBrowserApp: App {
    @State private var storage = StorageEngine.shared
    @State private var themeManager = ThemeManager.shared
    @State private var lockManager = BiometricLockManager.shared
    @Environment(\.scenePhase) private var scenePhase

    var body: some Scene {
        WindowGroup {
            ZStack {
                Group {
                    if storage.hasCompletedOnboarding {
                        BrowserRootView()
                    } else {
                        OnboardingView {
                            withAnimation(LiquidAnimation.smoothSpring) {
                                storage.hasCompletedOnboarding = true
                            }
                        }
                    }
                }

                // Pantalla de Bloqueo Persistente de Seguridad
                if storage.hasCompletedOnboarding && lockManager.isAppLocked && KeychainVault.shared.isAppLockEnabled {
                    AppLockScreenView {
                        withAnimation(LiquidAnimation.interactiveSpring) {
                            lockManager.isAppLocked = false
                        }
                    }
                    .transition(.opacity)
                    .zIndex(999)
                }
            }
            .preferredColorScheme(themeManager.preferredColorScheme)
            .onChange(of: scenePhase) { _, newPhase in
                lockManager.handleScenePhaseChange(newPhase)
            }
            .onAppear {
                if KeychainVault.shared.isAppLockEnabled {
                    lockManager.isAppLocked = true
                }
            }
        }
    }
}
