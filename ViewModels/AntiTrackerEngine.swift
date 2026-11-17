import WebKit
import SwiftUI

// MARK: - AntiTrackerEngine (@Observable Anti-Spy & Tracker Shield Engine)

@Observable
public final class AntiTrackerEngine: @unchecked Sendable {
    public static let shared = AntiTrackerEngine()

    public var isShieldEnabledGlobally: Bool = true {
        didSet {
            UserDefaults.standard.set(isShieldEnabledGlobally, forKey: "smartbot_anti_tracker_enabled_globally")
        }
    }

    public var ruleList: WKContentRuleList?
    public var sessionTrackersBlocked: Int = 0
    public var domainBlockedCount: [String: Int] = [:]
    public var disabledDomains: Set<String> = []

    private let ruleListIdentifier = "com.smartbot.browser.antitracker.rules"

    // MARK: - Reglas de Bloqueo Estricto de Rastreadores, Huellas y Anuncios
    private let rulesJSON = """
    [
        {
            "trigger": {
                "url-filter": ".*(google-analytics|googletagmanager|doubleclick|criteo|hotjar|segment|mixpanel|amplitude|outbrain|taboola|scorecardresearch|chartbeat|quantserve|facebook\\.net|connect\\.facebook).*$",
                "load-type": ["third-party"]
            },
            "action": {
                "type": "block"
            }
        },
        {
            "trigger": {
                "url-filter": ".*",
                "load-type": ["third-party"]
            },
            "action": {
                "type": "block-cookies"
            }
        },
        {
            "trigger": {
                "url-filter": ".*(adserver|adservices|adsystem|adnxs|advertising|popads|propellerads|zergnet).*$"
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
                "selector": ".ad, .ads, .advertisement, .ad-banner, .google-ad, .ad-container, [id^='google_ads'], [class*='adsbygoogle'], .sponsored-post"
            }
        }
    ]
    """

    private init() {
        self.isShieldEnabledGlobally = UserDefaults.standard.object(forKey: "smartbot_anti_tracker_enabled_globally") as? Bool ?? true
        compileRules()
    }

    public func compileRules() {
        guard let store = WKContentRuleListStore.default() else { return }

        store.compileContentRuleList(
            forIdentifier: ruleListIdentifier,
            encodedContentRuleList: rulesJSON
        ) { [weak self] list, error in
            if let error = error {
                NSLog("AntiTracker compile error: \(error.localizedDescription)")
            } else if let list = list {
                DispatchQueue.main.async {
                    self?.ruleList = list
                }
            }
        }
    }

    public func recordBlockedTracker(for domain: String) {
        let cleanDomain = domain.replacingOccurrences(of: "www.", with: "").lowercased()
        DispatchQueue.main.async {
            self.sessionTrackersBlocked += 1
            self.domainBlockedCount[cleanDomain, default: 0] += 1
        }
    }

    public func blockedCount(for domain: String) -> Int {
        let cleanDomain = domain.replacingOccurrences(of: "www.", with: "").lowercased()
        return domainBlockedCount[cleanDomain] ?? 0
    }

    public func isShieldActive(for domain: String) -> Bool {
        guard isShieldEnabledGlobally else { return false }
        let cleanDomain = domain.replacingOccurrences(of: "www.", with: "").lowercased()
        return !disabledDomains.contains(cleanDomain)
    }

    public func toggleShield(for domain: String) {
        let cleanDomain = domain.replacingOccurrences(of: "www.", with: "").lowercased()
        if disabledDomains.contains(cleanDomain) {
            disabledDomains.remove(cleanDomain)
        } else {
            disabledDomains.insert(cleanDomain)
        }
    }
}

// MARK: - Compatibility Alias
public typealias AdBlockerRuleEngine = AntiTrackerEngine
