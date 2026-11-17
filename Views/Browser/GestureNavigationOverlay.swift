import SwiftUI
import WebKit

public struct GestureNavigationOverlay: UIViewRepresentable {
    public var webView: WKWebView
    public var onEdgeBack: () -> Void
    public var onEdgeForward: () -> Void

    public init(
        webView: WKWebView,
        onEdgeBack: @escaping () -> Void,
        onEdgeForward: @escaping () -> Void
    ) {
        self.webView = webView
        self.onEdgeBack = onEdgeBack
        self.onEdgeForward = onEdgeForward
    }

    public func makeUIView(context: Context) -> UIView {
        let container = UIView()
        container.backgroundColor = .clear

        let leftSwipe = UIScreenEdgePanGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleLeftEdge(_:)))
        leftSwipe.edges = .left
        container.addGestureRecognizer(leftSwipe)

        let rightSwipe = UIScreenEdgePanGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleRightEdge(_:)))
        rightSwipe.edges = .right
        container.addGestureRecognizer(rightSwipe)

        return container
    }

    public func updateUIView(_ uiView: UIView, context: Context) {}

    public func makeCoordinator() -> Coordinator {
        Coordinator(onEdgeBack: onEdgeBack, onEdgeForward: onEdgeForward)
    }

    public final class Coordinator: NSObject {
        var onEdgeBack: () -> Void
        var onEdgeForward: () -> Void

        init(onEdgeBack: @escaping () -> Void, onEdgeForward: @escaping () -> Void) {
            self.onEdgeBack = onEdgeBack
            self.onEdgeForward = onEdgeForward
        }

        @objc func handleLeftEdge(_ gesture: UIScreenEdgePanGestureRecognizer) {
            if gesture.state == .recognized {
                HapticManager.shared.touchLight()
                onEdgeBack()
            }
        }

        @objc func handleRightEdge(_ gesture: UIScreenEdgePanGestureRecognizer) {
            if gesture.state == .recognized {
                HapticManager.shared.touchLight()
                onEdgeForward()
            }
        }
    }
}
