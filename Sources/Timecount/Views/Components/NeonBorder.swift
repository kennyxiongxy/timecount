import SwiftUI

struct NeonBorder: ViewModifier {
    let color: Color
    let radius: CGFloat
    let lineWidth: CGFloat

    func body(content: Content) -> some View {
        content
            .overlay(
                RoundedRectangle(cornerRadius: radius)
                    .stroke(color, lineWidth: lineWidth)
                    .shadow(color: color.opacity(0.8), radius: 4)
                    .shadow(color: color.opacity(0.4), radius: 8)
            )
    }
}

extension View {
    func neonBorder(color: Color, cornerRadius: CGFloat = 16, lineWidth: CGFloat = 1.5) -> some View {
        modifier(NeonBorder(color: color, radius: cornerRadius, lineWidth: lineWidth))
    }
}
