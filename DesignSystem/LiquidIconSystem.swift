import SwiftUI

public enum LiquidIconType: String, CaseIterable, Identifiable, Sendable {
    case back
    case forward
    case reload
    case stop
    case home

    case share
    case tabs
    case newTab
    case close
    case search
    case lockSSL
    case unlockSSL
    case shieldBlocker

    case spaceFolder
    case spaceWork
    case spaceStudy
    case spaceCode
    case spacePrivate
    case spaceStar
    case pin
    case moveSpace

    case readerMode
    case zoomIn
    case zoomOut
    case desktopMode
    case mobileMode
    case qrCode
    case download
    case history
    case bookmark
    case bookmarkFilled
    case settings
    case trash
    case copy
    case check
    case chevronDown
    case chevronUp
    case sliderAdjust
    case burnSession
    case faceID

    public var id: String { rawValue }

    public var displayName: String {
        switch self {
        case .back: return "Atrás"
        case .forward: return "Adelante"
        case .reload: return "Recargar"
        case .stop: return "Detener"
        case .home: return "Inicio"
        case .share: return "Compartir"
        case .tabs: return "Pestañas"
        case .newTab: return "Nueva Pestaña"
        case .close: return "Cerrar"
        case .search: return "Buscar"
        case .lockSSL: return "Seguro"
        case .unlockSSL: return "No Seguro"
        case .shieldBlocker: return "Bloqueador"
        case .spaceFolder: return "General"
        case .spaceWork: return "Trabajo"
        case .spaceStudy: return "Estudio"
        case .spaceCode: return "Código"
        case .spacePrivate: return "Privado"
        case .spaceStar: return "Favoritos"
        case .pin: return "Fijar"
        case .moveSpace: return "Mover"
        case .readerMode: return "Modo Lector"
        case .zoomIn: return "Ampliar"
        case .zoomOut: return "Reducir"
        case .desktopMode: return "Versión Escritorio"
        case .mobileMode: return "Versión Móvil"
        case .qrCode: return "Código QR"
        case .download: return "Descargas"
        case .history: return "Historial"
        case .bookmark: return "Marcador"
        case .bookmarkFilled: return "Guardado"
        case .settings: return "Ajustes"
        case .trash: return "Papelera"
        case .copy: return "Copiar"
        case .check: return "Completado"
        case .chevronDown: return "Desplegar"
        case .chevronUp: return "Plegar"
        case .sliderAdjust: return "Controles"
        case .burnSession: return "Quemar Sesión"
        case .faceID: return "Seguridad Biométrica"
        }
    }
}

public struct LiquidIconShape: Shape {
    public var type: LiquidIconType

    public init(_ type: LiquidIconType) {
        self.type = type
    }

    public func path(in rect: CGRect) -> Path {
        var path = Path()
        let w = rect.width
        let h = rect.height

        switch type {
        case .back:
            path.move(to: CGPoint(x: w * 0.62, y: h * 0.18))
            path.addLine(to: CGPoint(x: w * 0.28, y: h * 0.50))
            path.addLine(to: CGPoint(x: w * 0.62, y: h * 0.82))

        case .forward:
            path.move(to: CGPoint(x: w * 0.38, y: h * 0.18))
            path.addLine(to: CGPoint(x: w * 0.72, y: h * 0.50))
            path.addLine(to: CGPoint(x: w * 0.38, y: h * 0.82))

        case .reload:
            let cx = rect.midX
            let cy = rect.midY
            let radius = min(w, h) * 0.36
            path.addArc(
                center: CGPoint(x: cx, y: cy),
                radius: radius,
                startAngle: .degrees(-50),
                endAngle: .degrees(220),
                clockwise: false
            )
            let angle = -50.0 * .pi / 180.0
            let tx = cx + radius * CGFloat(cos(angle))
            let ty = cy + radius * CGFloat(sin(angle))
            let arrowSize = radius * 0.46
            path.move(to: CGPoint(x: tx - arrowSize * 0.25, y: ty - arrowSize))
            path.addLine(to: CGPoint(x: tx, y: ty))
            path.addLine(to: CGPoint(x: tx + arrowSize, y: ty - arrowSize * 0.25))

        case .stop:
            let pad = w * 0.26
            path.addRoundedRect(in: rect.insetBy(dx: pad, dy: pad), cornerSize: CGSize(width: 4, height: 4))

        case .home:
            path.move(to: CGPoint(x: w * 0.16, y: h * 0.44))
            path.addLine(to: CGPoint(x: w * 0.50, y: h * 0.14))
            path.addLine(to: CGPoint(x: w * 0.84, y: h * 0.44))
            path.move(to: CGPoint(x: w * 0.24, y: h * 0.40))
            path.addLine(to: CGPoint(x: w * 0.24, y: h * 0.84))
            path.addLine(to: CGPoint(x: w * 0.76, y: h * 0.84))
            path.addLine(to: CGPoint(x: w * 0.76, y: h * 0.40))
            path.move(to: CGPoint(x: w * 0.42, y: h * 0.84))
            path.addLine(to: CGPoint(x: w * 0.42, y: h * 0.58))
            path.addLine(to: CGPoint(x: w * 0.58, y: h * 0.58))
            path.addLine(to: CGPoint(x: w * 0.58, y: h * 0.84))

        case .share:
            path.move(to: CGPoint(x: w * 0.18, y: h * 0.56))
            path.addLine(to: CGPoint(x: w * 0.18, y: h * 0.86))
            path.addLine(to: CGPoint(x: w * 0.82, y: h * 0.86))
            path.addLine(to: CGPoint(x: w * 0.82, y: h * 0.56))
            path.move(to: CGPoint(x: w * 0.50, y: h * 0.64))
            path.addLine(to: CGPoint(x: w * 0.50, y: h * 0.14))
            path.move(to: CGPoint(x: w * 0.28, y: h * 0.36))
            path.addLine(to: CGPoint(x: w * 0.50, y: h * 0.14))
            path.addLine(to: CGPoint(x: w * 0.72, y: h * 0.36))

        case .tabs:
            let corner = CGSize(width: 4.5, height: 4.5)
            path.addRoundedRect(
                in: CGRect(x: w * 0.22, y: h * 0.10, width: w * 0.68, height: h * 0.68),
                cornerSize: corner
            )
            path.addRoundedRect(
                in: CGRect(x: w * 0.10, y: h * 0.22, width: w * 0.68, height: h * 0.68),
                cornerSize: corner
            )

        case .newTab:
            let corner = CGSize(width: 5, height: 5)
            path.addRoundedRect(in: rect.insetBy(dx: w * 0.10, dy: h * 0.10), cornerSize: corner)
            path.move(to: CGPoint(x: w * 0.50, y: h * 0.28))
            path.addLine(to: CGPoint(x: w * 0.50, y: h * 0.72))
            path.move(to: CGPoint(x: w * 0.28, y: h * 0.50))
            path.addLine(to: CGPoint(x: w * 0.72, y: h * 0.50))

        case .close:
            path.move(to: CGPoint(x: w * 0.24, y: h * 0.24))
            path.addLine(to: CGPoint(x: w * 0.76, y: h * 0.76))
            path.move(to: CGPoint(x: w * 0.76, y: h * 0.24))
            path.addLine(to: CGPoint(x: w * 0.24, y: h * 0.76))

        case .search:
            let cx = w * 0.44
            let cy = h * 0.44
            let r = w * 0.28
            path.addEllipse(in: CGRect(x: cx - r, y: cy - r, width: r * 2, height: r * 2))
            path.move(to: CGPoint(x: cx + r * 0.70, y: cy + r * 0.70))
            path.addLine(to: CGPoint(x: w * 0.86, y: h * 0.86))

        case .lockSSL:
            path.addRoundedRect(
                in: CGRect(x: w * 0.20, y: h * 0.46, width: w * 0.60, height: h * 0.44),
                cornerSize: CGSize(width: 5, height: 5)
            )
            let cx = w * 0.50
            let cy = h * 0.42
            let r = w * 0.20
            path.addArc(center: CGPoint(x: cx, y: cy), radius: r, startAngle: .degrees(180), endAngle: .degrees(0), clockwise: true)
            path.move(to: CGPoint(x: cx, y: h * 0.60))
            path.addLine(to: CGPoint(x: cx, y: h * 0.74))

        case .unlockSSL:
            path.addRoundedRect(
                in: CGRect(x: w * 0.20, y: h * 0.46, width: w * 0.60, height: h * 0.44),
                cornerSize: CGSize(width: 5, height: 5)
            )
            let cx = w * 0.66
            let cy = h * 0.42
            let r = w * 0.20
            path.addArc(center: CGPoint(x: cx, y: cy), radius: r, startAngle: .degrees(180), endAngle: .degrees(0), clockwise: true)
            path.move(to: CGPoint(x: w * 0.50, y: h * 0.60))
            path.addLine(to: CGPoint(x: w * 0.50, y: h * 0.74))

        case .shieldBlocker:
            path.move(to: CGPoint(x: w * 0.50, y: h * 0.12))
            path.addLine(to: CGPoint(x: w * 0.82, y: h * 0.24))
            path.addQuadCurve(
                to: CGPoint(x: w * 0.50, y: h * 0.88),
                control: CGPoint(x: w * 0.82, y: h * 0.64)
            )
            path.addQuadCurve(
                to: CGPoint(x: w * 0.18, y: h * 0.24),
                control: CGPoint(x: w * 0.18, y: h * 0.64)
            )
            path.closeSubpath()
            path.move(to: CGPoint(x: w * 0.36, y: h * 0.48))
            path.addLine(to: CGPoint(x: w * 0.46, y: h * 0.58))
            path.addLine(to: CGPoint(x: w * 0.64, y: h * 0.40))

        case .spaceFolder:
            path.move(to: CGPoint(x: w * 0.14, y: h * 0.24))
            path.addLine(to: CGPoint(x: w * 0.42, y: h * 0.24))
            path.addLine(to: CGPoint(x: w * 0.52, y: h * 0.34))
            path.addLine(to: CGPoint(x: w * 0.86, y: h * 0.34))
            path.addLine(to: CGPoint(x: w * 0.86, y: h * 0.78))
            path.addLine(to: CGPoint(x: w * 0.14, y: h * 0.78))
            path.closeSubpath()

        case .spaceWork:
            let body = CGRect(x: w * 0.14, y: h * 0.32, width: w * 0.72, height: h * 0.54)
            path.addRoundedRect(in: body, cornerSize: CGSize(width: 4, height: 4))
            path.move(to: CGPoint(x: w * 0.34, y: h * 0.32))
            path.addLine(to: CGPoint(x: w * 0.34, y: h * 0.18))
            path.addLine(to: CGPoint(x: w * 0.66, y: h * 0.18))
            path.addLine(to: CGPoint(x: w * 0.66, y: h * 0.32))
            path.move(to: CGPoint(x: w * 0.14, y: h * 0.54))
            path.addLine(to: CGPoint(x: w * 0.86, y: h * 0.54))

        case .spaceStudy:
            path.move(to: CGPoint(x: w * 0.50, y: h * 0.26))
            path.addQuadCurve(to: CGPoint(x: w * 0.14, y: h * 0.22), control: CGPoint(x: w * 0.32, y: h * 0.24))
            path.addLine(to: CGPoint(x: w * 0.14, y: h * 0.74))
            path.addQuadCurve(to: CGPoint(x: w * 0.50, y: h * 0.78), control: CGPoint(x: w * 0.32, y: h * 0.76))
            path.closeSubpath()

            path.move(to: CGPoint(x: w * 0.50, y: h * 0.26))
            path.addQuadCurve(to: CGPoint(x: w * 0.86, y: h * 0.22), control: CGPoint(x: w * 0.68, y: h * 0.24))
            path.addLine(to: CGPoint(x: w * 0.86, y: h * 0.74))
            path.addQuadCurve(to: CGPoint(x: w * 0.50, y: h * 0.78), control: CGPoint(x: w * 0.68, y: h * 0.76))
            path.closeSubpath()

        case .spaceCode:
            path.move(to: CGPoint(x: w * 0.32, y: h * 0.30))
            path.addLine(to: CGPoint(x: w * 0.16, y: h * 0.50))
            path.addLine(to: CGPoint(x: w * 0.32, y: h * 0.70))

            path.move(to: CGPoint(x: w * 0.68, y: h * 0.30))
            path.addLine(to: CGPoint(x: w * 0.84, y: h * 0.50))
            path.addLine(to: CGPoint(x: w * 0.68, y: h * 0.70))

            path.move(to: CGPoint(x: w * 0.56, y: h * 0.22))
            path.addLine(to: CGPoint(x: w * 0.44, y: h * 0.78))

        case .spacePrivate:
            path.addEllipse(in: CGRect(x: w * 0.32, y: h * 0.08, width: w * 0.36, height: h * 0.36))
            path.move(to: CGPoint(x: w * 0.08, y: h * 0.52))
            path.addQuadCurve(to: CGPoint(x: w * 0.92, y: h * 0.52), control: CGPoint(x: w * 0.50, y: h * 0.40))
            path.addLine(to: CGPoint(x: w * 0.92, y: h * 0.62))
            path.addQuadCurve(to: CGPoint(x: w * 0.08, y: h * 0.62), control: CGPoint(x: w * 0.50, y: h * 0.70))
            path.closeSubpath()
            path.addRoundedRect(in: CGRect(x: w * 0.20, y: h * 0.68, width: w * 0.24, height: h * 0.14), cornerSize: CGSize(width: 4, height: 4))
            path.addRoundedRect(in: CGRect(x: w * 0.56, y: h * 0.68, width: w * 0.24, height: h * 0.14), cornerSize: CGSize(width: 4, height: 4))

        case .spaceStar:
            let center = CGPoint(x: w * 0.5, y: h * 0.5)
            let points = 5
            let rOuter = min(w, h) * 0.40
            let rInner = rOuter * 0.44
            for i in 0..<(points * 2) {
                let radius = (i % 2 == 0) ? rOuter : rInner
                let angle = (Double(i) * .pi / Double(points)) - (.pi / 2.0)
                let pt = CGPoint(x: center.x + radius * CGFloat(cos(angle)), y: center.y + radius * CGFloat(sin(angle)))
                if i == 0 {
                    path.move(to: pt)
                } else {
                    path.addLine(to: pt)
                }
            }
            path.closeSubpath()

        case .pin:
            path.move(to: CGPoint(x: w * 0.34, y: h * 0.16))
            path.addLine(to: CGPoint(x: w * 0.66, y: h * 0.16))
            path.move(to: CGPoint(x: w * 0.50, y: h * 0.16))
            path.addLine(to: CGPoint(x: w * 0.50, y: h * 0.34))
            path.move(to: CGPoint(x: w * 0.26, y: h * 0.34))
            path.addLine(to: CGPoint(x: w * 0.74, y: h * 0.34))
            path.addLine(to: CGPoint(x: w * 0.62, y: h * 0.66))
            path.addLine(to: CGPoint(x: w * 0.38, y: h * 0.66))
            path.closeSubpath()
            path.move(to: CGPoint(x: w * 0.50, y: h * 0.66))
            path.addLine(to: CGPoint(x: w * 0.50, y: h * 0.90))

        case .moveSpace:
            path.addRoundedRect(in: CGRect(x: w * 0.14, y: h * 0.22, width: w * 0.52, height: h * 0.62), cornerSize: CGSize(width: 4, height: 4))
            path.move(to: CGPoint(x: w * 0.46, y: h * 0.46))
            path.addLine(to: CGPoint(x: w * 0.86, y: h * 0.46))
            path.move(to: CGPoint(x: w * 0.72, y: h * 0.32))
            path.addLine(to: CGPoint(x: w * 0.86, y: h * 0.46))
            path.addLine(to: CGPoint(x: w * 0.72, y: h * 0.60))

        case .readerMode:
            let lines: [(CGFloat, CGFloat)] = [
                (0.24, 0.56),
                (0.42, 0.72),
                (0.58, 0.72),
                (0.74, 0.48)
            ]
            for (yPos, widthFactor) in lines {
                path.move(to: CGPoint(x: w * 0.14, y: h * yPos))
                path.addLine(to: CGPoint(x: w * (0.14 + widthFactor), y: h * yPos))
            }

        case .zoomIn:
            let cx = w * 0.42
            let cy = h * 0.42
            let r = w * 0.26
            path.addEllipse(in: CGRect(x: cx - r, y: cy - r, width: r * 2, height: r * 2))
            path.move(to: CGPoint(x: cx + r * 0.70, y: cy + r * 0.70))
            path.addLine(to: CGPoint(x: w * 0.84, y: h * 0.84))
            path.move(to: CGPoint(x: cx, y: cy - r * 0.55))
            path.addLine(to: CGPoint(x: cx, y: cy + r * 0.55))
            path.move(to: CGPoint(x: cx - r * 0.55, y: cy))
            path.addLine(to: CGPoint(x: cx + r * 0.55, y: cy))

        case .zoomOut:
            let cx = w * 0.42
            let cy = h * 0.42
            let r = w * 0.26
            path.addEllipse(in: CGRect(x: cx - r, y: cy - r, width: r * 2, height: r * 2))
            path.move(to: CGPoint(x: cx + r * 0.70, y: cy + r * 0.70))
            path.addLine(to: CGPoint(x: w * 0.84, y: h * 0.84))
            path.move(to: CGPoint(x: cx - r * 0.55, y: cy))
            path.addLine(to: CGPoint(x: cx + r * 0.55, y: cy))

        case .desktopMode:
            path.addRoundedRect(
                in: CGRect(x: w * 0.12, y: h * 0.16, width: w * 0.76, height: h * 0.52),
                cornerSize: CGSize(width: 4, height: 4)
            )
            path.move(to: CGPoint(x: w * 0.50, y: h * 0.68))
            path.addLine(to: CGPoint(x: w * 0.50, y: h * 0.84))
            path.move(to: CGPoint(x: w * 0.32, y: h * 0.84))
            path.addLine(to: CGPoint(x: w * 0.68, y: h * 0.84))

        case .mobileMode:
            path.addRoundedRect(
                in: CGRect(x: w * 0.26, y: h * 0.10, width: w * 0.48, height: h * 0.80),
                cornerSize: CGSize(width: 8, height: 8)
            )
            path.move(to: CGPoint(x: w * 0.42, y: h * 0.18))
            path.addLine(to: CGPoint(x: w * 0.58, y: h * 0.18))
            path.addEllipse(in: CGRect(x: w * 0.45, y: h * 0.78, width: w * 0.10, height: h * 0.08))

        case .qrCode:
            let cellSize = w * 0.30
            let corner = CGSize(width: 3, height: 3)
            path.addRoundedRect(in: CGRect(x: w * 0.10, y: h * 0.10, width: cellSize, height: cellSize), cornerSize: corner)
            path.addRoundedRect(in: CGRect(x: w * 0.60, y: h * 0.10, width: cellSize, height: cellSize), cornerSize: corner)
            path.addRoundedRect(in: CGRect(x: w * 0.10, y: h * 0.60, width: cellSize, height: cellSize), cornerSize: corner)
            path.addRect(CGRect(x: w * 0.60, y: h * 0.60, width: w * 0.12, height: h * 0.12))
            path.addRect(CGRect(x: w * 0.78, y: h * 0.78, width: w * 0.12, height: h * 0.12))
            path.addRect(CGRect(x: w * 0.44, y: h * 0.44, width: w * 0.12, height: h * 0.12))

        case .download:
            path.move(to: CGPoint(x: w * 0.50, y: h * 0.14))
            path.addLine(to: CGPoint(x: w * 0.50, y: h * 0.66))
            path.move(to: CGPoint(x: w * 0.28, y: h * 0.46))
            path.addLine(to: CGPoint(x: w * 0.50, y: h * 0.66))
            path.addLine(to: CGPoint(x: w * 0.72, y: h * 0.46))
            path.move(to: CGPoint(x: w * 0.16, y: h * 0.82))
            path.addLine(to: CGPoint(x: w * 0.84, y: h * 0.82))

        case .history:
            let cx = rect.midX
            let cy = rect.midY
            let r = min(w, h) * 0.40
            path.addEllipse(in: CGRect(x: cx - r, y: cy - r, width: r * 2, height: r * 2))
            path.move(to: CGPoint(x: cx, y: cy - r * 0.65))
            path.addLine(to: CGPoint(x: cx, y: cy))
            path.addLine(to: CGPoint(x: cx + r * 0.50, y: cy))

        case .bookmark:
            path.move(to: CGPoint(x: w * 0.22, y: h * 0.10))
            path.addLine(to: CGPoint(x: w * 0.78, y: h * 0.10))
            path.addLine(to: CGPoint(x: w * 0.78, y: h * 0.88))
            path.addLine(to: CGPoint(x: w * 0.50, y: h * 0.68))
            path.addLine(to: CGPoint(x: w * 0.22, y: h * 0.88))
            path.closeSubpath()

        case .bookmarkFilled:
            path.move(to: CGPoint(x: w * 0.22, y: h * 0.10))
            path.addLine(to: CGPoint(x: w * 0.78, y: h * 0.10))
            path.addLine(to: CGPoint(x: w * 0.78, y: h * 0.88))
            path.addLine(to: CGPoint(x: w * 0.50, y: h * 0.68))
            path.addLine(to: CGPoint(x: w * 0.22, y: h * 0.88))
            path.closeSubpath()

        case .settings:
            let cx = rect.midX
            let cy = rect.midY
            let rOuter = min(w, h) * 0.40
            let rInner = rOuter * 0.48
            let teeth = 8
            for i in 0..<teeth {
                let baseAngle = (Double(i) * 2.0 * .pi / Double(teeth))
                let step = (.pi / Double(teeth)) * 0.45
                let a0 = baseAngle - step
                let a1 = baseAngle + step
                let pt0 = CGPoint(x: cx + rOuter * CGFloat(cos(a0)), y: cy + rOuter * CGFloat(sin(a0)))
                let pt1 = CGPoint(x: cx + rOuter * CGFloat(cos(a1)), y: cy + rOuter * CGFloat(sin(a1)))
                if i == 0 {
                    path.move(to: pt0)
                } else {
                    path.addLine(to: pt0)
                }
                path.addLine(to: pt1)
                let nextBase = (Double(i + 1) * 2.0 * .pi / Double(teeth))
                let aNext0 = nextBase - step
                let rRoot = rOuter * 0.80
                let ptRoot1 = CGPoint(x: cx + rRoot * CGFloat(cos(a1)), y: cy + rRoot * CGFloat(sin(a1)))
                let ptRoot2 = CGPoint(x: cx + rRoot * CGFloat(cos(aNext0)), y: cy + rRoot * CGFloat(sin(aNext0)))
                path.addLine(to: ptRoot1)
                path.addLine(to: ptRoot2)
            }
            path.closeSubpath()
            path.addEllipse(in: CGRect(x: cx - rInner, y: cy - rInner, width: rInner * 2, height: rInner * 2))

        case .trash:
            path.move(to: CGPoint(x: w * 0.20, y: h * 0.26))
            path.addLine(to: CGPoint(x: w * 0.80, y: h * 0.26))
            path.move(to: CGPoint(x: w * 0.36, y: h * 0.26))
            path.addLine(to: CGPoint(x: w * 0.36, y: h * 0.16))
            path.addLine(to: CGPoint(x: w * 0.64, y: h * 0.16))
            path.addLine(to: CGPoint(x: w * 0.64, y: h * 0.26))
            path.move(to: CGPoint(x: w * 0.26, y: h * 0.26))
            path.addLine(to: CGPoint(x: w * 0.30, y: h * 0.86))
            path.addLine(to: CGPoint(x: w * 0.70, y: h * 0.86))
            path.addLine(to: CGPoint(x: w * 0.74, y: h * 0.26))
            path.move(to: CGPoint(x: w * 0.42, y: h * 0.38))
            path.addLine(to: CGPoint(x: w * 0.42, y: h * 0.74))
            path.move(to: CGPoint(x: w * 0.58, y: h * 0.38))
            path.addLine(to: CGPoint(x: w * 0.58, y: h * 0.74))

        case .copy:
            let corner = CGSize(width: 4, height: 4)
            path.addRoundedRect(in: CGRect(x: w * 0.26, y: h * 0.26, width: w * 0.58, height: h * 0.62), cornerSize: corner)
            path.move(to: CGPoint(x: w * 0.16, y: h * 0.66))
            path.addLine(to: CGPoint(x: w * 0.16, y: h * 0.14))
            path.addLine(to: CGPoint(x: w * 0.66, y: h * 0.14))

        case .check:
            path.move(to: CGPoint(x: w * 0.18, y: h * 0.52))
            path.addLine(to: CGPoint(x: w * 0.40, y: h * 0.74))
            path.addLine(to: CGPoint(x: w * 0.82, y: h * 0.26))

        case .chevronDown:
            path.move(to: CGPoint(x: w * 0.22, y: h * 0.36))
            path.addLine(to: CGPoint(x: w * 0.50, y: h * 0.64))
            path.addLine(to: CGPoint(x: w * 0.78, y: h * 0.36))

        case .chevronUp:
            path.move(to: CGPoint(x: w * 0.22, y: h * 0.64))
            path.addLine(to: CGPoint(x: w * 0.50, y: h * 0.36))
            path.addLine(to: CGPoint(x: w * 0.78, y: h * 0.64))

        case .sliderAdjust:
            path.move(to: CGPoint(x: w * 0.16, y: h * 0.30))
            path.addLine(to: CGPoint(x: w * 0.84, y: h * 0.30))
            path.addEllipse(in: CGRect(x: w * 0.30, y: h * 0.20, width: w * 0.20, height: h * 0.20))
            path.move(to: CGPoint(x: w * 0.16, y: h * 0.70))
            path.addLine(to: CGPoint(x: w * 0.84, y: h * 0.70))
            path.addEllipse(in: CGRect(x: w * 0.54, y: h * 0.60, width: w * 0.20, height: h * 0.20))

        case .burnSession:
            path.move(to: CGPoint(x: w * 0.50, y: h * 0.12))
            path.addQuadCurve(to: CGPoint(x: w * 0.78, y: h * 0.52), control: CGPoint(x: w * 0.82, y: h * 0.28))
            path.addQuadCurve(to: CGPoint(x: w * 0.50, y: h * 0.88), control: CGPoint(x: w * 0.76, y: h * 0.84))
            path.addQuadCurve(to: CGPoint(x: w * 0.22, y: h * 0.52), control: CGPoint(x: w * 0.24, y: h * 0.84))
            path.addQuadCurve(to: CGPoint(x: w * 0.50, y: h * 0.12), control: CGPoint(x: w * 0.18, y: h * 0.28))
            path.closeSubpath()
            path.move(to: CGPoint(x: w * 0.50, y: h * 0.42))
            path.addQuadCurve(to: CGPoint(x: w * 0.64, y: h * 0.62), control: CGPoint(x: w * 0.66, y: h * 0.50))
            path.addQuadCurve(to: CGPoint(x: w * 0.50, y: h * 0.78), control: CGPoint(x: w * 0.60, y: h * 0.76))
            path.addQuadCurve(to: CGPoint(x: w * 0.36, y: h * 0.62), control: CGPoint(x: w * 0.40, y: h * 0.76))
            path.addQuadCurve(to: CGPoint(x: w * 0.50, y: h * 0.42), control: CGPoint(x: w * 0.34, y: h * 0.50))
            path.closeSubpath()

        case .faceID:
            let bracket = w * 0.22
            path.move(to: CGPoint(x: w * 0.12, y: h * (0.12 + bracket)))
            path.addLine(to: CGPoint(x: w * 0.12, y: h * 0.12))
            path.addLine(to: CGPoint(x: w * (0.12 + bracket), y: h * 0.12))

            path.move(to: CGPoint(x: w * (0.88 - bracket), y: h * 0.12))
            path.addLine(to: CGPoint(x: w * 0.88, y: h * 0.12))
            path.addLine(to: CGPoint(x: w * 0.88, y: h * (0.12 + bracket)))

            path.move(to: CGPoint(x: w * 0.12, y: h * (0.88 - bracket)))
            path.addLine(to: CGPoint(x: w * 0.12, y: h * 0.88))
            path.addLine(to: CGPoint(x: w * (0.12 + bracket), y: h * 0.88))

            path.move(to: CGPoint(x: w * (0.88 - bracket), y: h * 0.88))
            path.addLine(to: CGPoint(x: w * 0.88, y: h * 0.88))
            path.addLine(to: CGPoint(x: w * 0.88, y: h * (0.88 - bracket)))

            path.addEllipse(in: CGRect(x: w * 0.34, y: h * 0.38, width: w * 0.08, height: h * 0.08))
            path.addEllipse(in: CGRect(x: w * 0.58, y: h * 0.38, width: w * 0.08, height: h * 0.08))

            path.move(to: CGPoint(x: w * 0.50, y: h * 0.46))
            path.addLine(to: CGPoint(x: w * 0.50, y: h * 0.56))
            path.addLine(to: CGPoint(x: w * 0.44, y: h * 0.56))

            path.move(to: CGPoint(x: w * 0.36, y: h * 0.66))
            path.addQuadCurve(to: CGPoint(x: w * 0.64, y: h * 0.66), control: CGPoint(x: w * 0.50, y: h * 0.74))
        }

        return path
    }
}

public struct LiquidIconView: View {
    public var type: LiquidIconType
    public var size: CGFloat
    public var color: Color?
    public var lineWidth: CGFloat

    @Environment(\.colorScheme) private var colorScheme

    public init(
        _ type: LiquidIconType,
        size: CGFloat = 20,
        color: Color? = nil,
        lineWidth: CGFloat = 1.5
    ) {
        self.type = type
        self.size = size
        self.color = color
        self.lineWidth = lineWidth
    }

    public var body: some View {
        let tint = color ?? (colorScheme == .dark ? Color.white : Color.black)
        let strokeStyle = StrokeStyle(lineWidth: lineWidth, lineCap: .round, lineJoin: .round)

        Group {
            if type == .bookmarkFilled {
                LiquidIconShape(type)
                    .fill(tint)
            } else {
                LiquidIconShape(type)
                    .stroke(tint, style: strokeStyle)
            }
        }
        .frame(width: size, height: size)
        .contentShape(Rectangle())
    }
}
