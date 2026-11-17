import SwiftUI

@Observable
final class AppState {
    @ObservationIgnored
    @AppStorage("userName") var userName: String = ""

    @ObservationIgnored
    @AppStorage("userAge") var userAge: Int = 0

    @ObservationIgnored
    @AppStorage("accentColorHex") var accentColorHex: String = "#4A90E2"

    @ObservationIgnored
    @AppStorage("searchEngine") var searchEngine: SearchEngine = .google

    @ObservationIgnored
    @AppStorage("autoCloseTabsDays") var autoCloseTabsDays: Int = 0

    @ObservationIgnored
    @AppStorage("barPosition") var barPosition: BarPosition = .bottom

    // Estado UI
    var isShowingTabs  = false
    var isShowingTools = false
    var isPrivateMode  = false

    enum SearchEngine: String, CaseIterable, Codable {
        case google     = "Google"
        case duckduckgo = "DuckDuckGo"
        case brave      = "Brave"
        case ecosia     = "Ecosia"

        var searchURL: String {
            switch self {
            case .google:     return "https://www.google.com/search?q="
            case .duckduckgo: return "https://duckduckgo.com/?q="
            case .brave:      return "https://search.brave.com/search?q="
            case .ecosia:     return "https://www.ecosia.org/search?q="
            }
        }
    }

    enum BarPosition: String, CaseIterable, Codable {
        case bottom = "Abajo"
        case top    = "Arriba"
    }
}
