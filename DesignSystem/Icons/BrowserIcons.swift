import SwiftUI

// MARK: - Pestañas

struct TabsIcon: Shape {
    var count: Int = 1
    func path(in rect: CGRect) -> Path {
        var p = Path()
        let w = rect.width, h = rect.height
        let r = CGSize(width: 5, height: 5)
        if count > 1 {
            p.addRoundedRect(in: .init(x: w*0.20, y: h*0.08, width: w*0.72, height: h*0.70), cornerSize: r)
        }
        p.addRoundedRect(in: .init(x: w*0.08, y: h*0.22, width: w*0.72, height: h*0.70), cornerSize: r)
        return p
    }
}

// MARK: - Candado

struct LockIcon: Shape {
    var isOpen: Bool = false
    func path(in rect: CGRect) -> Path {
        var p = Path()
        let w = rect.width, h = rect.height
        // Cuerpo
        p.addRoundedRect(
            in: .init(x: w*0.17, y: h*0.46, width: w*0.66, height: h*0.46),
            cornerSize: .init(width: 7, height: 7)
        )
        // Arco
        let cx = w * 0.50, cy = h * 0.41, r = w * 0.22
        if isOpen {
            p.addArc(center: .init(x: cx + r * 0.9, y: cy),
                     radius: r, startAngle: .degrees(185),
                     endAngle: .degrees(355), clockwise: false)
        } else {
            p.addArc(center: .init(x: cx, y: cy),
                     radius: r, startAngle: .degrees(180),
                     endAngle: .degrees(0), clockwise: true)
        }
        // Agujero de llave
        p.addEllipse(in: .init(x: cx - w*0.08, y: h*0.57, width: w*0.16, height: w*0.16))
        p.move(to: .init(x: cx, y: h*0.675)); p.addLine(to: .init(x: cx, y: h*0.80))
        return p
    }
}

// MARK: - Marcador (bandera)

struct BookmarkIcon: Shape {
    var filled: Bool = false
    func path(in rect: CGRect) -> Path {
        var p = Path()
        let w = rect.width, h = rect.height
        p.move(to:    .init(x: w*0.20, y: h*0.07))
        p.addLine(to: .init(x: w*0.80, y: h*0.07))
        p.addLine(to: .init(x: w*0.80, y: h*0.90))
        p.addLine(to: .init(x: w*0.50, y: h*0.70))
        p.addLine(to: .init(x: w*0.20, y: h*0.90))
        p.closeSubpath()
        return p
    }
}

// MARK: - Incógnito (capucha)

struct PrivateIcon: Shape {
    func path(in rect: CGRect) -> Path {
        var p = Path()
        let w = rect.width, h = rect.height
        // Cabeza
        p.addEllipse(in: .init(x: w*0.30, y: h*0.06, width: w*0.40, height: h*0.36))
        // Ala del sombrero
        p.move(to: .init(x: w*0.04, y: h*0.52))
        p.addQuadCurve(to: .init(x: w*0.96, y: h*0.52), control: .init(x: w*0.50, y: h*0.42))
        p.addLine(to: .init(x: w*0.96, y: h*0.62))
        p.addQuadCurve(to: .init(x: w*0.04, y: h*0.62), control: .init(x: w*0.50, y: h*0.70))
        p.closeSubpath()
        // Ojos
        p.addRoundedRect(in: .init(x: w*0.20, y: h*0.70, width: w*0.24, height: h*0.13),
                         cornerSize: .init(width: 4, height: 4))
        p.addRoundedRect(in: .init(x: w*0.56, y: h*0.70, width: w*0.24, height: h*0.13),
                         cornerSize: .init(width: 4, height: 4))
        return p
    }
}

// MARK: - Plus

struct PlusIcon: Shape {
    func path(in rect: CGRect) -> Path {
        var p = Path()
        let cx = rect.midX, cy = rect.midY
        let arm = min(rect.width, rect.height) * 0.37
        p.move(to: .init(x: cx, y: cy - arm)); p.addLine(to: .init(x: cx, y: cy + arm))
        p.move(to: .init(x: cx - arm, y: cy)); p.addLine(to: .init(x: cx + arm, y: cy))
        return p
    }
}

// MARK: - Historial (reloj analógico)

struct HistoryIcon: Shape {
    func path(in rect: CGRect) -> Path {
        var p = Path()
        let cx = rect.midX, cy = rect.midY
        let r  = min(rect.width, rect.height) * 0.43
        p.addEllipse(in: .init(x: cx - r, y: cy - r, width: r*2, height: r*2))
        // Manecilla de las 12 → 11
        p.move(to: .init(x: cx, y: cy))
        p.addLine(to: .init(x: cx - r*0.32, y: cy - r*0.52))
        // Manecilla de los 3
        p.move(to: .init(x: cx, y: cy))
        p.addLine(to: .init(x: cx + r*0.56, y: cy))
        return p
    }
}

// MARK: - Descargas (flecha abajo + bandeja)

struct DownloadIcon: Shape {
    func path(in rect: CGRect) -> Path {
        var p = Path()
        let w = rect.width, h = rect.height
        // Fuste
        p.move(to:    .init(x: w*0.50, y: h*0.10))
        p.addLine(to: .init(x: w*0.50, y: h*0.68))
        // Punta
        p.move(to:    .init(x: w*0.26, y: h*0.46))
        p.addLine(to: .init(x: w*0.50, y: h*0.68))
        p.addLine(to: .init(x: w*0.74, y: h*0.46))
        // Bandeja
        p.move(to:    .init(x: w*0.12, y: h*0.82))
        p.addLine(to: .init(x: w*0.88, y: h*0.82))
        return p
    }
}

// MARK: - Globo terráqueo

struct GlobeIcon: Shape {
    func path(in rect: CGRect) -> Path {
        var p = Path()
        let cx = rect.midX, cy = rect.midY
        let r  = min(rect.width, rect.height) * 0.46
        p.addEllipse(in: .init(x: cx-r, y: cy-r, width: r*2, height: r*2))
        // Meridiano central
        p.addEllipse(in: .init(x: cx - r*0.42, y: cy - r, width: r*0.84, height: r*2))
        // Paralelos
        for yo in [-0.38, 0.38] as [Double] {
            let hw = r * sqrt(1 - yo*yo)
            p.move(to:    .init(x: cx - hw, y: cy + r*yo))
            p.addLine(to: .init(x: cx + hw, y: cy + r*yo))
        }
        return p
    }
}

// MARK: - Vista BrowserIconView

struct BrowserIconView: View {
    enum Icon {
        case tabs(Int), lock(Bool), bookmark(Bool)
        case `private`, plus, history, download, globe
    }

    let icon:      Icon
    var size:      CGFloat = 22
    var color:     Color   = .primary
    var lineWidth: CGFloat = 2.0

    var body: some View {
        let stroke = StrokeStyle(lineWidth: lineWidth, lineCap: .round, lineJoin: .round)
        Group {
            switch icon {
            case .tabs(let n):
                TabsIcon(count: n).stroke(color, style: stroke)
            case .lock(let open):
                LockIcon(isOpen: open).stroke(color, style: stroke)
            case .bookmark(let filled):
                if filled { BookmarkIcon(filled: true).fill(color) }
                else      { BookmarkIcon().stroke(color, style: stroke) }
            case .private:
                PrivateIcon().stroke(color, style: .init(lineWidth: lineWidth - 0.3,
                                                          lineCap: .round, lineJoin: .round))
            case .plus:
                PlusIcon().stroke(color, style: .init(lineWidth: lineWidth + 0.2, lineCap: .round))
            case .history:
                HistoryIcon().stroke(color, style: .init(lineWidth: lineWidth, lineCap: .round))
            case .download:
                DownloadIcon().stroke(color, style: stroke)
            case .globe:
                GlobeIcon().stroke(color, style: .init(lineWidth: lineWidth - 0.2, lineCap: .round))
            }
        }
        .frame(width: size, height: size)
    }
}
