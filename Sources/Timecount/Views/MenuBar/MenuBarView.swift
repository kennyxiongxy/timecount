import SwiftUI
import SwiftData
import AppKit

struct MenuBarView: View {
    @Query(filter: #Predicate<Preset> { $0.showInMenuBar == true },
           sort: \Preset.sortOrder) private var menuPresets: [Preset]

    @EnvironmentObject var timerEngine: TimerEngine
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var windowManager: WindowManager
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        if !menuPresets.isEmpty {
            Text("预设时长")
                .font(.custom("AaXiaoGouGuaiGuaiXiangSuTi-2", size: 10))
                .foregroundStyle(.secondary)

            ForEach(menuPresets) { preset in
                Button(action: { createAndOpenTimer(from: preset) }) {
                    HStack {
                        Text(preset.name)
                        Spacer()
                        Text(TimeInterval.formatCompact(preset.totalSeconds))
                            .font(.system(size: 11, design: .monospaced))
                            .foregroundStyle(.secondary)
                    }
                }
            }

            Divider()
        }

        Button("退出 Timecount") {
            NSApplication.shared.terminate(nil)
        }
    }

    private func createAndOpenTimer(from preset: Preset) {
        let timer = TimerModel(
            name: preset.name,
            totalSeconds: preset.totalSeconds,
            sortOrder: 0
        )
        if !themeManager.activeTheme.cardBackgroundColorHex.isEmpty {
            timer.backgroundColorHex = themeManager.activeTheme.cardBackgroundColorHex
        }
        modelContext.insert(timer)
        try? modelContext.save()

        timerEngine.start(timer: timer)
        windowManager.openFullscreen(for: timer.id, modelContext: modelContext)
    }
}
