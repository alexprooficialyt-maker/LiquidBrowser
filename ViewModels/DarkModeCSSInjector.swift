import Foundation
import WebKit

// MARK: - DarkModeCSSInjector

public struct DarkModeCSSInjector {
    public static let darkModeCSS = """
    html {
        filter: invert(90%) hue-rotate(180deg) !important;
        background-color: #121212 !important;
    }
    img, video, iframe, canvas, svg, picture, [style*='background-image'] {
        filter: invert(100%) hue-rotate(180deg) !important;
    }
    """

    public static let injectionScript = """
    (function() {
        var styleId = 'liquid-browser-forced-dark-mode';
        var existing = document.getElementById(styleId);
        if (existing) {
            existing.remove();
        } else {
            var style = document.createElement('style');
            style.id = styleId;
            style.type = 'text/css';
            style.appendChild(document.createTextNode(`\(darkModeCSS)`));
            (document.head || document.documentElement).appendChild(style);
        }
    })();
    """

    public static func toggleDarkMode(on webView: WKWebView, enabled: Bool) {
        if enabled {
            webView.evaluateJavaScript(injectionScript, completionHandler: nil)
        } else {
            let removeScript = "var el = document.getElementById('liquid-browser-forced-dark-mode'); if (el) { el.remove(); }"
            webView.evaluateJavaScript(removeScript, completionHandler: nil)
        }
    }
}
