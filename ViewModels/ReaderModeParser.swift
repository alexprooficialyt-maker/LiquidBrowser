import Foundation
import WebKit

// MARK: - ReaderModeParser

public struct ReaderModeParser {
    public static let extractionScript = """
    (function() {
        var article = document.querySelector('article') ||
                      document.querySelector('main') ||
                      document.querySelector('[role=\"main\"]') ||
                      document.querySelector('.post-content') ||
                      document.querySelector('.article-content') ||
                      document.body;

        var title = document.title || '';
        var h1 = document.querySelector('h1');
        if (h1 && h1.innerText.trim().length > 0) {
            title = h1.innerText.trim();
        }

        var byline = '';
        var authorNode = document.querySelector('[rel=\"author\"], .author, .byline, [itemprop=\"author\"]');
        if (authorNode) {
            byline = authorNode.innerText.trim();
        }

        var clone = article.cloneNode(true);

        var removeSelectors = [
            'script', 'style', 'nav', 'header', 'footer', 'aside',
            '.ad', '.ads', '.advertisement', '.social-share',
            '.comments', '#comments', '.newsletter', '.popup',
            'form', 'button', 'iframe'
        ];

        removeSelectors.forEach(function(sel) {
            var elements = clone.querySelectorAll(sel);
            elements.forEach(function(el) { el.remove(); });
        });

        var text = clone.innerText || '';
        var html = clone.innerHTML || '';
        var excerpt = text.substring(0, 160).replace(/\\s+/g, ' ').trim();

        return {
            title: title,
            byline: byline,
            siteName: window.location.hostname.replace('www.', ''),
            contentHTML: html,
            textContent: text,
            excerpt: excerpt
        };
    })();
    """

    public static func parse(webView: WKWebView, completion: @escaping @Sendable (ReaderArticle?) -> Void) {
        guard let url = webView.url else {
            completion(nil)
            return
        }

        webView.evaluateJavaScript(extractionScript) { result, _ in
            guard let dict = result as? [String: Any],
                  let title = dict["title"] as? String,
                  let contentHTML = dict["contentHTML"] as? String,
                  let textContent = dict["textContent"] as? String,
                  let excerpt = dict["excerpt"] as? String else {
                completion(nil)
                return
            }

            let byline = dict["byline"] as? String
            let siteName = dict["siteName"] as? String
            let readMinutes = ReaderArticle.estimateReadingMinutes(from: textContent)

            let article = ReaderArticle(
                url: url,
                title: title.isEmpty ? "Artículo" : title,
                byline: byline?.isEmpty == true ? nil : byline,
                siteName: siteName,
                contentHTML: contentHTML,
                textContent: textContent,
                excerpt: excerpt,
                savedAt: Date(),
                readingTimeMinutes: readMinutes
            )

            completion(article)
        }
    }
}
