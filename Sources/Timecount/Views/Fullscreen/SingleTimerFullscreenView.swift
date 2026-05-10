import SwiftUI
import SwiftData
import AppKit

struct SingleTimerFullscreenView: View {
    let timerID: UUID
    var onClose: (() -> Void)?
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject var timerEngine: TimerEngine
    @EnvironmentObject var themeManager: ThemeManager
    @AppStorage("timerFontName") private var fontName = "LiquidCrystal"

    @State private var timer: TimerModel?

    var body: some View {
        GeometryReader { geometry in
            let safeW = geometry.size.width - 80
            let safeH = geometry.size.height - 120
            let ringSize = min(safeW * 0.55, safeH * 0.55, 480)
            let timerText = timer?.displayTime ?? ""
            let charCount = max(CGFloat(timerText.count), 4)
            let innerDiameter = ringSize * 0.88
            let sideMargin = ringSize * 0.025
            let availableWidth = innerDiameter - sideMargin * 2
            let timeFontSize = availableWidth / (charCount * 0.62)

            ZStack {
                // Background
                fullscreenBackground
                    .ignoresSafeArea()

                // Grid overlay
                CyberGridBackground(
                    lineColor: effectiveAccent.opacity(0.05),
                    lineSpacing: 60
                )
                .ignoresSafeArea()

                if let timer = timer {
                    VStack(spacing: 0) {
                        Spacer(minLength: 60)

                        // Brand label
                        HStack(spacing: 8) {
                            Circle()
                                .fill(effectiveAccent)
                                .frame(width: 6, height: 6)
                                .shadow(color: effectiveAccent.opacity(0.8), radius: 4)
                            Text("TIMECOUNT")
                                .font(.system(size: 12, weight: .bold, design: .monospaced))
                                .foregroundStyle(effectiveAccent.opacity(0.6))
                        }
                        .padding(.bottom, 24)

                        // Timer name
                        Text(timer.name)
                            .font(.system(size: min(timeFontSize * 0.9, 56), weight: .medium, design: .monospaced))
                            .foregroundStyle(
                                timer.textColorHex.isEmpty
                                ? themeManager.primary
                                : Color(hex: timer.textColorHex)
                            )
                            .padding(.bottom, ringSize * 0.1)

                        // Main timer ring
                        ZStack {
                            CircularProgressView(
                                totalSeconds: timer.totalSeconds,
                                remainingSeconds: timer.remainingSeconds,
                                isRunning: timer.isRunning,
                                isFinished: timer.status == .finished,
                                themeManager: themeManager,
                                customAccentColorHex: timer.accentColorHex,
                                outerLineWidth: 18
                            )
                            .frame(width: ringSize, height: ringSize)
                            .overlay(
                                CyberCornerDecoration(
                                    color: effectiveAccent.opacity(0.2),
                                    lineWidth: 1
                                )
                                .scaleEffect(1.15)
                            )

                            VStack(spacing: 6) {
                                Text(timer.displayTime)
                                    .font(.custom(fontName, size: timeFontSize).bold())
                                    .foregroundStyle(timeColor)
                                    .shadow(color: timeColor.opacity(0.5), radius: timeFontSize * 0.15)
                                    .shadow(color: timeColor.opacity(0.2), radius: timeFontSize * 0.3)
                                    .contentTransition(.numericText())

                                Text(statusText(timer))
                                    .font(.custom("AaXiaoGouGuaiGuaiXiangSuTi-2", size: timeFontSize * 0.2))
                                    .foregroundStyle(
                                        timer.textColorHex.isEmpty
                                        ? themeManager.secondary
                                        : Color(hex: timer.textColorHex).opacity(0.7)
                                    )
                                    .padding(.top, 4)
                            }
                        }

                        Spacer(minLength: ringSize * 0.12)

                        // Controls
                        HStack(spacing: 40) {
                            Button(action: { togglePlayPause(timer) }) {
                                ZStack {
                                    Circle()
                                        .fill(effectiveAccent.opacity(0.08))
                                        .frame(width: 64, height: 64)
                                        .overlay(
                                            Circle()
                                                .strokeBorder(effectiveAccent.opacity(0.3), lineWidth: 1)
                                        )
                                    Image(systemName: playPauseIcon(timer))
                                        .font(.system(size: 24, weight: .bold))
                                        .foregroundStyle(effectiveAccent)
                                }
                            }
                            .buttonStyle(.plain)

                            Button(action: { timerEngine.reset(timer: timer) }) {
                                ZStack {
                                    Circle()
                                        .fill(effectiveSecondary.opacity(0.05))
                                        .frame(width: 52, height: 52)
                                        .overlay(
                                            Circle()
                                                .strokeBorder(effectiveSecondary.opacity(0.2), lineWidth: 1)
                                        )
                                    Image(systemName: "arrow.counterclockwise")
                                        .font(.system(size: 18))
                                        .foregroundStyle(effectiveSecondary.opacity(0.7))
                                }
                            }
                            .buttonStyle(.plain)
                            .disabled(timer.status == .idle)
                        }
                        .padding(.vertical, 20)

                        // Session info
                        HStack(spacing: 32) {
                            statItem(
                                label: "总时长",
                                value: TimeInterval.formatCompact(timer.totalSeconds)
                            )
                            statItem(
                                label: "剩余",
                                value: TimeInterval.formatCompact(timer.remainingSeconds)
                            )
                            statItem(
                                label: "进度",
                                value: "\(Int(timer.progress * 100))%"
                            )
                        }
                        .padding(.horizontal, 32)
                        .padding(.vertical, 14)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.white.opacity(0.02))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .strokeBorder(effectiveAccent.opacity(0.1), lineWidth: 0.5)
                                )
                        )

                        Spacer(minLength: 60)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    Text("未找到计时器")
                        .font(.custom("AaXiaoGouGuaiGuaiXiangSuTi-2", size: 18))
                        .foregroundStyle(.secondary)
                }

                // Close button top-right
                VStack {
                    HStack {
                        Spacer()
                        Button {
                            onClose?()
                        } label: {
                            ZStack {
                                Circle()
                                    .fill(Color.white.opacity(0.05))
                                    .frame(width: 36, height: 36)
                                Image(systemName: "xmark")
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundStyle(themeManager.secondary.opacity(0.7))
                            }
                        }
                        .buttonStyle(.plain)
                        .padding(28)
                    }
                    Spacer()
                }
            }
        }
        .onAppear {
            refreshTimer()
        }
        .onChange(of: timerEngine.tickCounter) { _, _ in
            refreshTimer()
        }
        .onReceive(Timer.publish(every: 2, on: .main, in: .common).autoconnect()) { _ in
            refreshTimer()
        }
    }

    private var effectiveAccent: Color {
        guard let hex = timer?.accentColorHex, !hex.isEmpty else {
            return themeManager.accent
        }
        return Color(hex: hex)
    }

    private var effectiveSecondary: Color {
        guard let hex = timer?.textColorHex, !hex.isEmpty else {
            return themeManager.secondary
        }
        return Color(hex: hex)
    }

    private var timeColor: Color {
        guard let timer = timer else { return themeManager.primary }
        let customAccent = timer.accentColorHex.isEmpty
            ? themeManager.accent
            : Color(hex: timer.accentColorHex)
        switch timer.status {
        case .finished:
            return timer.accentColorHex.isEmpty ? .red : customAccent
        case .running:  return customAccent
        default:        return effectiveSecondary
        }
    }

    private var fullscreenBackground: Color {
        guard let hex = timer?.backgroundColorHex, !hex.isEmpty else {
            return themeManager.bg
        }
        return Color(hex: hex)
    }

    private func statItem(label: String, value: String) -> some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.system(size: 14, weight: .semibold, design: .monospaced))
                .foregroundStyle(effectiveAccent.opacity(0.9))
            Text(label)
                .font(.custom("AaXiaoGouGuaiGuaiXiangSuTi-2", size: 10))
                .foregroundStyle(effectiveSecondary.opacity(0.6))
        }
    }

    private func refreshTimer() {
        var descriptor = FetchDescriptor<TimerModel>()
        descriptor.fetchLimit = 1
        descriptor.predicate = #Predicate { $0.id == timerID }
        timer = try? modelContext.fetch(descriptor).first
    }

    private func statusText(_ timer: TimerModel) -> String {
        switch timer.status {
        case .running:  return "运行中"
        case .paused:   return "已暂停"
        case .finished: return "已完成"
        case .idle:     return "就绪"
        }
    }

    private func togglePlayPause(_ timer: TimerModel) {
        switch timer.status {
        case .running:
            timerEngine.pause(timer: timer)
        case .finished:
            timerEngine.pause(timer: timer)
        default:
            timerEngine.start(timer: timer)
        }
    }

    private func playPauseIcon(_ timer: TimerModel) -> String {
        switch timer.status {
        case .running:  return "pause.fill"
        case .finished: return "stop.fill"
        default:        return "play.fill"
        }
    }
}
