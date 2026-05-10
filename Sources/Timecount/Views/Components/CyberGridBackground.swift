import SwiftUI

struct CyberGridBackground: View {
    var lineColor: Color = Color(hex: "#00FF41").opacity(0.08)
    var lineSpacing: CGFloat = 40

    var body: some View {
        GeometryReader { geometry in
            let w = geometry.size.width
            let h = geometry.size.height

            Canvas { context, size in
                // Horizontal lines
                var y: CGFloat = 0
                while y < h {
                    var path = Path()
                    path.move(to: CGPoint(x: 0, y: y))
                    path.addLine(to: CGPoint(x: w, y: y))
                    context.stroke(path, with: .color(lineColor), lineWidth: 0.5)
                    y += lineSpacing
                }

                // Vertical lines
                var x: CGFloat = 0
                while x < w {
                    var path = Path()
                    path.move(to: CGPoint(x: x, y: 0))
                    path.addLine(to: CGPoint(x: x, y: h))
                    context.stroke(path, with: .color(lineColor), lineWidth: 0.5)
                    x += lineSpacing
                }
            }
        }
        .allowsHitTesting(false)
    }
}

struct CyberCornerDecoration: View {
    var color: Color = Color(hex: "#00FF41").opacity(0.3)
    var lineWidth: CGFloat = 1

    var body: some View {
        GeometryReader { geometry in
            let w = geometry.size.width
            let h = geometry.size.height
            let cornerLength: CGFloat = 12

            Canvas { context, size in
                // Top-left
                var tl1 = Path()
                tl1.move(to: CGPoint(x: 0, y: cornerLength))
                tl1.addLine(to: CGPoint(x: 0, y: 0))
                tl1.addLine(to: CGPoint(x: cornerLength, y: 0))
                context.stroke(tl1, with: .color(color), lineWidth: lineWidth)

                // Top-right
                var tr1 = Path()
                tr1.move(to: CGPoint(x: w - cornerLength, y: 0))
                tr1.addLine(to: CGPoint(x: w, y: 0))
                tr1.addLine(to: CGPoint(x: w, y: cornerLength))
                context.stroke(tr1, with: .color(color), lineWidth: lineWidth)

                // Bottom-left
                var bl1 = Path()
                bl1.move(to: CGPoint(x: 0, y: h - cornerLength))
                bl1.addLine(to: CGPoint(x: 0, y: h))
                bl1.addLine(to: CGPoint(x: cornerLength, y: h))
                context.stroke(bl1, with: .color(color), lineWidth: lineWidth)

                // Bottom-right
                var br1 = Path()
                br1.move(to: CGPoint(x: w - cornerLength, y: h))
                br1.addLine(to: CGPoint(x: w, y: h))
                br1.addLine(to: CGPoint(x: w, y: h - cornerLength))
                context.stroke(br1, with: .color(color), lineWidth: lineWidth)
            }
        }
        .allowsHitTesting(false)
    }
}
