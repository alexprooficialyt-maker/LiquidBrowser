import Foundation
import WebKit

public struct DarkModeCSSInjector {
    public static let scriptIdentifier = "LiquidBrowserForcedDarkModeScript"

    public static let cssContent = """
    @media (prefers-color-scheme: dark) {
        /* Already respects dark mode */
    }
    html {
        background-color: #121214 !important;
        filter: invert(0.92) hue-rotate(180deg) !important;
    }
    img, video, canvas, svg, picture, [style*='background-image'] {
        filter: invert(1.08) hue-rotate(180deg) !important;
    }
    iframe {
        background: #121214 !important;
    }
    """

    public static func makeUserScript() -> WKUserScript {
        let jsSource = """
        (function() {
            if (document.getElementById('__liquid_dark_mode_style__')) return;
            var style = document.createElement('style');
            style.id = '__liquid_dark_mode_style__';
            style.type = 'text/css';
            style.innerHTML = `\(cssContent)`;
            document.head.appendChild(style);
        })();
        """
        return WKUserScript(source: jsSource, injectionTime: .atDocumentEnd, forMainFrameOnly: true)
    }

    public static func toggleDarkMode(on webView: WKWebView, enabled: Bool) {
        if enabled {
            let injectJS = """
            (function() {
                var existing = document.getElementById('__liquid_dark_mode_style__');
                if (!existing) {
                    var style = document.createElement('style');
                    style.id = '__liquid_dark_mode_style__';
                    style.type = 'text/css';
                    style.innerHTML = `\(cssContent)`;
                    document.head.appendChild(style);
                }
            })();
            """
            webView.evaluateJavaScript(injectJS)
        } else {
            let removeJS = """
            (function() {
                var existing = document.getElementById('__liquid_dark_mode_style__');
                if (existing) {
                    existing.remove();
                }
            })();
            """
            webView.evaluateJavaScript(removeJS)
        }
    }
}
