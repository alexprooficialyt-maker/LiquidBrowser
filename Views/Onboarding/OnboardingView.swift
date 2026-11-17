import SwiftUI

// MARK: - OnboardingView (Bridge Alias to 5-Step OnboardingFlowView)

public struct OnboardingView: View {
    public var onFinished: () -> Void

    public init(onFinished: @escaping () -> Void = {}) {
        self.onFinished = onFinished
    }

    public var body: some View {
        OnboardingFlowView(onFinished: onFinished)
    }
}
