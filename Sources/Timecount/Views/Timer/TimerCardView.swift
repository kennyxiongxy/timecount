import SwiftUI
import SwiftData

struct TimerCardView: View {
    @Bindable var timer: TimerModel
    @EnvironmentObject var timerEngine: TimerEngine
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var windowManager: WindowManager
    @EnvironmentObject var soundManager: SoundManager
    @Environment(\.modelContext) private var modelContext
    @State private var editedName: String
    @State private var showColorPopover = false

    init(timer: TimerModel) {
        self.timer = timer
        _editedName = State(initialValue: timer.name)
    }

    var body: some View {
        ZStack(alignment: .topTrailing) {
            VStack(spacing: 12) {
                // Name field — always editable
                TextField("计时器名称", text: $editedName, onCommit: commitName)
                    .textFieldStyle(.plain)
                    .font(.headline)
                    .foregroundStyle(
                        timer.textColorHex.isEmpty
                        ? themeManager.primary
                        : Color(hex: timer.textColorHex)
                    )
                    .multilineTextAlignment(.center)

                TimerDisplayView(
                    timer: timer,
                    customTextColorHex: timer.textColorHex,
                    customAccentColorHex: timer.accentColorHex
                )

                TimeInputView(timer: timer)

                TimerControlsView(
                    timer: timer,
                    customAccentColorHex: timer.accentColorHex
                )
            }
            .padding(16)

            // Config + Delete buttons — top-right corner
            HStack(spacing: 4) {
                Button(action: { showColorPopover = true }) {
                    Image(systemName: "paintpalette")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(
                            timer.textColorHex.isEmpty
                            ? themeManager.secondary.opacity(0.7)
                            : Color(hex: timer.textColorHex).opacity(0.7)
                        )
                        .frame(width: 22, height: 22)
                }
                .buttonStyle(.plain)
                .help("自定义卡片颜色")

                Button(action: deleteTimer) {
                    Image(systemName: "xmark")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(
                            timer.textColorHex.isEmpty
                            ? themeManager.primary
                            : Color(hex: timer.textColorHex)
                        )
                        .frame(width: 22, height: 22)
                }
                .buttonStyle(.plain)
            }
            .padding(6)
        }
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(timer.backgroundColorHex.isEmpty
                      ? themeManager.cardBg
                      : Color(hex: timer.backgroundColorHex))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .strokeBorder(
                    timer.accentColorHex.isEmpty
                    ? themeManager.cardBorder.opacity(0.4)
                    : Color(hex: timer.accentColorHex).opacity(0.4),
                    lineWidth: 1
                )
        )
        .shadow(
            color: (timer.accentColorHex.isEmpty
                    ? themeManager.glow.opacity(0.15)
                    : Color(hex: timer.accentColorHex).opacity(0.15)),
            radius: 8
        )
        .simultaneousGesture(
            TapGesture(count: 2).onEnded {
                windowManager.openFullscreen(for: timer.id, modelContext: modelContext)
            }
        )
        .contextMenu {
            Button("复制", action: duplicateTimer)
            Divider()
            Button("删除", role: .destructive, action: deleteTimer)
        }
        .popover(isPresented: $showColorPopover, arrowEdge: .top) {
            CardColorPickerView(
                backgroundColorHex: $timer.backgroundColorHex,
                textColorHex: $timer.textColorHex,
                accentColorHex: $timer.accentColorHex
            )
        }
    }

    private func commitName() {
        let trimmed = editedName.trimmingCharacters(in: .whitespaces)
        if !trimmed.isEmpty {
            timer.name = trimmed
            try? modelContext.save()
        } else {
            editedName = timer.name
        }
    }

    private func duplicateTimer() {
        let newTimer = TimerModel(
            name: "\(timer.name) 副本",
            totalSeconds: timer.totalSeconds,
            sortOrder: timer.sortOrder + 1
        )
        modelContext.insert(newTimer)
        try? modelContext.save()
    }

    private func deleteTimer() {
        if timer.status == .running {
            timerEngine.pause(timer: timer)
        }
        if timer.status == .finished {
            soundManager.stopEndSound()
        }
        windowManager.closeFullscreen(for: timer.id)
        modelContext.delete(timer)
        try? modelContext.save()
    }
}
