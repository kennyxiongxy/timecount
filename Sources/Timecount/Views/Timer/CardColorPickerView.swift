import SwiftUI

struct CardColorPickerView: View {
    @Binding var backgroundColorHex: String
    @Binding var textColorHex: String
    @Binding var accentColorHex: String
    @EnvironmentObject var themeManager: ThemeManager
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("卡片颜色")
                .font(.headline)
                .foregroundStyle(.primary)

            colorRow(label: "背景色", hex: $backgroundColorHex,
                     fallback: themeManager.cardBg)
            colorRow(label: "文字/时间色", hex: $textColorHex,
                     fallback: themeManager.primary)
            colorRow(label: "进度环色", hex: $accentColorHex,
                     fallback: themeManager.accent)

            Divider()

            HStack {
                Button("重置为默认") {
                    backgroundColorHex = ""
                    textColorHex = ""
                    accentColorHex = ""
                }
                .font(.caption)
                Spacer()
                Button("完成") {
                    dismiss()
                }
                .buttonStyle(.borderedProminent)
                .font(.caption)
            }
        }
        .padding()
        .frame(width: 280)
    }

    private func colorRow(label: String, hex: Binding<String>,
                          fallback: Color) -> some View {
        HStack(spacing: 8) {
            Text(label)
                .frame(width: 80, alignment: .leading)
                .font(.system(size: 12))
                .foregroundStyle(.primary)

            ColorPicker("", selection: Binding(
                get: { hex.wrappedValue.isEmpty ? fallback : Color(hex: hex.wrappedValue) },
                set: { hex.wrappedValue = $0.toHex() }
            ))
            .labelsHidden()

            TextField("#", text: hex)
                .font(.caption.monospaced())
                .frame(width: 60)
                .textFieldStyle(.roundedBorder)

            Circle()
                .fill(hex.wrappedValue.isEmpty
                      ? fallback.opacity(0.5)
                      : Color(hex: hex.wrappedValue))
                .frame(width: 14, height: 14)
                .overlay(Circle().stroke(Color.white.opacity(0.2), lineWidth: 1))
        }
    }
}
