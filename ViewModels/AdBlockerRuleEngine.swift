import Foundation
import WebKit

// MARK: - AdBlockerRuleEngine

public final class AdBlockerRuleEngine: @unchecked Sendable {
    public static let shared = AdBlockerRuleEngine()

    public private(set) var ruleList: WKContentRuleList?
    private let ruleListIdentifier = "LiquidBrowserAdBlockerRules_v1"

    private let rulesJSON = """
    [
        {
            "trigger": {
                "url-filter": ".*",
                "load-type": ["third-party"],
                "if-domain": [
                    "*doubleclick.net",
                    "*google-analytics.com",
                    "*googletagservices.com",
                    "*adnxs.com",
                    "*facebook.com/tr",
                    "*scorecardresearch.com",
                    "*taboola.com",
                    "*outbrain.com",
                    "*criteo.com",
                    "*hotjar.com",
                    "*analytics.twitter.com"
                ]
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
                "selector": ".ad, .ads, .advertisement, .ad-banner, .google-ad, .ad-container, [id^='google_ads'], [class*='adsbygoogle']"
            }
        }
    ]
    """

    private init() {
        compileRules()
    }

    public func compileRules() {
        let store = WKContentRuleListStore.default()

        store.compileContentRuleList(
            forIdentifier: ruleListIdentifier,
            encodedContentRuleList: rulesJSON
        ) { [weak self] list, error in
            if let error = error {
                NSLog("AdBlocker compile error: \(error.localizedDescription)")
            } else if let list = list {
                self?.ruleList = list
            }
        }
    }
}
