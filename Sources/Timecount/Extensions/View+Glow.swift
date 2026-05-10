import SwiftUI

struct NeonGlowModifier: ViewModifier {
    let color: Color
    let radius: CGFloat

    func body(content: Content) -> some View {
        content
            .shadow(color: color.opacity(0.8), radius: radius / 3)
            .shadow(color: color.opacity(0.6), radius: radius / 2)
            .shadow(color: color, radius: radius)
    }
}

extension View {
    func neonGlow(color: Color, radius: CGFloat = 12) -> some View {
        modifier(NeonGlowModifier(color: color, radius: radius))
    }
}
