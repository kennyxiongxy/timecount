import SwiftUI

struct ScanlineOverlay: View {
    let lineSpacing: CGFloat
    let opacity: Double

    init(lineSpacing: CGFloat = 4, opacity: Double = 0.03) {
        self.lineSpacing = lineSpacing
        self.opacity = opacity
    }

    var body: some View {
        Canvas { context, size in
            var y: CGFloat = 0
            while y < size.height {
                var path = Path()
                path.move(to: CGPoint(x: 0, y: y))
                path.addLine(to: CGPoint(x: size.width, y: y))
                context.stroke(path, with: .color(.white.opacity(opacity)), lineWidth: 1)
                y += lineSpacing
            }
        }
        .allowsHitTesting(false)
    }
}
