import SwiftUI

// MARK: - Atrás

struct BackIcon: Shape {
    func path(in rect: CGRect) -> Path {
        var p = Path()
        let w = rect.width, h = rect.height
        // Trazo en chevron limpio, proporcionado
        p.move(to: .init(x: w * 0.65, y: h * 0.16))
        p.addLine(to: .init(x: w * 0.26, y: h * 0.50))
        p.addLine(to: .init(x: w * 0.65, y: h * 0.84))
        return p
    }
}

// MARK: - Adelante

struct ForwardIcon: Shape {
    func path(in rect: CGRect) -> Path {
        var p = Path()
        let w = rect.width, h = rect.height
        p.move(to: .init(x: w * 0.35, y: h * 0.16))
        p.addLine(to: .init(x: w * 0.74, y: h * 0.50))
        p.addLine(to: .init(x: w * 0.35, y: h * 0.84))
        return p
    }
}

// MARK: - Recargar

struct ReloadIcon: Shape {
    func path(in rect: CGRect) -> Path {
        var p = Path()
        let cx = rect.midX, cy = rect.midY
        let r:  CGFloat = min(rect.width, rect.height) * 0.37

        // Arco de ~290 grados (antihorario)
        p.addArc(
            center:     .init(x: cx, y: cy),
            radius:     r,
            startAngle: .degrees(-55),
            endAngle:   .degrees(215),
            clockwise:  false
        )

        // Punta de flecha en el inicio del arco
        let startRad: CGFloat = CGFloat(-55) * .pi / 180
        let tx = cx + r * cos(startRad)
        let ty = cy + r * sin(startRad)
        let as_: CGFloat = r * 0.44
        p.move(to:    .init(x: tx - as_ * 0.28, y: ty - as_))
        p.addLine(to: .init(x: tx,              y: ty))
        p.addLine(to: .init(x: tx + as_,        y: ty - as_ * 0.28))
        return p
    }
}

// MARK: - Stop

struct StopIcon: Shape {
    func path(in rect: CGRect) -> Path {
        var p = Path()
        let pad: CGFloat = rect.width * 0.26
        p.addRoundedRect(
            in:         rect.insetBy(dx: pad, dy: pad),
            cornerSize: .init(width: 4, height: 4)
        )
        return p
    }
}

// MARK: - Vista

struct NavIconView: View {
    enum Icon { case back, forward, reload, stop }
    let icon:            Icon
    var size:            CGFloat = 22
    var color:           Color   = .primary
    var lineWidth:       CGFloat = 2.2

    var body: some View {
        let s = StrokeStyle(lineWidth: lineWidth, lineCap: .round, lineJoin: .round)
        Group {
            switch icon {
            case .back:    BackIcon().stroke(color, style: s)
            case .forward: ForwardIcon().stroke(color, style: s)
            case .reload:  ReloadIcon().stroke(color, style: s)
            case .stop:    StopIcon().stroke(color, style: s)
            }
        }
        .frame(width: size, height: size)
    }
}
