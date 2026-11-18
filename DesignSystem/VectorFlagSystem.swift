import SwiftUI

// MARK: - VectorFlagSystem.swift
// Hand-drawn vector flags for all 15 AppLanguage cases.
// No emoji. Each flag drawn with Path / Canvas inside a clipped RoundedRectangle.

// MARK: - Public Entry Point

public struct VectorFlagView: View {
    public let language: AppLanguage
    public let size: CGFloat

    public init(language: AppLanguage, size: CGFloat = 28) {
        self.language = language
        self.size = size
    }

    private var width: CGFloat { size * 1.5 }
    private var height: CGFloat { size }

    public var body: some View {
        ZStack {
            flagCanvas
        }
        .frame(width: width, height: height)
        .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 6, style: .continuous)
                .strokeBorder(
                    LinearGradient(
                        colors: [Color.white.opacity(0.45), Color.black.opacity(0.18)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 0.5
                )
        )
    }

    @ViewBuilder
    private var flagCanvas: some View {
        switch language {
        case .spanish:    SpainFlag(width: width, height: height)
        case .english:    USAFlag(width: width, height: height)
        case .french:     FranceFlag(width: width, height: height)
        case .german:     GermanyFlag(width: width, height: height)
        case .italian:    ItalyFlag(width: width, height: height)
        case .portuguese: PortugalFlag(width: width, height: height)
        case .catalan:    CataloniaFlag(width: width, height: height)
        case .japanese:   JapanFlag(width: width, height: height)
        case .korean:     SouthKoreaFlag(width: width, height: height)
        case .chinese:    ChinaFlag(width: width, height: height)
        case .dutch:      NetherlandsFlag(width: width, height: height)
        case .polish:     PolandFlag(width: width, height: height)
        case .turkish:    TurkeyFlag(width: width, height: height)
        case .arabic:     SaudiArabiaFlag(width: width, height: height)
        case .russian:    RussiaFlag(width: width, height: height)
        }
    }
}

// MARK: - Backward Compat
public typealias LanguageFlagView = VectorFlagView

// MARK: - Color helpers (hex)

private extension Color {
    init(hex: UInt32) {
        let r = Double((hex >> 16) & 0xFF) / 255
        let g = Double((hex >> 8)  & 0xFF) / 255
        let b = Double( hex        & 0xFF) / 255
        self.init(red: r, green: g, blue: b)
    }
}

// MARK: - España 🇪🇸

private struct SpainFlag: View {
    let width: CGFloat
    let height: CGFloat

    // 3 horizontal stripes: red 1/4 | yellow 1/2 | red 1/4
    var body: some View {
        Canvas { ctx, size in
            let red    = Color(hex: 0xC60B1E)
            let yellow = Color(hex: 0xFFC400)
            let h = size.height
            let w = size.width
            // Top red stripe (h/4)
            ctx.fill(Path(CGRect(x: 0, y: 0, width: w, height: h * 0.25)), with: .color(red))
            // Yellow middle stripe (h/2)
            ctx.fill(Path(CGRect(x: 0, y: h * 0.25, width: w, height: h * 0.5)), with: .color(yellow))
            // Bottom red stripe (h/4)
            ctx.fill(Path(CGRect(x: 0, y: h * 0.75, width: w, height: h * 0.25)), with: .color(red))
        }
        .frame(width: width, height: height)
    }
}

// MARK: - USA / English 🇺🇸

private struct USAFlag: View {
    let width: CGFloat
    let height: CGFloat

    var body: some View {
        Canvas { ctx, size in
            let red  = Color(hex: 0xBF0A30)
            let blue = Color(hex: 0x002868)
            let w    = size.width
            let h    = size.height
            // 7 horizontal stripes (red/white alternating), top = red
            let stripeH = h / 7.0
            for i in 0..<7 {
                let color: Color = (i % 2 == 0) ? red : .white
                ctx.fill(Path(CGRect(x: 0, y: stripeH * CGFloat(i), width: w, height: stripeH)), with: .color(color))
            }
            // Blue canton: covers top-left 40% wide × top 3 stripes tall
            let cantonW = w * 0.40
            let cantonH = stripeH * 3.5
            ctx.fill(Path(CGRect(x: 0, y: 0, width: cantonW, height: cantonH)), with: .color(blue))
            // Stars hint: a 3×5 grid of small white dots inside the canton
            let cols = 5
            let rows = 3
            let dotR: CGFloat = min(cantonW / CGFloat(cols * 2 + 2), cantonH / CGFloat(rows * 2 + 2))
            for row in 0..<rows {
                for col in 0..<cols {
                    let cx = cantonW / CGFloat(cols + 1) * CGFloat(col + 1)
                    let cy = cantonH / CGFloat(rows + 1) * CGFloat(row + 1)
                    var star = Path()
                    star.addEllipse(in: CGRect(x: cx - dotR, y: cy - dotR, width: dotR * 2, height: dotR * 2))
                    ctx.fill(star, with: .color(.white))
                }
            }
        }
        .frame(width: width, height: height)
    }
}

// MARK: - France 🇫🇷

private struct FranceFlag: View {
    let width: CGFloat
    let height: CGFloat

    // 3 vertical stripes equal: blue | white | red
    var body: some View {
        Canvas { ctx, size in
            let blue = Color(hex: 0x002395)
            let red  = Color(hex: 0xED2939)
            let w    = size.width
            let h    = size.height
            let sw   = w / 3.0
            ctx.fill(Path(CGRect(x: 0,      y: 0, width: sw, height: h)), with: .color(blue))
            ctx.fill(Path(CGRect(x: sw,     y: 0, width: sw, height: h)), with: .color(.white))
            ctx.fill(Path(CGRect(x: sw * 2, y: 0, width: sw, height: h)), with: .color(red))
        }
        .frame(width: width, height: height)
    }
}

// MARK: - Germany 🇩🇪

private struct GermanyFlag: View {
    let width: CGFloat
    let height: CGFloat

    // 3 horizontal stripes equal: black | red | gold
    var body: some View {
        Canvas { ctx, size in
            let black = Color(hex: 0x000000)
            let red   = Color(hex: 0xDD0000)
            let gold  = Color(hex: 0xFFCE00)
            let w = size.width
            let h = size.height
            let sh = h / 3.0
            ctx.fill(Path(CGRect(x: 0, y: 0,      width: w, height: sh)), with: .color(black))
            ctx.fill(Path(CGRect(x: 0, y: sh,     width: w, height: sh)), with: .color(red))
            ctx.fill(Path(CGRect(x: 0, y: sh * 2, width: w, height: sh)), with: .color(gold))
        }
        .frame(width: width, height: height)
    }
}

// MARK: - Italy 🇮🇹

private struct ItalyFlag: View {
    let width: CGFloat
    let height: CGFloat

    // 3 vertical stripes equal: green | white | red
    var body: some View {
        Canvas { ctx, size in
            let green = Color(hex: 0x009246)
            let red   = Color(hex: 0xCE2B37)
            let w     = size.width
            let h     = size.height
            let sw    = w / 3.0
            ctx.fill(Path(CGRect(x: 0,      y: 0, width: sw, height: h)), with: .color(green))
            ctx.fill(Path(CGRect(x: sw,     y: 0, width: sw, height: h)), with: .color(.white))
            ctx.fill(Path(CGRect(x: sw * 2, y: 0, width: sw, height: h)), with: .color(red))
        }
        .frame(width: width, height: height)
    }
}

// MARK: - Portugal 🇵🇹

private struct PortugalFlag: View {
    let width: CGFloat
    let height: CGFloat

    // Vertical 2:5 split — green 2 parts, red 3 parts; small yellow circle at junction
    var body: some View {
        Canvas { ctx, size in
            let green  = Color(hex: 0x006600)
            let red    = Color(hex: 0xFF0000)
            let yellow = Color(hex: 0xFFCE00)
            let w = size.width
            let h = size.height
            let greenW = w * 2.0 / 5.0
            // Green left
            ctx.fill(Path(CGRect(x: 0,      y: 0, width: greenW, height: h)), with: .color(green))
            // Red right
            ctx.fill(Path(CGRect(x: greenW, y: 0, width: w - greenW, height: h)), with: .color(red))
            // Yellow circle (armillary sphere hint) centered on the junction
            let circR = h * 0.28
            var circle = Path()
            circle.addEllipse(in: CGRect(x: greenW - circR, y: h / 2 - circR, width: circR * 2, height: circR * 2))
            ctx.fill(circle, with: .color(yellow))
            // Inner white circle (shield placeholder)
            var inner = Path()
            let innerR = circR * 0.65
            inner.addEllipse(in: CGRect(x: greenW - innerR, y: h / 2 - innerR, width: innerR * 2, height: innerR * 2))
            ctx.fill(inner, with: .color(.white))
        }
        .frame(width: width, height: height)
    }
}

// MARK: - Catalonia / Senyera

private struct CataloniaFlag: View {
    let width: CGFloat
    let height: CGFloat

    // Yellow background + 4 red horizontal stripes equally spaced
    var body: some View {
        Canvas { ctx, size in
            let yellow = Color(hex: 0xFCDD09)
            let red    = Color(hex: 0xDA121A)
            let w = size.width
            let h = size.height
            // Fill yellow background
            ctx.fill(Path(CGRect(x: 0, y: 0, width: w, height: h)), with: .color(yellow))
            // 4 red stripes in 9 equal bands (traditional: 4 red + 5 gold = 9 bands)
            // Bands are equal: each = h / 9
            let bandH = h / 9.0
            for i in [0, 2, 4, 6] { // red stripes at positions 0,2,4,6 (0-indexed)
                let y = bandH * CGFloat(i)
                ctx.fill(Path(CGRect(x: 0, y: y, width: w, height: bandH)), with: .color(red))
            }
        }
        .frame(width: width, height: height)
    }
}

// MARK: - Japan 🇯🇵

private struct JapanFlag: View {
    let width: CGFloat
    let height: CGFloat

    // White background, red circle centered (~60% of height diameter)
    var body: some View {
        Canvas { ctx, size in
            let red = Color(hex: 0xBC002D)
            let w = size.width
            let h = size.height
            // White background
            ctx.fill(Path(CGRect(x: 0, y: 0, width: w, height: h)), with: .color(.white))
            // Red circle
            let diam = h * 0.60
            let cx   = w / 2
            let cy   = h / 2
            var circle = Path()
            circle.addEllipse(in: CGRect(x: cx - diam / 2, y: cy - diam / 2, width: diam, height: diam))
            ctx.fill(circle, with: .color(red))
        }
        .frame(width: width, height: height)
    }
}

// MARK: - South Korea 🇰🇷

private struct SouthKoreaFlag: View {
    let width: CGFloat
    let height: CGFloat

    var body: some View {
        Canvas { ctx, size in
            let red  = Color(hex: 0xCD2E3A)
            let blue = Color(hex: 0x0047A0)
            let w    = size.width
            let h    = size.height
            // White background
            ctx.fill(Path(CGRect(x: 0, y: 0, width: w, height: h)), with: .color(.white))

            // Taeguk circle in center
            let cx    = w / 2
            let cy    = h / 2
            let diam  = h * 0.52
            let r     = diam / 2

            // Red top semicircle
            var redHalf = Path()
            redHalf.addArc(center: CGPoint(x: cx, y: cy), radius: r, startAngle: .degrees(180), endAngle: .degrees(0), clockwise: false)
            redHalf.closeSubpath()
            ctx.fill(redHalf, with: .color(red))

            // Blue bottom semicircle
            var blueHalf = Path()
            blueHalf.addArc(center: CGPoint(x: cx, y: cy), radius: r, startAngle: .degrees(0), endAngle: .degrees(180), clockwise: false)
            blueHalf.closeSubpath()
            ctx.fill(blueHalf, with: .color(blue))

            // Small red circle on the red side (top)
            var smallRed = Path()
            smallRed.addEllipse(in: CGRect(x: cx - r / 4, y: cy - r - r / 4, width: r / 2, height: r / 2))
            ctx.fill(smallRed, with: .color(red))

            // Small blue circle on the blue side (bottom)
            var smallBlue = Path()
            smallBlue.addEllipse(in: CGRect(x: cx - r / 4, y: cy + r - r / 4, width: r / 2, height: r / 2))
            ctx.fill(smallBlue, with: .color(blue))

            // Trigrams — 4 corners, simplified as short parallel bars
            let barLen: CGFloat  = r * 0.75
            let barThick: CGFloat = max(1.5, h * 0.025)
            let barGap: CGFloat  = barThick * 1.6

            // Helper to draw 3 trigram bars at a given center, rotated
            func drawTrigram(cx: CGFloat, cy: CGFloat, angle: CGFloat) {
                ctx.withCGContext { cgCtx in
                    cgCtx.saveGState()
                    cgCtx.translateBy(x: cx, y: cy)
                    cgCtx.rotate(by: angle * .pi / 180)
                    for i in -1...1 {
                        let yOff = CGFloat(i) * barGap
                        cgCtx.setFillColor(UIColor.black.cgColor)
                        cgCtx.fill(CGRect(x: -barLen / 2, y: yOff - barThick / 2, width: barLen, height: barThick))
                    }
                    cgCtx.restoreGState()
                }
            }

            let offset = r + barLen * 0.6
            // Top-left
            drawTrigram(cx: cx - offset * 0.65, cy: cy - offset * 0.4, angle: -45)
            // Top-right
            drawTrigram(cx: cx + offset * 0.65, cy: cy - offset * 0.4, angle: 45)
            // Bottom-left
            drawTrigram(cx: cx - offset * 0.65, cy: cy + offset * 0.4, angle: 45)
            // Bottom-right
            drawTrigram(cx: cx + offset * 0.65, cy: cy + offset * 0.4, angle: -45)
        }
        .frame(width: width, height: height)
    }
}

// MARK: - China 🇨🇳

private struct ChinaFlag: View {
    let width: CGFloat
    let height: CGFloat

    var body: some View {
        Canvas { ctx, size in
            let red    = Color(hex: 0xDE2910)
            let yellow = Color(hex: 0xFFDE00)
            let w      = size.width
            let h      = size.height
            // Red background
            ctx.fill(Path(CGRect(x: 0, y: 0, width: w, height: h)), with: .color(red))

            // Large star top-left
            let bigStarR: CGFloat = h * 0.24
            let bigStarCX = w * 0.14
            let bigStarCY = h * 0.26
            ctx.fill(starPath(cx: bigStarCX, cy: bigStarCY, outer: bigStarR, inner: bigStarR * 0.4, points: 5), with: .color(yellow))

            // 4 small stars in arc
            let smallR: CGFloat = h * 0.09
            let smallStarPositions: [(CGFloat, CGFloat)] = [
                (w * 0.30, h * 0.10),
                (w * 0.37, h * 0.18),
                (w * 0.37, h * 0.30),
                (w * 0.30, h * 0.38)
            ]
            for (sx, sy) in smallStarPositions {
                ctx.fill(starPath(cx: sx, cy: sy, outer: smallR, inner: smallR * 0.4, points: 5), with: .color(yellow))
            }
        }
        .frame(width: width, height: height)
    }

    private func starPath(cx: CGFloat, cy: CGFloat, outer: CGFloat, inner: CGFloat, points: Int) -> Path {
        var path = Path()
        let total = points * 2
        for i in 0..<total {
            let angle = CGFloat(i) * .pi / CGFloat(points) - .pi / 2
            let r = (i % 2 == 0) ? outer : inner
            let x = cx + r * cos(angle)
            let y = cy + r * sin(angle)
            if i == 0 { path.move(to: CGPoint(x: x, y: y)) }
            else       { path.addLine(to: CGPoint(x: x, y: y)) }
        }
        path.closeSubpath()
        return path
    }
}

// MARK: - Netherlands 🇳🇱

private struct NetherlandsFlag: View {
    let width: CGFloat
    let height: CGFloat

    // 3 horizontal stripes equal: red | white | blue
    var body: some View {
        Canvas { ctx, size in
            let red  = Color(hex: 0xAE1C28)
            let blue = Color(hex: 0x21468B)
            let w    = size.width
            let h    = size.height
            let sh   = h / 3.0
            ctx.fill(Path(CGRect(x: 0, y: 0,      width: w, height: sh)), with: .color(red))
            ctx.fill(Path(CGRect(x: 0, y: sh,     width: w, height: sh)), with: .color(.white))
            ctx.fill(Path(CGRect(x: 0, y: sh * 2, width: w, height: sh)), with: .color(blue))
        }
        .frame(width: width, height: height)
    }
}

// MARK: - Poland 🇵🇱

private struct PolandFlag: View {
    let width: CGFloat
    let height: CGFloat

    // 2 horizontal stripes equal: white | red
    var body: some View {
        Canvas { ctx, size in
            let red = Color(hex: 0xDC143C)
            let w   = size.width
            let h   = size.height
            ctx.fill(Path(CGRect(x: 0, y: 0,       width: w, height: h / 2)), with: .color(.white))
            ctx.fill(Path(CGRect(x: 0, y: h / 2,   width: w, height: h / 2)), with: .color(red))
        }
        .frame(width: width, height: height)
    }
}

// MARK: - Turkey 🇹🇷

private struct TurkeyFlag: View {
    let width: CGFloat
    let height: CGFloat

    var body: some View {
        Canvas { ctx, size in
            let red = Color(hex: 0xE30A17)
            let w   = size.width
            let h   = size.height
            // Red background
            ctx.fill(Path(CGRect(x: 0, y: 0, width: w, height: h)), with: .color(red))

            // Crescent: white circle minus a red offset circle
            let cx    = w * 0.38
            let cy    = h * 0.50
            let outerR = h * 0.30
            let innerR = outerR * 0.80
            let innerOffX = outerR * 0.30

            // White outer circle
            var outer = Path()
            outer.addEllipse(in: CGRect(x: cx - outerR, y: cy - outerR, width: outerR * 2, height: outerR * 2))
            ctx.fill(outer, with: .color(.white))

            // Red inner circle (creates crescent)
            var inner = Path()
            inner.addEllipse(in: CGRect(x: cx - innerR + innerOffX, y: cy - innerR, width: innerR * 2, height: innerR * 2))
            ctx.fill(inner, with: .color(red))

            // White 5-point star to the right of crescent
            let starCX = cx + outerR * 0.95
            let starCY = cy
            let starR  = outerR * 0.42
            ctx.fill(starPath(cx: starCX, cy: starCY, outer: starR, inner: starR * 0.4, points: 5), with: .color(.white))
        }
        .frame(width: width, height: height)
    }

    private func starPath(cx: CGFloat, cy: CGFloat, outer: CGFloat, inner: CGFloat, points: Int) -> Path {
        var path = Path()
        let total = points * 2
        for i in 0..<total {
            let angle = CGFloat(i) * .pi / CGFloat(points) - .pi / 2
            let r = (i % 2 == 0) ? outer : inner
            let x = cx + r * cos(angle)
            let y = cy + r * sin(angle)
            if i == 0 { path.move(to: CGPoint(x: x, y: y)) }
            else       { path.addLine(to: CGPoint(x: x, y: y)) }
        }
        path.closeSubpath()
        return path
    }
}

// MARK: - Saudi Arabia / Arabic 🇸🇦

private struct SaudiArabiaFlag: View {
    let width: CGFloat
    let height: CGFloat

    var body: some View {
        Canvas { ctx, size in
            let green = Color(hex: 0x006C35)
            let w     = size.width
            let h     = size.height
            // Green background
            ctx.fill(Path(CGRect(x: 0, y: 0, width: w, height: h)), with: .color(green))

            // Shahada simplified: white horizontal text line
            let textY    = h * 0.38
            let textH    = max(2.0, h * 0.08)
            let textX    = w * 0.10
            let textW    = w * 0.80
            ctx.fill(Path(CGRect(x: textX, y: textY, width: textW, height: textH)), with: .color(.white))
            // A second, shorter line below (second line of Shahada)
            let textY2 = textY + textH * 2.5
            let textW2 = textW * 0.70
            let textX2 = textX + (textW - textW2) / 2
            ctx.fill(Path(CGRect(x: textX2, y: textY2, width: textW2, height: textH)), with: .color(.white))

            // Sword: vertical blade below the text, centered
            let swordX     = w * 0.5 - max(1.5, w * 0.02)
            let swordTop   = h * 0.57
            let swordBot   = h * 0.88
            let swordW     = max(3.0, w * 0.045)
            // Blade (rectangle tapering — simplified as rectangle)
            ctx.fill(Path(CGRect(x: swordX, y: swordTop, width: swordW, height: swordBot - swordTop)), with: .color(.white))
            // Hilt (crossguard)
            let hiltY = swordTop + (swordBot - swordTop) * 0.15
            let hiltW = swordW * 3.5
            let hiltH = max(2.0, swordW * 0.5)
            ctx.fill(Path(CGRect(x: swordX - (hiltW - swordW) / 2, y: hiltY, width: hiltW, height: hiltH)), with: .color(.white))
        }
        .frame(width: width, height: height)
    }
}

// MARK: - Russia 🇷🇺

private struct RussiaFlag: View {
    let width: CGFloat
    let height: CGFloat

    // 3 horizontal stripes equal: white | blue | red
    var body: some View {
        Canvas { ctx, size in
            let blue = Color(hex: 0x0039A6)
            let red  = Color(hex: 0xD52B1E)
            let w    = size.width
            let h    = size.height
            let sh   = h / 3.0
            ctx.fill(Path(CGRect(x: 0, y: 0,      width: w, height: sh)), with: .color(.white))
            ctx.fill(Path(CGRect(x: 0, y: sh,     width: w, height: sh)), with: .color(blue))
            ctx.fill(Path(CGRect(x: 0, y: sh * 2, width: w, height: sh)), with: .color(red))
        }
        .frame(width: width, height: height)
    }
}
