import SwiftUI

struct TimerDisplayView: View {
    @Bindable var timer: TimerModel
    @EnvironmentObject var timerEngine: TimerEngine
    @EnvironmentObject var themeManager: ThemeManager
    @AppStorage("timerFontName") private var fontName = "SF Mono"

    var body: some View {
        ZStack {
            CircularProgressView(
                totalSeconds: timer.totalSeconds,
                remainingSeconds: timer.remainingSeconds,
                isRunning: timer.isRunning,
                isFinished: timer.status == .finished,
                themeManager: themeManager
            )
            .frame(width: 140, height: 140)

            VStack(spacing: 4) {
                Text(timer.displayTime)
                    .font(.custom(fontName, size: displayFontSize).bold())
                    .foregroundStyle(timeColor)
                    .shadow(color: timeColor.opacity(0.6), radius: 6)
                    .shadow(color: timeColor.opacity(0.3), radius: 12)
                    .contentTransition(.numericText())

                Text(statusLabel)
                    .font(.caption)
                    .foregroundStyle(themeManager.secondary)
            }
        }
        .animation(.easeInOut(duration: 0.3), value: timer.status)
    }

    private var timeColor: Color {
        switch timer.status {
        case .finished: return .red
        case .running:  return themeManager.accent
        default:        return themeManager.primary
        }
    }

    private var displayFontSize: CGFloat {
        let chars = max(CGFloat(timer.displayTime.count), 4)
        let innerDiameter: CGFloat = 140 * 0.88
        let sideMargin: CGFloat = 140 * 0.025
        let availableWidth = innerDiameter - sideMargin * 2
        return min(availableWidth / (chars * 0.62), 32)
    }

    private var statusLabel: String {
        switch timer.status {
        case .running:  return "运行中"
        case .paused:   return "已暂停"
        case .finished: return "已完成"
        case .idle:     return "就绪"
        }
    }
}
