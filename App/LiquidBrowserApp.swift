import SwiftUI

@main
struct LiquidBrowserApp: App {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @State private var appState = AppState()

    var body: some Scene {
        WindowGroup {
            if hasCompletedOnboarding {
                BrowserView()
                    .environment(appState)
            } else {
                OnboardingView()
                    .environment(appState)
            }
        }
    }
}
