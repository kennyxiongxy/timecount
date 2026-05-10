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

    private var cardBg: Color {
        timer.backgroundColorHex.isEmpty
            ? themeManager.cardBg
            : Color(hex: timer.backgroundColorHex)
    }

    private var cardBorderColor: Color {
        timer.accentColorHex.isEmpty
            ? themeManager.cardBorder.opacity(0.5)
            : Color(hex: timer.accentColorHex).opacity(0.5)
    }

    private var textColor: Color {
        timer.textColorHex.isEmpty
            ? themeManager.primary
            : Color(hex: timer.textColorHex)
    }

    private var accentColor: Color {
        timer.accentColorHex.isEmpty
            ? themeManager.accent
            : Color(hex: timer.accentColorHex)
    }

    private var secondaryColor: Color {
        timer.textColorHex.isEmpty
            ? themeManager.secondary
            : Color(hex: timer.textColorHex).opacity(0.7)
    }

    var body: some View {
        ZStack(alignment: .topTrailing) {
            VStack(spacing: 8) {
                // Header: icon + name only (status moved to timer display)
                HStack(spacing: 8) {
                    Image(systemName: iconForTimer)
                        .font(.system(size: 11))
                        .foregroundStyle(accentColor.opacity(0.7))

                    TextField("计时器名称", text: $editedName, onCommit: commitName)
                        .textFieldStyle(.plain)
                        .font(.custom("AaXiaoGouGuaiGuaiXiangSuTi-2", size: 13))
                        .foregroundStyle(textColor)

                    Spacer()
                }

                // Timer display with circular progress — double tap here for fullscreen
                TimerDisplayView(
                    timer: timer,
                    customTextColorHex: timer.textColorHex,
                    customAccentColorHex: timer.accentColorHex
                )

                // Time adjustment input
                TimeInputView(timer: timer)

                // Controls row
                HStack(spacing: 16) {
                    Button(action: togglePlayPause) {
                        HStack(spacing: 4) {
                            Image(systemName: playPauseIcon)
                                .font(.system(size: 11, weight: .bold))
                            Text(playPauseLabel)
                                .font(.custom("AaXiaoGouGuaiGuaiXiangSuTi-2", size: 11))
                        }
                        .foregroundStyle(accentColor)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 5)
                        .background(
                            RoundedRectangle(cornerRadius: 6)
                                .fill(accentColor.opacity(0.08))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 6)
                                .strokeBorder(accentColor.opacity(0.3), lineWidth: 0.5)
                        )
                    }
                    .buttonStyle(.plain)
                    .disabled(timer.totalSeconds == 0)

                    Spacer()

                    HStack(spacing: 10) {
                        Button(action: { timerEngine.reset(timer: timer) }) {
                            Image(systemName: "arrow.counterclockwise")
                                .font(.system(size: 12))
                                .foregroundStyle(secondaryColor.opacity(0.8))
                        }
                        .buttonStyle(.plain)
                        .disabled(timer.status == .idle)

                        Button(action: toggleFullscreen) {
                            Image(systemName: windowManager.isFullscreenOpen(for: timer.id)
                                  ? "arrow.down.right.and.arrow.up.left"
                                  : "arrow.up.left.and.arrow.down.right")
                                .font(.system(size: 12))
                                .foregroundStyle(secondaryColor.opacity(0.8))
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .padding(12)

            // Config + Delete buttons — top-right corner
            HStack(spacing: 4) {
                Button(action: { showColorPopover = true }) {
                    Image(systemName: "paintpalette")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(secondaryColor.opacity(0.6))
                        .frame(width: 22, height: 22)
                }
                .buttonStyle(.plain)
                .help("自定义卡片颜色")

                Button(action: deleteTimer) {
                    Image(systemName: "xmark")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(textColor.opacity(0.5))
                        .frame(width: 22, height: 22)
                }
                .buttonStyle(.plain)
            }
            .padding(8)
        }
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(cardBg)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .strokeBorder(cardBorderColor, lineWidth: 1)
        )
        .shadow(
            color: (timer.accentColorHex.isEmpty
                    ? themeManager.glow.opacity(0.1)
                    : Color(hex: timer.accentColorHex).opacity(0.1)),
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

    private var iconForTimer: String {
        let name = timer.name.lowercased()
        if name.contains("work") || name.contains("工作") { return "briefcase.fill" }
        if name.contains("study") || name.contains("学习") { return "book.fill" }
        if name.contains("exercise") || name.contains("运动") { return "figure.run" }
        if name.contains("read") || name.contains("阅读") { return "eyeglasses" }
        if name.contains("break") || name.contains("休息") { return "cup.and.saucer.fill" }
        return "timer"
    }

    private var statusDotColor: Color {
        switch timer.status {
        case .finished: return .red
        case .running:  return accentColor
        case .paused:   return .orange
        case .idle:     return secondaryColor
        }
    }

    private var statusLabelShort: String {
        switch timer.status {
        case .running:  return "运行中"
        case .paused:   return "已暂停"
        case .finished: return "已完成"
        case .idle:     return "就绪"
        }
    }

    private func chineseFont(size: CGFloat) -> Font {
        .custom("AaXiaoGouGuaiGuaiXiangSuTi-2", size: size)
    }

    private var playPauseIcon: String {
        switch timer.status {
        case .running: return "pause.fill"
        case .finished: return "stop.fill"
        default: return "play.fill"
        }
    }

    private var playPauseLabel: String {
        switch timer.status {
        case .running: return "暂停"
        case .finished: return "停止"
        default: return "开始"
        }
    }

    private func togglePlayPause() {
        switch timer.status {
        case .running:
            timerEngine.pause(timer: timer)
        case .finished:
            timerEngine.pause(timer: timer)
        default:
            timerEngine.start(timer: timer)
        }
    }

    private func toggleFullscreen() {
        if windowManager.isFullscreenOpen(for: timer.id) {
            windowManager.closeFullscreen(for: timer.id)
        } else {
            windowManager.openFullscreen(for: timer.id, modelContext: modelContext)
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
