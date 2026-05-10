import SwiftUI
import SwiftData
import AppKit

struct SingleTimerFullscreenView: View {
    let timerID: UUID
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject var timerEngine: TimerEngine
    @EnvironmentObject var themeManager: ThemeManager
    @AppStorage("timerFontName") private var fontName = "SF Mono"

    var body: some View {
        GeometryReader { geometry in
            let safeW = geometry.size.width - 80
            let safeH = geometry.size.height - 120
            let ringSize = min(safeW * 0.65, safeH * 0.6, 550)
            let timerText = fetchTimer()?.displayTime ?? ""
            let charCount = max(CGFloat(timerText.count), 4)
            let innerDiameter = ringSize * 0.88
            let sideMargin = ringSize * 0.025
            let availableWidth = innerDiameter - sideMargin * 2
            let timeFontSize = availableWidth / (charCount * 0.62)

            ZStack {
                themeManager.bg
                    .ignoresSafeArea()

                if let timer = fetchTimer() {
                    VStack(spacing: 0) {
                        Spacer(minLength: 40)

                        Text(timer.name)
                            .font(.system(size: min(timeFontSize * 1.3, 96), weight: .medium))
                            .foregroundStyle(themeManager.primary)
                            .padding(.bottom, ringSize * 0.12)

                        ZStack {
                            CircularProgressView(
                                totalSeconds: timer.totalSeconds,
                                remainingSeconds: timer.remainingSeconds,
                                isRunning: timer.isRunning,
                                isFinished: timer.status == .finished,
                                themeManager: themeManager,
                                outerLineWidth: 16
                            )
                            .frame(width: ringSize, height: ringSize)

                            VStack(spacing: 4) {
                                Text(timer.displayTime)
                                    .font(.custom(fontName, size: timeFontSize).bold())
                                    .foregroundStyle(
                                        timer.status == .finished ? .red :
                                        timer.isRunning ? themeManager.accent : themeManager.primary
                                    )
                                    .shadow(color: (timer.isRunning ? themeManager.accent : themeManager.primary).opacity(0.4), radius: timeFontSize * 0.12)

                                Text(statusText(timer))
                                    .font(.system(size: timeFontSize * 0.22))
                                    .foregroundStyle(themeManager.secondary)
                            }
                        }

                        Spacer(minLength: ringSize * 0.15)

                        // Controls always visible
                        HStack(spacing: 50) {
                            Button(action: { togglePlayPause(timer) }) {
                                Image(systemName: playPauseIcon(timer))
                                    .font(.system(size: min(timeFontSize * 0.7, 48)))
                            }
                            .buttonStyle(.plain)
                            .foregroundStyle(themeManager.accent)

                            Button(action: { timerEngine.reset(timer: timer) }) {
                                Image(systemName: "arrow.counterclockwise")
                                    .font(.system(size: min(timeFontSize * 0.55, 40)))
                            }
                            .buttonStyle(.plain)
                            .foregroundStyle(themeManager.secondary)
                        }
                        .padding(.vertical, 16)
                        .padding(.horizontal, 32)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(.ultraThinMaterial)
                        )

                        Spacer(minLength: 40)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    Text("未找到计时器")
                        .foregroundStyle(.secondary)
                }

                // Close button top-right
                VStack {
                    HStack {
                        Spacer()
                        Button {
                            NSApp.keyWindow?.close()
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .font(.system(size: 28))
                                .foregroundStyle(.secondary)
                        }
                        .buttonStyle(.plain)
                        .padding(24)
                    }
                    Spacer()
                }
            }
        }
    }

    private func statusText(_ timer: TimerModel) -> String {
        switch timer.status {
        case .running:  return "运行中"
        case .paused:   return "已暂停"
        case .finished: return "已完成"
        case .idle:     return "就绪"
        }
    }

    private func fetchTimer() -> TimerModel? {
        var descriptor = FetchDescriptor<TimerModel>()
        descriptor.fetchLimit = 1
        descriptor.predicate = #Predicate { $0.id == timerID }
        return try? modelContext.fetch(descriptor).first
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
