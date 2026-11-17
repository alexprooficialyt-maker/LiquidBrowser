import SwiftUI

// MARK: - LiquidIconType Enum (45+ Handcrafted Vector Icons)

public enum LiquidIconType: String, CaseIterable, Sendable {
    // 1. Navegación
    case back
    case forward
    case reload
    case stop
    case home

    // 2. Barra de acciones
    case share
    case tabs
    case newTab
    case close
    case search

    // 3. Motores de Búsqueda
    case googleSearch
    case duckDuckGoSearch
    case braveSearch
    case ecosiaSearch

    // 4. Seguridad y SSL
    case lockSSL
    case unlockSSL
    case shieldBlocker

    // 5. Autenticación y Perfil
    case faceID
    case touchID
    case pinPad
    case userProfile
    case googleAccount

    // 6. Espacios y Carpetas
    case spaceFolder
    case spaceWork
    case spaceStudy
    case spaceCode
    case spacePrivate
    case spaceStar

    // 7. Acciones de Pestaña y Menú Contextual
    case pin
    case unpin
    case moveSpace
    case editPencil
    case renewTab

    // 8. Herramientas del Navegador
    case readerMode
    case desktopMode
    case mobileMode
    case qrCode
    case download
    case history
    case bookmark
    case bookmarkFilled
    case settings
    case trash
    case burnSession
    case sliderAdjust

    // 9. Créditos y Autor
    case creditsAuthor

    // 10. Chevrons y Controles
    case chevronLeft
    case chevronRight
    case chevronUp
    case chevronDown
    case checkmark
}

// MARK: - LiquidIconShape Router

public struct LiquidIconShape: Shape {
    public let type: LiquidIconType

    public init(_ type: LiquidIconType) {
        self.type = type
    }

    public func path(in rect: CGRect) -> Path {
        var p = Path()
        let w = rect.width
        let h = rect.height
        guard w > 0, h > 0 else { return p }

        switch type {
        // --- NAVEGACIÓN ---
        case .back:
            p.move(to: CGPoint(x: w * 0.65, y: h * 0.20))
            p.addLine(to: CGPoint(x: w * 0.32, y: h * 0.50))
            p.addLine(to: CGPoint(x: w * 0.65, y: h * 0.80))
            p.move(to: CGPoint(x: w * 0.32, y: h * 0.50))
            p.addLine(to: CGPoint(x: w * 0.80, y: h * 0.50))

        case .forward:
            p.move(to: CGPoint(x: w * 0.35, y: h * 0.20))
            p.addLine(to: CGPoint(x: w * 0.68, y: h * 0.50))
            p.addLine(to: CGPoint(x: w * 0.35, y: h * 0.80))
            p.move(to: CGPoint(x: w * 0.68, y: h * 0.50))
            p.addLine(to: CGPoint(x: w * 0.20, y: h * 0.50))

        case .reload:
            let center = CGPoint(x: w * 0.50, y: h * 0.50)
            let r = min(w, h) * 0.35
            p.addArc(center: center, radius: r, startAngle: .degrees(-40), endAngle: .degrees(250), clockwise: false)
            let tip = CGPoint(x: center.x + r * cos(CGFloat(-40 * Double.pi / 180)),
                              y: center.y + r * sin(CGFloat(-40 * Double.pi / 180)))
            p.move(to: CGPoint(x: tip.x - w * 0.04, y: tip.y - h * 0.16))
            p.addLine(to: tip)
            p.addLine(to: CGPoint(x: tip.x - w * 0.16, y: tip.y - h * 0.04))

        case .stop:
            p.addEllipse(in: CGRect(x: w * 0.15, y: h * 0.15, width: w * 0.70, height: h * 0.70))
            p.move(to: CGPoint(x: w * 0.36, y: h * 0.36))
            p.addLine(to: CGPoint(x: w * 0.64, y: h * 0.64))
            p.move(to: CGPoint(x: w * 0.64, y: h * 0.36))
            p.addLine(to: CGPoint(x: w * 0.36, y: h * 0.64))

        case .home:
            p.move(to: CGPoint(x: w * 0.18, y: h * 0.46))
            p.addLine(to: CGPoint(x: w * 0.50, y: h * 0.18))
            p.addLine(to: CGPoint(x: w * 0.82, y: h * 0.46))
            p.move(to: CGPoint(x: w * 0.26, y: h * 0.43))
            p.addLine(to: CGPoint(x: w * 0.26, y: h * 0.82))
            p.addLine(to: CGPoint(x: w * 0.74, y: h * 0.82))
            p.addLine(to: CGPoint(x: w * 0.74, y: h * 0.43))
            p.move(to: CGPoint(x: w * 0.42, y: h * 0.82))
            p.addLine(to: CGPoint(x: w * 0.42, y: h * 0.58))
            p.addLine(to: CGPoint(x: w * 0.58, y: h * 0.58))
            p.addLine(to: CGPoint(x: w * 0.58, y: h * 0.82))

        // --- BARRA DE ACCIONES ---
        case .share:
            p.addRoundedRect(in: CGRect(x: w * 0.22, y: h * 0.40, width: w * 0.56, height: h * 0.45),
                             cornerSize: CGSize(width: 4, height: 4))
            p.move(to: CGPoint(x: w * 0.50, y: h * 0.15))
            p.addLine(to: CGPoint(x: w * 0.50, y: h * 0.58))
            p.move(to: CGPoint(x: w * 0.34, y: h * 0.30))
            p.addLine(to: CGPoint(x: w * 0.50, y: h * 0.15))
            p.addLine(to: CGPoint(x: w * 0.66, y: h * 0.30))

        case .tabs:
            p.addRoundedRect(in: CGRect(x: w * 0.18, y: h * 0.26, width: w * 0.50, height: h * 0.50),
                             cornerSize: CGSize(width: 5, height: 5))
            p.move(to: CGPoint(x: w * 0.36, y: h * 0.26))
            p.addLine(to: CGPoint(x: w * 0.36, y: h * 0.18))
            p.addLine(to: CGPoint(x: w * 0.82, y: h * 0.18))
            p.addLine(to: CGPoint(x: w * 0.82, y: h * 0.64))
            p.addLine(to: CGPoint(x: w * 0.68, y: h * 0.64))

        case .newTab:
            p.move(to: CGPoint(x: w * 0.50, y: h * 0.20))
            p.addLine(to: CGPoint(x: w * 0.50, y: h * 0.80))
            p.move(to: CGPoint(x: w * 0.20, y: h * 0.50))
            p.addLine(to: CGPoint(x: w * 0.80, y: h * 0.50))

        case .close:
            p.move(to: CGPoint(x: w * 0.26, y: h * 0.26))
            p.addLine(to: CGPoint(x: w * 0.74, y: h * 0.74))
            p.move(to: CGPoint(x: w * 0.74, y: h * 0.26))
            p.addLine(to: CGPoint(x: w * 0.26, y: h * 0.74))

        case .search:
            let cr = min(w, h) * 0.26
            let cc = CGPoint(x: w * 0.42, y: h * 0.42)
            p.addEllipse(in: CGRect(x: cc.x - cr, y: cc.y - cr, width: cr * 2, height: cr * 2))
            p.move(to: CGPoint(x: cc.x + cr * 0.70, y: cc.y + cr * 0.70))
            p.addLine(to: CGPoint(x: w * 0.82, y: h * 0.82))

        // --- MOTORES DE BÚSQUEDA VECTORIALES ---
        case .googleSearch:
            let center = CGPoint(x: w * 0.50, y: h * 0.50)
            let r = min(w, h) * 0.34
            p.addArc(center: center, radius: r, startAngle: .degrees(-40), endAngle: .degrees(290), clockwise: false)
            p.move(to: CGPoint(x: center.x, y: center.y))
            p.addLine(to: CGPoint(x: center.x + r, y: center.y))

        case .duckDuckGoSearch:
            p.move(to: CGPoint(x: w * 0.30, y: h * 0.70))
            p.addQuadCurve(to: CGPoint(x: w * 0.50, y: h * 0.30), control: CGPoint(x: w * 0.20, y: h * 0.35))
            p.addQuadCurve(to: CGPoint(x: w * 0.75, y: h * 0.26), control: CGPoint(x: w * 0.60, y: h * 0.16))
            p.addLine(to: CGPoint(x: w * 0.84, y: h * 0.34))
            p.addLine(to: CGPoint(x: w * 0.72, y: h * 0.44))
            p.addQuadCurve(to: CGPoint(x: w * 0.70, y: h * 0.70), control: CGPoint(x: w * 0.80, y: h * 0.60))
            p.closeSubpath()
            p.addEllipse(in: CGRect(x: w * 0.58, y: h * 0.28, width: w * 0.06, height: h * 0.06))

        case .braveSearch:
            p.move(to: CGPoint(x: w * 0.50, y: h * 0.15))
            p.addLine(to: CGPoint(x: w * 0.80, y: h * 0.28))
            p.addLine(to: CGPoint(x: w * 0.72, y: h * 0.62))
            p.addQuadCurve(to: CGPoint(x: w * 0.50, y: h * 0.85), control: CGPoint(x: w * 0.62, y: h * 0.80))
            p.addQuadCurve(to: CGPoint(x: w * 0.28, y: h * 0.62), control: CGPoint(x: w * 0.38, y: h * 0.80))
            p.addLine(to: CGPoint(x: w * 0.20, y: h * 0.28))
            p.closeSubpath()
            p.move(to: CGPoint(x: w * 0.40, y: h * 0.45))
            p.addLine(to: CGPoint(x: w * 0.60, y: h * 0.45))
            p.move(to: CGPoint(x: w * 0.50, y: h * 0.45))
            p.addLine(to: CGPoint(x: w * 0.50, y: h * 0.65))

        case .ecosiaSearch:
            p.move(to: CGPoint(x: w * 0.50, y: h * 0.85))
            p.addLine(to: CGPoint(x: w * 0.50, y: h * 0.45))
            p.addQuadCurve(to: CGPoint(x: w * 0.25, y: h * 0.35), control: CGPoint(x: w * 0.30, y: h * 0.48))
            p.addQuadCurve(to: CGPoint(x: w * 0.50, y: h * 0.18), control: CGPoint(x: w * 0.30, y: h * 0.20))
            p.addQuadCurve(to: CGPoint(x: w * 0.75, y: h * 0.35), control: CGPoint(x: w * 0.70, y: h * 0.20))
            p.addQuadCurve(to: CGPoint(x: w * 0.50, y: h * 0.45), control: CGPoint(x: w * 0.70, y: h * 0.48))

        // --- SEGURIDAD Y SSL ---
        case .lockSSL:
            p.addRoundedRect(in: CGRect(x: w * 0.24, y: h * 0.44, width: w * 0.52, height: h * 0.42),
                             cornerSize: CGSize(width: 5, height: 5))
            p.addArc(center: CGPoint(x: w * 0.50, y: h * 0.44), radius: w * 0.18, startAngle: .degrees(180), endAngle: .degrees(0), clockwise: false)
            p.addEllipse(in: CGRect(x: w * 0.46, y: h * 0.58, width: w * 0.08, height: h * 0.08))
            p.move(to: CGPoint(x: w * 0.50, y: h * 0.66))
            p.addLine(to: CGPoint(x: w * 0.50, y: h * 0.74))

        case .unlockSSL:
            p.addRoundedRect(in: CGRect(x: w * 0.24, y: h * 0.44, width: w * 0.52, height: h * 0.42),
                             cornerSize: CGSize(width: 5, height: 5))
            p.addArc(center: CGPoint(x: w * 0.58, y: h * 0.38), radius: w * 0.18, startAngle: .degrees(180), endAngle: .degrees(0), clockwise: false)
            p.move(to: CGPoint(x: w * 0.50, y: h * 0.60))
            p.addLine(to: CGPoint(x: w * 0.50, y: h * 0.72))

        case .shieldBlocker:
            p.move(to: CGPoint(x: w * 0.50, y: h * 0.14))
            p.addLine(to: CGPoint(x: w * 0.82, y: h * 0.24))
            p.addLine(to: CGPoint(x: w * 0.76, y: h * 0.64))
            p.addQuadCurve(to: CGPoint(x: w * 0.50, y: h * 0.88), control: CGPoint(x: w * 0.68, y: h * 0.82))
            p.addQuadCurve(to: CGPoint(x: w * 0.24, y: h * 0.64), control: CGPoint(x: w * 0.32, y: h * 0.82))
            p.addLine(to: CGPoint(x: w * 0.18, y: h * 0.24))
            p.closeSubpath()
            p.move(to: CGPoint(x: w * 0.34, y: h * 0.48))
            p.addLine(to: CGPoint(x: w * 0.46, y: h * 0.60))
            p.addLine(to: CGPoint(x: w * 0.66, y: h * 0.38))

        // --- AUTENTICACIÓN Y PERFIL ---
        case .faceID:
            // Esquinas biométricas de detección
            let cL: CGFloat = w * 0.18
            let s: CGFloat = w * 0.15
            let e: CGFloat = w * 0.85
            // Superior izq
            p.move(to: CGPoint(x: s, y: s + cL)); p.addLine(to: CGPoint(x: s, y: s)); p.addLine(to: CGPoint(x: s + cL, y: s))
            // Superior der
            p.move(to: CGPoint(x: e - cL, y: s)); p.addLine(to: CGPoint(x: e, y: s)); p.addLine(to: CGPoint(x: e, y: s + cL))
            // Inferior izq
            p.move(to: CGPoint(x: s, y: e - cL)); p.addLine(to: CGPoint(x: s, y: e)); p.addLine(to: CGPoint(x: s + cL, y: e))
            // Inferior der
            p.move(to: CGPoint(x: e - cL, y: e)); p.addLine(to: CGPoint(x: e, y: e)); p.addLine(to: CGPoint(x: e, y: e - cL))
            // Ojos
            p.move(to: CGPoint(x: w * 0.34, y: h * 0.40)); p.addLine(to: CGPoint(x: w * 0.34, y: h * 0.44))
            p.move(to: CGPoint(x: w * 0.66, y: h * 0.40)); p.addLine(to: CGPoint(x: w * 0.66, y: h * 0.44))
            // Nariz
            p.move(to: CGPoint(x: w * 0.50, y: h * 0.46)); p.addLine(to: CGPoint(x: w * 0.50, y: h * 0.56))
            p.addLine(to: CGPoint(x: w * 0.45, y: h * 0.56))
            // Boca
            p.move(to: CGPoint(x: w * 0.36, y: h * 0.66))
            p.addQuadCurve(to: CGPoint(x: w * 0.64, y: h * 0.66), control: CGPoint(x: w * 0.50, y: h * 0.74))

        case .touchID:
            let center = CGPoint(x: w * 0.50, y: h * 0.50)
            p.addArc(center: center, radius: w * 0.12, startAngle: .degrees(130), endAngle: .degrees(50), clockwise: false)
            p.addArc(center: center, radius: w * 0.22, startAngle: .degrees(140), endAngle: .degrees(40), clockwise: false)
            p.addArc(center: center, radius: w * 0.32, startAngle: .degrees(150), endAngle: .degrees(30), clockwise: false)
            p.addArc(center: center, radius: w * 0.40, startAngle: .degrees(160), endAngle: .degrees(20), clockwise: false)

        case .pinPad:
            let r: CGFloat = w * 0.05
            for row in 0..<3 {
                for col in 0..<3 {
                    let cx = w * 0.26 + CGFloat(col) * (w * 0.24)
                    let cy = h * 0.26 + CGFloat(row) * (h * 0.24)
                    p.addEllipse(in: CGRect(x: cx - r, y: cy - r, width: r * 2, height: r * 2))
                }
            }

        case .userProfile, .googleAccount:
            p.addEllipse(in: CGRect(x: w * 0.12, y: h * 0.12, width: w * 0.76, height: h * 0.76))
            p.addEllipse(in: CGRect(x: w * 0.36, y: h * 0.26, width: w * 0.28, height: h * 0.28))
            p.move(to: CGPoint(x: w * 0.24, y: h * 0.78))
            p.addQuadCurve(to: CGPoint(x: w * 0.76, y: h * 0.78), control: CGPoint(x: w * 0.50, y: h * 0.58))

        // --- ESPACIOS Y CARPETAS ---
        case .spaceFolder:
            p.move(to: CGPoint(x: w * 0.16, y: h * 0.32))
            p.addLine(to: CGPoint(x: w * 0.40, y: h * 0.32))
            p.addLine(to: CGPoint(x: w * 0.48, y: h * 0.42))
            p.addLine(to: CGPoint(x: w * 0.84, y: h * 0.42))
            p.addLine(to: CGPoint(x: w * 0.84, y: h * 0.78))
            p.addLine(to: CGPoint(x: w * 0.16, y: h * 0.78))
            p.closeSubpath()

        case .spaceWork:
            p.addRoundedRect(in: CGRect(x: w * 0.16, y: h * 0.36, width: w * 0.68, height: h * 0.50),
                             cornerSize: CGSize(width: 5, height: 5))
            p.move(to: CGPoint(x: w * 0.34, y: h * 0.36))
            p.addLine(to: CGPoint(x: w * 0.34, y: h * 0.22))
            p.addLine(to: CGPoint(x: w * 0.66, y: h * 0.22))
            p.addLine(to: CGPoint(x: w * 0.66, y: h * 0.36))
            p.move(to: CGPoint(x: w * 0.16, y: h * 0.56))
            p.addLine(to: CGPoint(x: w * 0.84, y: h * 0.56))

        case .spaceStudy:
            p.move(to: CGPoint(x: w * 0.50, y: h * 0.22))
            p.addLine(to: CGPoint(x: w * 0.86, y: h * 0.40))
            p.addLine(to: CGPoint(x: w * 0.50, y: h * 0.58))
            p.addLine(to: CGPoint(x: w * 0.14, y: h * 0.40))
            p.closeSubpath()
            p.move(to: CGPoint(x: w * 0.28, y: h * 0.48))
            p.addLine(to: CGPoint(x: w * 0.28, y: h * 0.70))
            p.addQuadCurve(to: CGPoint(x: w * 0.72, y: h * 0.70), control: CGPoint(x: w * 0.50, y: h * 0.82))
            p.addLine(to: CGPoint(x: w * 0.72, y: h * 0.48))

        case .spaceCode:
            p.move(to: CGPoint(x: w * 0.36, y: h * 0.28))
            p.addLine(to: CGPoint(x: w * 0.18, y: h * 0.50))
            p.addLine(to: CGPoint(x: w * 0.36, y: h * 0.72))
            p.move(to: CGPoint(x: w * 0.64, y: h * 0.28))
            p.addLine(to: CGPoint(x: w * 0.82, y: h * 0.50))
            p.addLine(to: CGPoint(x: w * 0.64, y: h * 0.72))
            p.move(to: CGPoint(x: w * 0.56, y: h * 0.24))
            p.addLine(to: CGPoint(x: w * 0.44, y: h * 0.76))

        case .spacePrivate:
            p.move(to: CGPoint(x: w * 0.15, y: h * 0.50))
            p.addQuadCurve(to: CGPoint(x: w * 0.85, y: h * 0.50), control: CGPoint(x: w * 0.50, y: h * 0.20))
            p.addQuadCurve(to: CGPoint(x: w * 0.15, y: h * 0.50), control: CGPoint(x: w * 0.50, y: h * 0.80))
            p.addEllipse(in: CGRect(x: w * 0.40, y: h * 0.40, width: w * 0.20, height: h * 0.20))

        case .spaceStar:
            let center = CGPoint(x: w * 0.50, y: h * 0.50)
            let rOut = min(w, h) * 0.38
            let rIn = rOut * 0.42
            for i in 0..<10 {
                let angle = Double(i) * Double.pi / 5.0 - Double.pi / 2.0
                let r = (i % 2 == 0) ? rOut : rIn
                let pt = CGPoint(x: center.x + CGFloat(cos(angle)) * r,
                                 y: center.y + CGFloat(sin(angle)) * r)
                if i == 0 { p.move(to: pt) } else { p.addLine(to: pt) }
            }
            p.closeSubpath()

        // --- ACCIONES DE PESTAÑA Y MENÚ CONTEXTUAL ---
        case .pin:
            p.move(to: CGPoint(x: w * 0.35, y: h * 0.20))
            p.addLine(to: CGPoint(x: w * 0.65, y: h * 0.20))
            p.addLine(to: CGPoint(x: w * 0.58, y: h * 0.50))
            p.addLine(to: CGPoint(x: w * 0.72, y: h * 0.56))
            p.addLine(to: CGPoint(x: w * 0.28, y: h * 0.56))
            p.addLine(to: CGPoint(x: w * 0.42, y: h * 0.50))
            p.closeSubpath()
            p.move(to: CGPoint(x: w * 0.50, y: h * 0.56))
            p.addLine(to: CGPoint(x: w * 0.50, y: h * 0.85))

        case .unpin:
            p.move(to: CGPoint(x: w * 0.35, y: h * 0.20))
            p.addLine(to: CGPoint(x: w * 0.65, y: h * 0.20))
            p.move(to: CGPoint(x: w * 0.50, y: h * 0.56))
            p.addLine(to: CGPoint(x: w * 0.50, y: h * 0.85))
            p.move(to: CGPoint(x: w * 0.20, y: h * 0.20))
            p.addLine(to: CGPoint(x: w * 0.80, y: h * 0.80))

        case .moveSpace:
            p.move(to: CGPoint(x: w * 0.14, y: h * 0.34))
            p.addLine(to: CGPoint(x: w * 0.36, y: h * 0.34))
            p.addLine(to: CGPoint(x: w * 0.44, y: h * 0.44))
            p.addLine(to: CGPoint(x: w * 0.68, y: h * 0.44))
            p.addLine(to: CGPoint(x: w * 0.68, y: h * 0.76))
            p.addLine(to: CGPoint(x: w * 0.14, y: h * 0.76))
            p.closeSubpath()
            p.move(to: CGPoint(x: w * 0.60, y: h * 0.60))
            p.addLine(to: CGPoint(x: w * 0.86, y: h * 0.60))
            p.addLine(to: CGPoint(x: w * 0.78, y: h * 0.52))

        case .editPencil:
            p.move(to: CGPoint(x: w * 0.22, y: h * 0.78))
            p.addLine(to: CGPoint(x: w * 0.22, y: h * 0.66))
            p.addLine(to: CGPoint(x: w * 0.64, y: h * 0.24))
            p.addLine(to: CGPoint(x: w * 0.76, y: h * 0.36))
            p.addLine(to: CGPoint(x: w * 0.34, y: h * 0.78))
            p.closeSubpath()
            p.move(to: CGPoint(x: w * 0.16, y: h * 0.84))
            p.addLine(to: CGPoint(x: w * 0.30, y: h * 0.84))

        case .renewTab:
            let center = CGPoint(x: w * 0.50, y: h * 0.50)
            let r = min(w, h) * 0.34
            p.addArc(center: center, radius: r, startAngle: .degrees(45), endAngle: .degrees(315), clockwise: false)
            let tip = CGPoint(x: center.x + r * cos(CGFloat(45 * Double.pi / 180)),
                              y: center.y + r * sin(CGFloat(45 * Double.pi / 180)))
            p.move(to: CGPoint(x: tip.x + w * 0.05, y: tip.y - h * 0.15))
            p.addLine(to: tip)
            p.addLine(to: CGPoint(x: tip.x - w * 0.15, y: tip.y - h * 0.05))

        // --- HERRAMIENTAS ---
        case .readerMode:
            p.move(to: CGPoint(x: w * 0.50, y: h * 0.26))
            p.addLine(to: CGPoint(x: w * 0.50, y: h * 0.78))
            p.addQuadCurve(to: CGPoint(x: w * 0.18, y: h * 0.74), control: CGPoint(x: w * 0.34, y: h * 0.78))
            p.addLine(to: CGPoint(x: w * 0.18, y: h * 0.22))
            p.addQuadCurve(to: CGPoint(x: w * 0.50, y: h * 0.26), control: CGPoint(x: w * 0.34, y: h * 0.22))
            p.addQuadCurve(to: CGPoint(x: w * 0.82, y: h * 0.22), control: CGPoint(x: w * 0.66, y: h * 0.22))
            p.addLine(to: CGPoint(x: w * 0.82, y: h * 0.74))
            p.addQuadCurve(to: CGPoint(x: w * 0.50, y: h * 0.78), control: CGPoint(x: w * 0.66, y: h * 0.78))

        case .desktopMode:
            p.addRoundedRect(in: CGRect(x: w * 0.16, y: h * 0.22, width: w * 0.68, height: h * 0.46),
                             cornerSize: CGSize(width: 4, height: 4))
            p.move(to: CGPoint(x: w * 0.50, y: h * 0.68))
            p.addLine(to: CGPoint(x: w * 0.50, y: h * 0.82))
            p.move(to: CGPoint(x: w * 0.32, y: h * 0.82))
            p.addLine(to: CGPoint(x: w * 0.68, y: h * 0.82))

        case .mobileMode:
            p.addRoundedRect(in: CGRect(x: w * 0.28, y: h * 0.16, width: w * 0.44, height: h * 0.68),
                             cornerSize: CGSize(width: 7, height: 7))
            p.move(to: CGPoint(x: w * 0.46, y: h * 0.76))
            p.addLine(to: CGPoint(x: w * 0.54, y: h * 0.76))

        case .qrCode:
            // Esquinas cuadradas de alineación QR
            let s: CGFloat = w * 0.20
            p.addRect(CGRect(x: w * 0.16, y: h * 0.16, width: s, height: s))
            p.addRect(CGRect(x: w * 0.64, y: h * 0.16, width: s, height: s))
            p.addRect(CGRect(x: w * 0.16, y: h * 0.64, width: s, height: s))
            p.addRect(CGRect(x: w * 0.44, y: h * 0.44, width: w * 0.12, height: h * 0.12))
            p.addRect(CGRect(x: w * 0.64, y: h * 0.64, width: w * 0.20, height: h * 0.20))

        case .download:
            p.move(to: CGPoint(x: w * 0.50, y: h * 0.18))
            p.addLine(to: CGPoint(x: w * 0.50, y: h * 0.60))
            p.move(to: CGPoint(x: w * 0.32, y: h * 0.44))
            p.addLine(to: CGPoint(x: w * 0.50, y: h * 0.60))
            p.addLine(to: CGPoint(x: w * 0.68, y: h * 0.44))
            p.move(to: CGPoint(x: w * 0.20, y: h * 0.74))
            p.addLine(to: CGPoint(x: w * 0.20, y: h * 0.82))
            p.addLine(to: CGPoint(x: w * 0.80, y: h * 0.82))
            p.addLine(to: CGPoint(x: w * 0.80, y: h * 0.74))

        case .history:
            let center = CGPoint(x: w * 0.50, y: h * 0.50)
            p.addEllipse(in: CGRect(x: w * 0.16, y: h * 0.16, width: w * 0.68, height: h * 0.68))
            p.move(to: center)
            p.addLine(to: CGPoint(x: center.x, y: h * 0.30))
            p.move(to: center)
            p.addLine(to: CGPoint(x: w * 0.66, y: center.y))

        case .bookmark:
            p.move(to: CGPoint(x: w * 0.26, y: h * 0.16))
            p.addLine(to: CGPoint(x: w * 0.74, y: h * 0.16))
            p.addLine(to: CGPoint(x: w * 0.74, y: h * 0.84))
            p.addLine(to: CGPoint(x: w * 0.50, y: h * 0.66))
            p.addLine(to: CGPoint(x: w * 0.26, y: h * 0.84))
            p.closeSubpath()

        case .bookmarkFilled:
            p.move(to: CGPoint(x: w * 0.26, y: h * 0.16))
            p.addLine(to: CGPoint(x: w * 0.74, y: h * 0.16))
            p.addLine(to: CGPoint(x: w * 0.74, y: h * 0.84))
            p.addLine(to: CGPoint(x: w * 0.50, y: h * 0.66))
            p.addLine(to: CGPoint(x: w * 0.26, y: h * 0.84))
            p.closeSubpath()

        case .settings:
            let center = CGPoint(x: w * 0.50, y: h * 0.50)
            p.addEllipse(in: CGRect(x: center.x - w * 0.14, y: center.y - h * 0.14, width: w * 0.28, height: h * 0.28))
            let rOut = min(w, h) * 0.36
            let rIn = rOut * 0.82
            for i in 0..<8 {
                let a = Double(i) * Double.pi / 4.0
                let ptOut1 = CGPoint(x: center.x + CGFloat(cos(a - 0.12)) * rOut, y: center.y + CGFloat(sin(a - 0.12)) * rOut)
                let ptOut2 = CGPoint(x: center.x + CGFloat(cos(a + 0.12)) * rOut, y: center.y + CGFloat(sin(a + 0.12)) * rOut)
                let ptIn = CGPoint(x: center.x + CGFloat(cos(a + 0.39)) * rIn, y: center.y + CGFloat(sin(a + 0.39)) * rIn)
                if i == 0 { p.move(to: ptOut1) } else { p.addLine(to: ptOut1) }
                p.addLine(to: ptOut2)
                p.addLine(to: ptIn)
            }
            p.closeSubpath()

        case .trash:
            p.move(to: CGPoint(x: w * 0.22, y: h * 0.28))
            p.addLine(to: CGPoint(x: w * 0.78, y: h * 0.28))
            p.move(to: CGPoint(x: w * 0.38, y: h * 0.28))
            p.addLine(to: CGPoint(x: w * 0.38, y: h * 0.18))
            p.addLine(to: CGPoint(x: w * 0.62, y: h * 0.18))
            p.addLine(to: CGPoint(x: w * 0.62, y: h * 0.28))
            p.addRoundedRect(in: CGRect(x: w * 0.26, y: h * 0.28, width: w * 0.48, height: h * 0.54),
                             cornerSize: CGSize(width: 3, height: 3))
            p.move(to: CGPoint(x: w * 0.42, y: h * 0.40))
            p.addLine(to: CGPoint(x: w * 0.42, y: h * 0.70))
            p.move(to: CGPoint(x: w * 0.58, y: h * 0.40))
            p.addLine(to: CGPoint(x: w * 0.58, y: h * 0.70))

        case .burnSession:
            p.move(to: CGPoint(x: w * 0.50, y: h * 0.15))
            p.addQuadCurve(to: CGPoint(x: w * 0.76, y: h * 0.58), control: CGPoint(x: w * 0.78, y: h * 0.34))
            p.addQuadCurve(to: CGPoint(x: w * 0.50, y: h * 0.86), control: CGPoint(x: w * 0.74, y: h * 0.82))
            p.addQuadCurve(to: CGPoint(x: w * 0.24, y: h * 0.58), control: CGPoint(x: w * 0.26, y: h * 0.82))
            p.addQuadCurve(to: CGPoint(x: w * 0.50, y: h * 0.15), control: CGPoint(x: w * 0.22, y: h * 0.34))
            p.move(to: CGPoint(x: w * 0.50, y: h * 0.48))
            p.addQuadCurve(to: CGPoint(x: w * 0.62, y: h * 0.66), control: CGPoint(x: w * 0.64, y: h * 0.54))
            p.addQuadCurve(to: CGPoint(x: w * 0.50, y: h * 0.76), control: CGPoint(x: w * 0.60, y: h * 0.76))
            p.addQuadCurve(to: CGPoint(x: w * 0.38, y: h * 0.66), control: CGPoint(x: w * 0.40, y: h * 0.76))
            p.addQuadCurve(to: CGPoint(x: w * 0.50, y: h * 0.48), control: CGPoint(x: w * 0.36, y: h * 0.54))

        case .sliderAdjust:
            p.move(to: CGPoint(x: w * 0.20, y: h * 0.35)); p.addLine(to: CGPoint(x: w * 0.80, y: h * 0.35))
            p.move(to: CGPoint(x: w * 0.20, y: h * 0.65)); p.addLine(to: CGPoint(x: w * 0.80, y: h * 0.65))
            p.addEllipse(in: CGRect(x: w * 0.36, y: h * 0.25, width: w * 0.18, height: h * 0.20))
            p.addEllipse(in: CGRect(x: w * 0.54, y: h * 0.55, width: w * 0.18, height: h * 0.20))

        case .creditsAuthor:
            // Emblema de autor / diseñador Apple
            p.addEllipse(in: CGRect(x: w * 0.15, y: h * 0.15, width: w * 0.70, height: h * 0.70))
            p.move(to: CGPoint(x: w * 0.32, y: h * 0.68))
            p.addLine(to: CGPoint(x: w * 0.32, y: h * 0.32))
            p.addLine(to: CGPoint(x: w * 0.52, y: h * 0.32))
            p.addQuadCurve(to: CGPoint(x: w * 0.52, y: h * 0.50), control: CGPoint(x: w * 0.68, y: h * 0.41))
            p.addLine(to: CGPoint(x: w * 0.32, y: h * 0.50))
            p.move(to: CGPoint(x: w * 0.48, y: h * 0.50))
            p.addLine(to: CGPoint(x: w * 0.66, y: h * 0.68))

        // --- CHEVRONS Y CONTROLES ---
        case .chevronLeft:
            p.move(to: CGPoint(x: w * 0.62, y: h * 0.25))
            p.addLine(to: CGPoint(x: w * 0.38, y: h * 0.50))
            p.addLine(to: CGPoint(x: w * 0.62, y: h * 0.75))

        case .chevronRight:
            p.move(to: CGPoint(x: w * 0.38, y: h * 0.25))
            p.addLine(to: CGPoint(x: w * 0.62, y: h * 0.50))
            p.addLine(to: CGPoint(x: w * 0.38, y: h * 0.75))

        case .chevronUp:
            p.move(to: CGPoint(x: w * 0.25, y: h * 0.62))
            p.addLine(to: CGPoint(x: w * 0.50, y: h * 0.38))
            p.addLine(to: CGPoint(x: w * 0.75, y: h * 0.62))

        case .chevronDown:
            p.move(to: CGPoint(x: w * 0.25, y: h * 0.38))
            p.addLine(to: CGPoint(x: w * 0.50, y: h * 0.62))
            p.addLine(to: CGPoint(x: w * 0.75, y: h * 0.38))

        case .checkmark:
            p.move(to: CGPoint(x: w * 0.24, y: h * 0.52))
            p.addLine(to: CGPoint(x: w * 0.42, y: h * 0.70))
            p.addLine(to: CGPoint(x: w * 0.76, y: h * 0.32))
        }

        return p
    }
}

// MARK: - LiquidIconView

public struct LiquidIconView: View {
    public let type: LiquidIconType
    public let size: CGFloat
    public let color: Color?
    public let strokeWidth: CGFloat

    @Environment(\.colorScheme) private var colorScheme

    public init(
        _ type: LiquidIconType,
        size: CGFloat = 20,
        color: Color? = nil,
        strokeWidth: CGFloat = 1.5
    ) {
        self.type = type
        self.size = size
        self.color = color
        self.strokeWidth = strokeWidth
    }

    public var body: some View {
        let resolvedColor = color ?? ThemeManager.shared.textPrimary(for: colorScheme)

        LiquidIconShape(type)
            .stroke(
                resolvedColor,
                style: StrokeStyle(
                    lineWidth: strokeWidth,
                    lineCap: .round,
                    lineJoin: .round
                )
            )
            .frame(width: size, height: size)
    }
}
