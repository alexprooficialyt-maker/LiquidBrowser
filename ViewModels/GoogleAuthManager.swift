import Foundation
import WebKit
import Observation

// MARK: - GoogleAuthManager

@Observable
public final class GoogleAuthManager: @unchecked Sendable {
    public static let shared = GoogleAuthManager()

    public var accountState: GoogleAccountState = GoogleAccountState()
    public var isCheckingSession: Bool = false

    private let storageKey = "google_account_state_v1"

    public init() {
        loadPersistedAccountState()
        checkSessionCookies()
    }

    private func loadPersistedAccountState() {
        if let stored: GoogleAccountState = StorageEngine.shared.loadJSON(from: storageKey + ".json") {
            self.accountState = stored
        }
    }

    public func saveAccountState() {
        StorageEngine.shared.saveJSON(accountState, to: storageKey + ".json")
    }

    // MARK: - Session Verification via WKWebsiteDataStore

    public func checkSessionCookies(completion: (@Sendable (Bool) -> Void)? = nil) {
        isCheckingSession = true
        let cookieStore = WKWebsiteDataStore.default().httpCookieStore

        cookieStore.getAllCookies { [weak self] cookies in
            guard let self = self else { return }

            let googleCookies = cookies.filter { $0.domain.contains("google.") }
            let hasSID = googleCookies.contains { $0.name == "SID" || $0.name == "SSID" }

            Task { @MainActor in
                self.isCheckingSession = false
                if hasSID {
                    self.accountState.isSignedIn = true
                    if self.accountState.displayName == nil {
                        self.accountState.displayName = "Cuenta de Google"
                    }
                } else if self.accountState.isSignedIn && !hasSID {
                    // Si ya no existen cookies pero estaba marcado, mantiene el perfil si no se deslogueó explícitamente
                }
                self.saveAccountState()
                completion?(self.accountState.isSignedIn)
            }
        }
    }

    // MARK: - Sign In & Sign Out

    public var googleSignInURL: URL {
        URL(string: "https://accounts.google.com/ServiceLogin?hl=es") ?? URL(fileURLWithPath: "/")
    }

    public func markSignedIn(email: String?, displayName: String?, avatarURL: URL? = nil) {
        accountState.isSignedIn = true
        accountState.userEmail = email
        accountState.displayName = displayName ?? email?.components(separatedBy: "@").first ?? "Google"
        accountState.avatarURL = avatarURL
        saveAccountState()
    }

    public func signOut(completion: (@Sendable () -> Void)? = nil) {
        accountState = GoogleAccountState(isSignedIn: false)
        saveAccountState()

        let cookieStore = WKWebsiteDataStore.default().httpCookieStore
        cookieStore.getAllCookies { cookies in
            let googleCookies = cookies.filter { $0.domain.contains("google.") || $0.domain.contains("youtube.") }
            let group = DispatchGroup()

            for cookie in googleCookies {
                group.enter()
                cookieStore.delete(cookie) {
                    group.leave()
                }
            }

            group.notify(queue: .main) {
                completion?()
            }
        }
    }
}

// MARK: - Compatibility Alias
public typealias GoogleAccountAuthManager = GoogleAuthManager
