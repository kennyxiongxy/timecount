import SwiftUI
import SwiftData

struct ThemeCustomizationView: View {
    @Bindable var theme: ThemeConfiguration
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject var themeManager: ThemeManager

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("自定义主题")
                    .font(.custom("AaXiaoGouGuaiGuaiXiangSuTi-2", size: 20))
                    .padding(.bottom, 8)

                colorSection("背景色", hex: $theme.backgroundColorHex)
                colorSection("卡片背景色", hex: $theme.cardBackgroundColorHex)
                colorSection("卡片边框色", hex: $theme.cardBorderColorHex)
                colorSection("主文字色", hex: $theme.primaryTextColorHex)
                colorSection("次文字色", hex: $theme.secondaryTextColorHex)
                colorSection("强调色", hex: $theme.accentColorHex)

                Divider()

                Group {
                    Text("发光效果").font(.custom("AaXiaoGouGuaiGuaiXiangSuTi-2", size: 13))
                    colorSection("发光颜色", hex: $theme.glowColorHex)

                    HStack {
                        Text("发光半径: \(Int(theme.glowRadius))")
                        Slider(value: $theme.glowRadius, in: 0...40)
                    }

                    HStack {
                        Text("发光强度: \(Int(theme.glowOpacity * 100))%")
                        Slider(value: $theme.glowOpacity, in: 0...1)
                    }
                }

                Divider()

                Group {
                    Text("特效").font(.custom("AaXiaoGouGuaiGuaiXiangSuTi-2", size: 13))
                    Toggle("CRT 扫描线", isOn: $theme.useScanlines)
                    Toggle("粒子效果", isOn: $theme.useParticleEffect)
                }

                Divider()

                HStack {
                    Button("取消", role: .cancel) { dismiss() }
                    Spacer()
                    Button("应用") {
                        themeManager.applyTheme(theme)
                        try? modelContext.save()
                        dismiss()
                    }
                    .buttonStyle(.borderedProminent)
                }
                .padding(.top)
            }
            .padding()
        }
        .frame(width: 400, height: 600)
    }

    private func colorSection(_ label: String, hex: Binding<String>) -> some View {
        HStack {
            Text(label).frame(width: 120, alignment: .leading)
            ColorPicker("", selection: Binding(
                get: { Color(hex: hex.wrappedValue) },
                set: { hex.wrappedValue = $0.toHex() }
            ))
            TextField("#", text: hex)
                .font(.caption.monospaced())
                .frame(width: 80)
                .textFieldStyle(.roundedBorder)
        }
    }
}
