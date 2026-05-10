import SwiftUI

struct SciFiButtonStyle: ButtonStyle {
    let accentColor: Color

    init(accentColor: Color = Color(hex: "#FF00FF")) {
        self.accentColor = accentColor
    }

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(accentColor.opacity(configuration.isPressed ? 0.3 : 0.15))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(accentColor.opacity(configuration.isPressed ? 1.0 : 0.5), lineWidth: 1)
            )
            .shadow(color: accentColor.opacity(configuration.isPressed ? 0.8 : 0.3), radius: configuration.isPressed ? 8 : 4)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.15), value: configuration.isPressed)
    }
}
