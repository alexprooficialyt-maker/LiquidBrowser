import SwiftUI
import WebKit

// MARK: - WebContainerView
// Envuelve WKWebView con soporte para gestos de borde, pull-to-refresh y scroll hide/show

struct WebContainerView: UIViewRepresentable {
    @Binding var tabID: UUID
    var viewModel: BrowserViewModel
    var onScrollDown: () -> Void
    var onScrollUp:   () -> Void

    func makeUIView(context: Context) -> WKWebView {
        let tab = viewModel.tabManager.tabs.first { $0.id == tabID }
        let wv  = viewModel.webView(for: tabID, isPrivate: tab?.isPrivate ?? false)
        wv.scrollView.delegate = context.coordinator
        wv.addObserver(context.coordinator, forKeyPath: #keyPath(WKWebView.estimatedProgress), options: .new, context: nil)

        // Pull-to-refresh
        let refresh = UIRefreshControl()
        refresh.addTarget(context.coordinator, action: #selector(Coordinator.handleRefresh(_:)), for: .valueChanged)
        wv.scrollView.refreshControl = refresh

        // Gesto deslizar desde borde izquierdo (atrás)
        let swipeLeft = UIScreenEdgePanGestureRecognizer(
            target: context.coordinator, action: #selector(Coordinator.handleEdgeSwipe(_:)))
        swipeLeft.edges = .left
        wv.addGestureRecognizer(swipeLeft)

        // Gesto deslizar desde borde derecho (adelante)
        let swipeRight = UIScreenEdgePanGestureRecognizer(
            target: context.coordinator, action: #selector(Coordinator.handleEdgeSwipeRight(_:)))
        swipeRight.edges = .right
        wv.addGestureRecognizer(swipeRight)

        // Cargar URL si hay
        if let url = tab?.url, wv.url == nil {
            wv.load(URLRequest(url: url))
        }
        return wv
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(viewModel: viewModel, tabID: tabID,
                    onScrollDown: onScrollDown, onScrollUp: onScrollUp)
    }

    // MARK: - Coordinator

    final class Coordinator: NSObject, UIScrollViewDelegate {
        let viewModel: BrowserViewModel
        let tabID: UUID
        let onScrollDown: () -> Void
        let onScrollUp:   () -> Void
        private var lastOffset: CGFloat = 0

        init(viewModel: BrowserViewModel, tabID: UUID,
             onScrollDown: @escaping () -> Void, onScrollUp: @escaping () -> Void) {
            self.viewModel    = viewModel
            self.tabID        = tabID
            self.onScrollDown = onScrollDown
            self.onScrollUp   = onScrollUp
        }

        // Pull-to-refresh
        @objc func handleRefresh(_ sender: UIRefreshControl) {
            viewModel.reload()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) { sender.endRefreshing() }
        }

        // Gesto de borde izquierdo → Atrás
        @objc func handleEdgeSwipe(_ recognizer: UIScreenEdgePanGestureRecognizer) {
            if recognizer.state == .recognized { viewModel.goBack() }
        }

        // Gesto de borde derecho → Adelante
        @objc func handleEdgeSwipeRight(_ recognizer: UIScreenEdgePanGestureRecognizer) {
            if recognizer.state == .recognized { viewModel.goForward() }
        }

        // Ocultar/mostrar barra al hacer scroll
        func scrollViewDidScroll(_ scrollView: UIScrollView) {
            let offset = scrollView.contentOffset.y
            let delta  = offset - lastOffset
            if delta > 10  { onScrollDown() }
            if delta < -10 { onScrollUp() }
            lastOffset = offset
        }

        // KVO: progreso de carga
        override func observeValue(forKeyPath keyPath: String?, of object: Any?,
                                   change: [NSKeyValueChangeKey: Any]?, context: UnsafeMutableRawPointer?) {
            guard keyPath == #keyPath(WKWebView.estimatedProgress),
                  let wv = object as? WKWebView else { return }
            DispatchQueue.main.async {
                self.viewModel.tabManager.update(tabID: self.tabID, progress: wv.estimatedProgress)
            }
        }

        deinit {
            // El KVO se elimina automáticamente al liberar el coordinator
        }
    }
}
