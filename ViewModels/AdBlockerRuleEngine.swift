import Foundation
import WebKit

public final class AdBlockerRuleEngine: @unchecked Sendable {
    public static let shared = AdBlockerRuleEngine()

    private let ruleListIdentifier = "LiquidBrowserAdBlockerRules"
    private var compiledRuleList: WKContentRuleList?
    private let lock = NSLock()

    private init() {
        compileRules()
    }

    public var ruleList: WKContentRuleList? {
        lock.lock()
        defer { lock.unlock() }
        return compiledRuleList
    }

    public func compileRules(completion: (@Sendable (Bool) -> Void)? = nil) {
        let rulesJSON = """
        [
            {
                "trigger": {
                    "url-filter": ".*(doubleclick\\\\.net|googlesyndication\\\\.com|googleadservices\\\\.com|moatads\\\\.com|adnxs\\\\.com|adroll\\\\.com|outbrain\\\\.com|taboola\\\\.com|criteo\\\\.com|scorecardresearch\\\\.com|quantserve\\\\.com).*"
                },
                "action": {
                    "type": "block"
                }
            },
            {
                "trigger": {
                    "url-filter": ".*(facebook\\\\.com/tr|analytics\\\\.twitter\\\\.com|ads\\\\.linkedin\\\\.com|pixel\\\\.wp\\\\.com|hotjar\\\\.com|clarity\\\\.ms).*"
                },
                "action": {
                    "type": "block"
                }
            },
            {
                "trigger": {
                    "url-filter": ".*",
                    "resource-type": ["popup"]
                },
                "action": {
                    "type": "block"
                }
            },
            {
                "trigger": {
                    "url-filter": ".*"
                },
                "action": {
                    "type": "css-display-none",
                    "selector": ".ad, .ads, .ad-banner, .advertisement, [id^='ad_'], [class*='ad-container'], .sponsor-post, .cookie-banner, #cookie-consent"
                }
            }
        ]
        """

        WKContentRuleListStore.default().compileContentRuleList(
            forIdentifier: ruleListIdentifier,
            encodedContentRuleList: rulesJSON
        ) { [weak self] list, error in
            guard let self = self else { return }
            self.lock.lock()
            self.compiledRuleList = list
            self.lock.unlock()

            if let error = error {
                NSLog("AdBlockerRuleEngine compilation error: \(error.localizedDescription)")
                completion?(false)
            } else {
                completion?(true)
            }
        }
    }
}
