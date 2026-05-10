import SwiftUI

struct ThemePreviewCard: View {
    let theme: ThemeConfiguration
    let isSelected: Bool
    let onSelect: () -> Void

    var body: some View {
        Button(action: onSelect) {
            VStack(spacing: 8) {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color(hex: theme.cardBackgroundColorHex))
                    .frame(height: 60)
                    .overlay(
                        Text("12:34")
                            .font(.system(size: 20, weight: .bold, design: .monospaced))
                            .foregroundStyle(Color(hex: theme.primaryTextColorHex))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .strokeBorder(
                                isSelected ? Color(hex: theme.accentColorHex) : Color.gray.opacity(0.3),
                                lineWidth: isSelected ? 2 : 1
                            )
                    )

                Text(theme.name)
                    .font(.caption)
                    .foregroundStyle(isSelected ? Color(hex: theme.accentColorHex) : .secondary)
            }
        }
        .buttonStyle(.plain)
    }
}
