import SwiftUI

// MARK: - SearchEngineLogoView (Universal Vector Logo Dispatcher)

public struct SearchEngineLogoView: View {
    public let engine: SearchEngineType
    public var size: CGFloat = 28
    public var style: BrandLogoStyle = .fullColor

    public init(engine: SearchEngineType, size: CGFloat = 28, style: BrandLogoStyle = .fullColor) {
        self.engine = engine
        self.size = size
        self.style = style
    }

    public var body: some View {
        Group {
            switch engine {
            case .google:
                GoogleOfficialLogoView(style: style, size: size)
            case .duckDuckGo:
                DuckDuckGoOfficialLogoView(style: style, size: size)
            case .brave:
                BraveOfficialLogoView(style: style, size: size)
            case .ecosia:
                EcosiaOfficialLogoView(style: style, size: size)
            case .bing:
                BingOfficialLogoView(style: style, size: size)
            case .startpage:
                StartpageOfficialLogoView(style: style, size: size)
            case .qwant:
                QwantOfficialLogoView(style: style, size: size)
            case .perplexity:
                PerplexityOfficialLogoView(style: style, size: size)
            }
        }
        .frame(width: size, height: size)
    }
}

// MARK: - 5. Official Microsoft Bing Vector Component

public struct BingOfficialLogoView: View {
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

            if style == .monochrome {
                let color = colorScheme == .dark ? Color.white : Color.black
                var path = Path()
                path.move(to: CGPoint(x: w * 0.25, y: h * 0.10))
                path.addLine(to: CGPoint(x: w * 0.25, y: h * 0.90))
                path.addCurve(
                    to: CGPoint(x: w * 0.80, y: h * 0.65),
                    control1: CGPoint(x: w * 0.50, y: h * 0.95),
                    control2: CGPoint(x: w * 0.80, y: h * 0.85)
                )
                path.addCurve(
                    to: CGPoint(x: w * 0.25, y: h * 0.40),
                    control1: CGPoint(x: w * 0.80, y: h * 0.45),
                    control2: CGPoint(x: w * 0.50, y: h * 0.40)
                )
                context.stroke(path, with: .color(color), lineWidth: w * 0.12)
                return
            }

            // Bing Gradient Colors (Teal to Blue)
            let teal = Color(red: 0.00, green: 0.53, blue: 0.80)
            let cyan = Color(red: 0.12, green: 0.73, blue: 0.88)
            let blue = Color(red: 0.08, green: 0.35, blue: 0.72)

            var path1 = Path()
            path1.move(to: CGPoint(x: w * 0.22, y: h * 0.10))
            path1.addLine(to: CGPoint(x: w * 0.46, y: h * 0.22))
            path1.addLine(to: CGPoint(x: w * 0.46, y: h * 0.68))
            path1.addLine(to: CGPoint(x: w * 0.22, y: h * 0.56))
            path1.closeSubpath()
            context.fill(path1, with: .color(blue))

            var path2 = Path()
            path2.move(to: CGPoint(x: w * 0.46, y: h * 0.22))
            path2.addLine(to: CGPoint(x: w * 0.78, y: h * 0.42))
            path2.addLine(to: CGPoint(x: w * 0.60, y: h * 0.88))
            path2.addLine(to: CGPoint(x: w * 0.46, y: h * 0.68))
            path2.closeSubpath()
            context.fill(path2, with: .color(cyan))

            var path3 = Path()
            path3.move(to: CGPoint(x: w * 0.22, y: h * 0.56))
            path3.addLine(to: CGPoint(x: w * 0.46, y: h * 0.68))
            path3.addLine(to: CGPoint(x: w * 0.60, y: h * 0.88))
            path3.addLine(to: CGPoint(x: w * 0.30, y: h * 0.90))
            path3.closeSubpath()
            context.fill(path3, with: .color(teal))
        }
        .frame(width: size, height: size)
    }
}

// MARK: - 6. Official Startpage Vector Component

public struct StartpageOfficialLogoView: View {
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

            if style == .monochrome {
                let color = colorScheme == .dark ? Color.white : Color.black
                let rect = CGRect(x: w * 0.12, y: h * 0.12, width: w * 0.76, height: h * 0.76)
                context.stroke(Path(roundedRect: rect, cornerRadius: 6), with: .color(color), lineWidth: 1.5)
                return
            }

            // Startpage Official Deep Royal Blue
            let spBlue = Color(red: 0.05, green: 0.22, blue: 0.62)
            let spCyan = Color(red: 0.16, green: 0.65, blue: 0.96)

            let bgRect = CGRect(x: 0, y: 0, width: w, height: h)
            context.fill(Path(roundedRect: bgRect, cornerRadius: w * 0.24), with: .color(spBlue))

            // Two overlapping curved privacy waves
            var wave1 = Path()
            wave1.move(to: CGPoint(x: w * 0.25, y: h * 0.60))
            wave1.addQuadCurve(
                to: CGPoint(x: w * 0.75, y: h * 0.40),
                control: CGPoint(x: w * 0.50, y: h * 0.20)
            )
            context.stroke(wave1, with: .color(Color.white), style: StrokeStyle(lineWidth: w * 0.12, lineCap: .round))

            var wave2 = Path()
            wave2.move(to: CGPoint(x: w * 0.35, y: h * 0.75))
            wave2.addQuadCurve(
                to: CGPoint(x: w * 0.75, y: h * 0.60),
                control: CGPoint(x: w * 0.55, y: h * 0.45)
            )
            context.stroke(wave2, with: .color(spCyan), style: StrokeStyle(lineWidth: w * 0.10, lineCap: .round))
        }
        .frame(width: size, height: size)
    }
}

// MARK: - 7. Official Qwant Vector Component

public struct QwantOfficialLogoView: View {
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

            if style == .monochrome {
                let color = colorScheme == .dark ? Color.white : Color.black
                var path = Path()
                path.addEllipse(in: CGRect(x: w * 0.15, y: h * 0.15, width: w * 0.70, height: h * 0.70))
                path.move(to: CGPoint(x: w * 0.55, y: h * 0.55))
                path.addLine(to: CGPoint(x: w * 0.85, y: h * 0.85))
                context.stroke(path, with: .color(color), lineWidth: w * 0.10)
                return
            }

            // Qwant Red/Violet/Cyan Colors
            let qRed = Color(red: 0.98, green: 0.22, blue: 0.35)
            let qViolet = Color(red: 0.45, green: 0.20, blue: 0.85)
            let qCyan = Color(red: 0.05, green: 0.75, blue: 0.90)

            let center = CGPoint(x: w * 0.46, y: h * 0.46)
            let r = w * 0.34

            var ring = Path()
            ring.addArc(center: center, radius: r, startAngle: .degrees(-60), endAngle: .degrees(220), clockwise: false)
            context.stroke(
                ring,
                with: .linearGradient(
                    Gradient(colors: [qRed, qViolet, qCyan]),
                    startPoint: CGPoint(x: 0, y: 0),
                    endPoint: CGPoint(x: w, y: h)
                ),
                style: StrokeStyle(lineWidth: w * 0.15, lineCap: .round)
            )

            // Tail of Q
            var tail = Path()
            tail.move(to: CGPoint(x: w * 0.52, y: h * 0.56))
            tail.addLine(to: CGPoint(x: w * 0.85, y: h * 0.88))
            context.stroke(tail, with: .color(qCyan), style: StrokeStyle(lineWidth: w * 0.15, lineCap: .round))
        }
        .frame(width: size, height: size)
    }
}

// MARK: - 8. Official Perplexity Vector Component

public struct PerplexityOfficialLogoView: View {
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

            let color = (style == .monochrome)
                ? (colorScheme == .dark ? Color.white : Color.black)
                : Color(red: 0.13, green: 0.65, blue: 0.68) // Official Perplexity Teal (#21A5AD)

            let strokeW = max(1.8, w * 0.09)

            // Woven Asterisk Crossbars
            var vert = Path()
            vert.move(to: CGPoint(x: w * 0.50, y: h * 0.12))
            vert.addLine(to: CGPoint(x: w * 0.50, y: h * 0.88))
            context.stroke(vert, with: .color(color), style: StrokeStyle(lineWidth: strokeW, lineCap: .round))

            var diag1 = Path()
            diag1.move(to: CGPoint(x: w * 0.18, y: h * 0.28))
            diag1.addLine(to: CGPoint(x: w * 0.82, y: h * 0.72))
            context.stroke(diag1, with: .color(color), style: StrokeStyle(lineWidth: strokeW, lineCap: .round))

            var diag2 = Path()
            diag2.move(to: CGPoint(x: w * 0.18, y: h * 0.72))
            diag2.addLine(to: CGPoint(x: w * 0.82, y: h * 0.28))
            context.stroke(diag2, with: .color(color), style: StrokeStyle(lineWidth: strokeW, lineCap: .round))

            // Central connecting loop
            let centerRect = CGRect(x: w * 0.38, y: h * 0.38, width: w * 0.24, height: h * 0.24)
            context.stroke(Path(ellipseIn: centerRect), with: .color(color), style: StrokeStyle(lineWidth: strokeW * 0.9))
        }
        .frame(width: size, height: size)
    }
}
