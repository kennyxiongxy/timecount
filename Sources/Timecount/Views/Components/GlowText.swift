import SwiftUI

struct GlowText: View {
    let text: String
    let font: Font
    let color: Color
    let glowColor: Color
    let glowRadius: CGFloat

    init(_ text: String,
         font: Font = .body,
         color: Color = .primary,
         glowColor: Color = .purple,
         glowRadius: CGFloat = 8) {
        self.text = text
        self.font = font
        self.color = color
        self.glowColor = glowColor
        self.glowRadius = glowRadius
    }

    var body: some View {
        Text(text)
            .font(font)
            .foregroundStyle(color)
            .shadow(color: glowColor.opacity(0.8), radius: glowRadius / 3)
            .shadow(color: glowColor.opacity(0.5), radius: glowRadius / 2)
            .shadow(color: glowColor, radius: glowRadius)
    }
}
