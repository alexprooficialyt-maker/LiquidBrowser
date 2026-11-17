import SwiftUI

// MARK: - Compartir (flecha hacia arriba desde plataforma)

struct ShareIcon: Shape {
    func path(in rect: CGRect) -> Path {
        var p = Path()
        let w = rect.width, h = rect.height
        // Plataforma inferior
        p.move(to:    .init(x: w * 0.18, y: h * 0.57))
        p.addLine(to: .init(x: w * 0.18, y: h * 0.86))
        p.addLine(to: .init(x: w * 0.82, y: h * 0.86))
        p.addLine(to: .init(x: w * 0.82, y: h * 0.57))
        // Fuste de la flecha
        p.move(to:    .init(x: w * 0.50, y: h * 0.63))
        p.addLine(to: .init(x: w * 0.50, y: h * 0.14))
        // Cabeza de la flecha
        p.move(to:    .init(x: w * 0.27, y: h * 0.37))
        p.addLine(to: .init(x: w * 0.50, y: h * 0.14))
        p.addLine(to: .init(x: w * 0.73, y: h * 0.37))
        return p
    }
}

// MARK: - Ajustes (engranaje de 8 dientes proporcional)

struct SettingsIcon: Shape {
    func path(in rect: CGRect) -> Path {
        var p = Path()
        let cx = rect.midX, cy = rect.midY
        let R  = min(rect.width, rect.height) * 0.42   // radio exterior
        let r  = R * 0.56                               // radio interior (hueco)
        let n  = 8                                      // número de dientes

        for i in 0..<n {
            let baseAngle = Double(i) * (2 * .pi / Double(n))
            let halfTooth = (.pi / Double(n)) * 0.52

            let a0 = baseAngle - halfTooth
            let a1 = baseAngle + halfTooth

            let outerPad = R * 0.86                     // radio de la raíz del diente

            if i == 0 {
                p.move(to: pt(cx, cy, R, a0))
            } else {
                p.addLine(to: pt(cx, cy, R, a0))
            }
            p.addLine(to: pt(cx, cy, R, a1))
            // Raíz entre dientes (arco corto a radio interno)
            let aN = baseAngle + (.pi / Double(n))
            p.addLine(to: pt(cx, cy, outerPad, a1 + 0.1))
            p.addLine(to: pt(cx, cy, outerPad, aN - 0.1))
        }
        p.closeSubpath()

        // Hueco central circular
        p.addEllipse(in: CGRect(x: cx - r, y: cy - r, width: r * 2, height: r * 2))
        return p
    }

    private func pt(_ cx: CGFloat, _ cy: CGFloat, _ radius: CGFloat, _ angle: Double) -> CGPoint {
        .init(x: cx + radius * cos(angle), y: cy + radius * sin(angle))
    }
}

// MARK: - Modo Lectura (renglones de texto)

struct ReaderIcon: Shape {
    func path(in rect: CGRect) -> Path {
        var p = Path()
        let w = rect.width, h = rect.height
        let lx = w * 0.16
        let widths: [Double] = [1.0, 0.82, 1.0, 0.68]
        for (i, wf) in widths.enumerated() {
            let y = h * (0.22 + Double(i) * 0.19)
            p.move(to:    .init(x: lx,                y: y))
            p.addLine(to: .init(x: lx + w * 0.68 * wf, y: y))
        }
        return p
    }
}

// MARK: - QR (patrón esquemático de tres esquinas + datos)

struct QRIcon: Shape {
    func path(in rect: CGRect) -> Path {
        var p = Path()
        let w = rect.width, h = rect.height
        let cell  = w * 0.30
        let inner = cell * 0.46
        let cs3   = CGSize(width: 3, height: 3)
        let cs2   = CGSize(width: 2, height: 2)

        func corner(_ x: CGFloat, _ y: CGFloat) {
            p.addRoundedRect(in: .init(x: x, y: y, width: cell,  height: cell),  cornerSize: cs3)
            p.addRoundedRect(in: .init(x: x + (cell - inner)/2, y: y + (cell - inner)/2,
                                       width: inner, height: inner), cornerSize: cs2)
        }

        corner(w * 0.08, h * 0.08)   // esquina superior izquierda
        corner(w * 0.62, h * 0.08)   // esquina superior derecha
        corner(w * 0.08, h * 0.62)   // esquina inferior izquierda

        // Datos: pequeños cuadrados en zona central/derecha
        for (dx, dy) in [(0.62, 0.62), (0.76, 0.62), (0.62, 0.76), (0.70, 0.70)] as [(Double, Double)] {
            p.addRoundedRect(
                in: .init(x: w * dx, y: h * dy, width: w * 0.10, height: h * 0.10),
                cornerSize: cs2
            )
        }
        return p
    }
}

// MARK: - Vista

struct ToolIconView: View {
    enum Icon { case share, settings, reader, qr }
    let icon:      Icon
    var size:      CGFloat = 22
    var color:     Color   = .primary
    var lineWidth: CGFloat = 2.0

    var body: some View {
        let stroke = StrokeStyle(lineWidth: lineWidth, lineCap: .round, lineJoin: .round)
        Group {
            switch icon {
            case .share:
                ShareIcon().stroke(color, style: stroke)
            case .settings:
                SettingsIcon().stroke(color, style: .init(lineWidth: lineWidth - 0.3, lineCap: .round))
            case .reader:
                ReaderIcon().stroke(color, style: .init(lineWidth: lineWidth, lineCap: .round))
            case .qr:
                QRIcon().stroke(color, style: .init(lineWidth: lineWidth - 0.3, lineCap: .round, lineJoin: .round))
            }
        }
        .frame(width: size, height: size)
    }
}
