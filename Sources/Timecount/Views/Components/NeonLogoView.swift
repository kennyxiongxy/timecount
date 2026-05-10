import SwiftUI

struct NeonLogoView: View {
    var body: some View {
        HStack(spacing: 6) {
            neonText("TIME", colors: [Color(hex: "#FF2D95"), Color(hex: "#FF6BCD")])
            neonText("COUNT", colors: [Color(hex: "#00E5FF"), Color(hex: "#0080FF")])
        }
        .frame(maxWidth: .infinity, alignment: .center)
    }

    private func neonText(_ text: String, colors: [Color]) -> some View {
        Text(text)
            .font(.system(size: 28, weight: .black, design: .monospaced))
            .foregroundStyle(.clear)
            .overlay(
                Text(text)
                    .font(.system(size: 28, weight: .black, design: .monospaced))
                    .foregroundStyle(
                        LinearGradient(
                            colors: colors,
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
            )
            .shadow(color: colors[0].opacity(0.7), radius: 6)
            .shadow(color: colors[0].opacity(0.4), radius: 12)
            .shadow(color: colors[1].opacity(0.3), radius: 20)
    }
}
