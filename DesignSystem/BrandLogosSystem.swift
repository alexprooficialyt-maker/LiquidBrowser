import SwiftUI

// MARK: - SearchEngineType Enum (8 Official Engines)

public enum SearchEngineType: String, CaseIterable, Identifiable, Codable, Sendable {
    case google     = "google"
    case duckDuckGo = "duckduckgo"
    case brave      = "brave"
    case ecosia     = "ecosia"
    case bing       = "bing"
    case startpage  = "startpage"
    case qwant      = "qwant"
    case perplexity = "perplexity"

    public var id: String { rawValue }

    public var displayName: String {
        switch self {
        case .google:     return Loc.tr("onboarding_search_google")
        case .duckDuckGo: return Loc.tr("onboarding_search_duck")
        case .brave:      return Loc.tr("onboarding_search_brave")
        case .ecosia:     return Loc.tr("onboarding_search_ecosia")
        case .bing:       return Loc.tr("onboarding_search_bing")
        case .startpage:  return Loc.tr("onboarding_search_startpage")
        case .qwant:      return Loc.tr("onboarding_search_qwant")
        case .perplexity: return Loc.tr("onboarding_search_perplexity")
        }
    }

    public var searchDescription: String {
        switch self {
        case .google:     return Loc.tr("onboarding_search_google_desc")
        case .duckDuckGo: return Loc.tr("onboarding_search_duck_desc")
        case .brave:      return Loc.tr("onboarding_search_brave_desc")
        case .ecosia:     return Loc.tr("onboarding_search_ecosia_desc")
        case .bing:       return Loc.tr("onboarding_search_bing_desc")
        case .startpage:  return Loc.tr("onboarding_search_startpage_desc")
        case .qwant:      return Loc.tr("onboarding_search_qwant_desc")
        case .perplexity: return Loc.tr("onboarding_search_perplexity_desc")
        }
    }

    public var searchURLPrefix: String {
        switch self {
        case .google:     return "https://www.google.com/search?q="
        case .duckDuckGo: return "https://duckduckgo.com/?q="
        case .brave:      return "https://search.brave.com/search?q="
        case .ecosia:     return "https://www.ecosia.org/search?q="
        case .bing:       return "https://www.bing.com/search?q="
        case .startpage:  return "https://www.startpage.com/sp/search?query="
        case .qwant:      return "https://www.qwant.com/?q="
        case .perplexity: return "https://www.perplexity.ai/search?q="
        }
    }

    public func buildSearchURL(query: String) -> URL? {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.hasPrefix("http://") || trimmed.hasPrefix("https://") {
            return URL(string: trimmed)
        }
        if trimmed.contains(".") && !trimmed.contains(" ") {
            return URL(string: "https://\(trimmed)")
        }
        guard let encoded = trimmed.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            return nil
        }
        return URL(string: "\(searchURLPrefix)\(encoded)")
    }
}

// MARK: - BrandLogoStyle

public enum BrandLogoStyle {
    case fullColor
    case monochrome
}

// MARK: - 1. Official Google "G" Vector Component

public struct GoogleOfficialLogoView: View {
    public var style: BrandLogoStyle = .fullColor
    public var size: CGFloat = 24
    @Environment(\.colorScheme) private var colorScheme

    public init(style: BrandLogoStyle = .fullColor, size: CGFloat = 24) {
        self.style = style
        self.size = size
    }

    public var body: some View {
        Canvas { context, sz in
            let w = sz.width
            let h = sz.height
            let center = CGPoint(x: w / 2, y: h / 2)
            let radius = min(w, h) / 2
            let innerRadius = radius * 0.52

            if style == .monochrome {
                let monoColor = colorScheme == .dark ? Color.white : Color.black
                var path = Path()
                path.addArc(center: center, radius: radius, startAngle: .degrees(-45), endAngle: .degrees(225), clockwise: true)
                path.addLine(to: CGPoint(x: center.x + radius, y: center.y))
                path.addLine(to: CGPoint(x: center.x, y: center.y))
                context.stroke(path, with: .color(monoColor), style: StrokeStyle(lineWidth: radius - innerRadius, lineCap: .round))
                return
            }

            // Colores Oficiales de Google
            let redColor = Color(red: 0.917, green: 0.263, blue: 0.208)   // #EA4335
            let yellowColor = Color(red: 0.984, green: 0.737, blue: 0.020) // #FBBC05
            let greenColor = Color(red: 0.204, green: 0.659, blue: 0.325)  // #34A853
            let blueColor = Color(red: 0.259, green: 0.522, blue: 0.957)   // #4285F4

            let strokeW = (radius - innerRadius) * 0.92

            // 1. Arco Rojo Superior (205° a 315°)
            var redPath = Path()
            redPath.addArc(center: center, radius: (radius + innerRadius) / 2, startAngle: .degrees(205), endAngle: .degrees(315), clockwise: false)
            context.stroke(redPath, with: .color(redColor), style: StrokeStyle(lineWidth: strokeW, lineCap: .butt))

            // 2. Arco Amarillo Izquierdo (130° a 210°)
            var yellowPath = Path()
            yellowPath.addArc(center: center, radius: (radius + innerRadius) / 2, startAngle: .degrees(130), endAngle: .degrees(210), clockwise: false)
            context.stroke(yellowPath, with: .color(yellowColor), style: StrokeStyle(lineWidth: strokeW, lineCap: .butt))

            // 3. Arco Verde Inferior (35° a 135°)
            var greenPath = Path()
            greenPath.addArc(center: center, radius: (radius + innerRadius) / 2, startAngle: .degrees(35), endAngle: .degrees(135), clockwise: false)
            context.stroke(greenPath, with: .color(greenColor), style: StrokeStyle(lineWidth: strokeW, lineCap: .butt))

            // 4. Barra y Arco Azul Derecho
            var bluePath = Path()
            bluePath.addArc(center: center, radius: (radius + innerRadius) / 2, startAngle: .degrees(310), endAngle: .degrees(360), clockwise: false)
            context.stroke(bluePath, with: .color(blueColor), style: StrokeStyle(lineWidth: strokeW, lineCap: .butt))

            var barPath = Path()
            barPath.move(to: CGPoint(x: center.x - (radius * 0.05), y: center.y))
            barPath.addLine(to: CGPoint(x: center.x + radius, y: center.y))
            context.stroke(barPath, with: .color(blueColor), style: StrokeStyle(lineWidth: strokeW, lineCap: .butt))
        }
        .frame(width: size, height: size)
    }
}

// MARK: - 2. Official DuckDuckGo Vector Emblema

public struct DuckDuckGoOfficialLogoView: View {
    public var style: BrandLogoStyle = .fullColor
    public var size: CGFloat = 24
    @Environment(\.colorScheme) private var colorScheme

    public init(style: BrandLogoStyle = .fullColor, size: CGFloat = 24) {
        self.style = style
        self.size = size
    }

    public var body: some View {
        Canvas { context, sz in
            let w = sz.width
            let h = sz.height
            let bounds = CGRect(origin: .zero, size: sz)

            if style == .fullColor {
                let circleColor = Color(red: 0.871, green: 0.345, blue: 0.200) // #DE5833
                context.fill(Path(ellipseIn: bounds), with: .color(circleColor))
            }

            let strokeColor = style == .fullColor ? Color.white : (colorScheme == .dark ? Color.white : Color.black)

            // Pato Dax (Cabeza y Pico)
            var head = Path()
            head.addArc(center: CGPoint(x: w * 0.48, y: h * 0.42), radius: w * 0.24, startAngle: .degrees(0), endAngle: .degrees(360), clockwise: false)
            context.fill(head, with: .color(strokeColor))

            // Pico anaranjado/amarillo
            var beak = Path()
            beak.move(to: CGPoint(x: w * 0.60, y: h * 0.38))
            beak.addLine(to: CGPoint(x: w * 0.88, y: h * 0.48))
            beak.addLine(to: CGPoint(x: w * 0.60, y: h * 0.54))
            beak.closeSubpath()
            let beakColor = style == .fullColor ? Color(red: 0.988, green: 0.722, blue: 0.165) : strokeColor
            context.fill(beak, with: .color(beakColor))

            // Pajarita verde
            var bowtie = Path()
            bowtie.move(to: CGPoint(x: w * 0.36, y: h * 0.72))
            bowtie.addLine(to: CGPoint(x: w * 0.60, y: h * 0.80))
            bowtie.addLine(to: CGPoint(x: w * 0.36, y: h * 0.88))
            bowtie.closeSubpath()
            let bowtieColor = style == .fullColor ? Color(red: 0.353, green: 0.686, blue: 0.243) : strokeColor
            context.fill(bowtie, with: .color(bowtieColor))
        }
        .frame(width: size, height: size)
    }
}

// MARK: - 3. Official Brave Search Faceted Lion Emblem

public struct BraveOfficialLogoView: View {
    public var style: BrandLogoStyle = .fullColor
    public var size: CGFloat = 24
    @Environment(\.colorScheme) private var colorScheme

    public init(style: BrandLogoStyle = .fullColor, size: CGFloat = 24) {
        self.style = style
        self.size = size
    }

    public var body: some View {
        Canvas { context, sz in
            let w = sz.width
            let h = sz.height

            let primaryOrange = Color(red: 0.984, green: 0.243, blue: 0.078) // #FB3E14
            let darkOrange = Color(red: 0.860, green: 0.180, blue: 0.040)
            let lightOrange = Color(red: 1.000, green: 0.420, blue: 0.180)

            let fillColor = style == .fullColor ? primaryOrange : (colorScheme == .dark ? Color.white : Color.black)

            var shield = Path()
            shield.move(to: CGPoint(x: w * 0.5, y: h * 0.06))
            shield.addLine(to: CGPoint(x: w * 0.86, y: h * 0.22))
            shield.addLine(to: CGPoint(x: w * 0.78, y: h * 0.62))
            shield.addLine(to: CGPoint(x: w * 0.5, y: h * 0.94))
            shield.addLine(to: CGPoint(x: w * 0.22, y: h * 0.62))
            shield.addLine(to: CGPoint(x: w * 0.14, y: h * 0.22))
            shield.closeSubpath()

            context.fill(shield, with: .color(fillColor))

            if style == .fullColor {
                var crown = Path()
                crown.move(to: CGPoint(x: w * 0.5, y: h * 0.15))
                crown.addLine(to: CGPoint(x: w * 0.72, y: h * 0.28))
                crown.addLine(to: CGPoint(x: w * 0.5, y: h * 0.38))
                crown.addLine(to: CGPoint(x: w * 0.28, y: h * 0.28))
                crown.closeSubpath()
                context.fill(crown, with: .color(lightOrange))

                var snout = Path()
                snout.move(to: CGPoint(x: w * 0.5, y: h * 0.44))
                snout.addLine(to: CGPoint(x: w * 0.65, y: h * 0.62))
                snout.addLine(to: CGPoint(x: w * 0.5, y: h * 0.78))
                snout.addLine(to: CGPoint(x: w * 0.35, y: h * 0.62))
                snout.closeSubpath()
                context.fill(snout, with: .color(darkOrange))
            } else {
                var line1 = Path()
                line1.move(to: CGPoint(x: w * 0.5, y: h * 0.06))
                line1.addLine(to: CGPoint(x: w * 0.5, y: h * 0.94))
                let lineColor = colorScheme == .dark ? Color.black : Color.white
                context.stroke(line1, with: .color(lineColor), lineWidth: 1.0)
            }
        }
        .frame(width: size, height: size)
    }
}

// MARK: - 4. Official Ecosia Vector Tree Emblem

public struct EcosiaOfficialLogoView: View {
    public var style: BrandLogoStyle = .fullColor
    public var size: CGFloat = 24
    @Environment(\.colorScheme) private var colorScheme

    public init(style: BrandLogoStyle = .fullColor, size: CGFloat = 24) {
        self.style = style
        self.size = size
    }

    public var body: some View {
        Canvas { context, sz in
            let w = sz.width
            let h = sz.height
            let bounds = CGRect(origin: .zero, size: sz)

            let ecosiaTeal = Color(red: 0.000, green: 0.588, blue: 0.533) // #009688
            let trunkBrown = Color(red: 0.400, green: 0.250, blue: 0.150)
            let leafGreen = Color(red: 0.298, green: 0.686, blue: 0.314)  // #4CAF50

            if style == .fullColor {
                context.fill(Path(ellipseIn: bounds), with: .color(ecosiaTeal))
            }

            let mainColor = style == .fullColor ? leafGreen : (colorScheme == .dark ? Color.white : Color.black)

            var foliage = Path()
            foliage.addArc(center: CGPoint(x: w * 0.5, y: h * 0.40), radius: w * 0.26, startAngle: .degrees(0), endAngle: .degrees(360), clockwise: false)
            context.fill(foliage, with: .color(mainColor))

            var trunk = Path()
            trunk.move(to: CGPoint(x: w * 0.46, y: h * 0.52))
            trunk.addLine(to: CGPoint(x: w * 0.54, y: h * 0.52))
            trunk.addLine(to: CGPoint(x: w * 0.58, y: h * 0.82))
            trunk.addLine(to: CGPoint(x: w * 0.42, y: h * 0.82))
            trunk.closeSubpath()
            let resolvedTrunkColor = style == .fullColor ? trunkBrown : mainColor
            context.fill(trunk, with: .color(resolvedTrunkColor))
        }
        .frame(width: size, height: size)
    }
}

// MARK: - Unified Brand Logo View Selector (Backward-Compatible Forwarder)

public struct BrandLogoView: View {
    public let engine: SearchEngineType
    public var style: BrandLogoStyle = .fullColor
    public var size: CGFloat = 24

    public init(engine: SearchEngineType, style: BrandLogoStyle = .fullColor, size: CGFloat = 24) {
        self.engine = engine
        self.style = style
        self.size = size
    }

    public var body: some View {
        SearchEngineLogoView(engine: engine, size: size, style: style)
    }
}
