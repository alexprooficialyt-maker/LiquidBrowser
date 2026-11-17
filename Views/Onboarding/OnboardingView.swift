import SwiftUI

struct OnboardingView: View {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @AppStorage("userName") private var userName = ""
    @AppStorage("userAge")  private var userAge  = 0

    @State private var step              = 0
    @State private var transitionForward = true

    var body: some View {
        ZStack {
            DarkGradientBackground().ignoresSafeArea()

            Group {
                switch step {
                case 0:  WelcomeStepView  { advance(to: 1) }.transition(slide)
                case 1:  NameStepView(userName: $userName) { advance(to: 2) }.transition(slide)
                case 2:  AgeStepView(userAge: $userAge)   { finish()       }.transition(slide)
                default: EmptyView()
                }
            }
            .animation(.spring(response: 0.52, dampingFraction: 0.78), value: step)
        }
    }

    private var slide: AnyTransition {
        .asymmetric(
            insertion: .move(edge: transitionForward ? .trailing : .leading).combined(with: .opacity),
            removal:   .move(edge: transitionForward ? .leading  : .trailing).combined(with: .opacity)
        )
    }

    private func advance(to s: Int) {
        transitionForward = s > step
        withAnimation(.spring(response: 0.52, dampingFraction: 0.78)) { step = s }
    }

    private func finish() {
        withAnimation(.easeInOut(duration: 0.4)) { hasCompletedOnboarding = true }
    }
}
