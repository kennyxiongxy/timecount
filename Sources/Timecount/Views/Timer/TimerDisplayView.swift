import SwiftUI

struct TimerDisplayView: View {
    @Bindable var timer: TimerModel
    @EnvironmentObject var timerEngine: TimerEngine
    @EnvironmentObject var themeManager: ThemeManager
    @AppStorage("timerFontName") private var fontName = "LiquidCrystal"
    var customTextColorHex: String = ""
    var customAccentColorHex: String = ""

    var body: some View {
        ZStack {
            CircularProgressView(
                totalSeconds: timer.totalSeconds,
                remainingSeconds: timer.remainingSeconds,
                isRunning: timer.isRunning,
                isFinished: timer.status == .finished,
                themeManager: themeManager,
                customAccentColorHex: customAccentColorHex
            )
            .frame(width: 120, height: 120)

            VStack(spacing: 4) {
                Text(timer.displayTime)
                    .font(.custom(fontName, size: displayFontSize).bold())
                    .foregroundStyle(timeColor)
                    .shadow(color: timeColor.opacity(0.6), radius: 6)
                    .shadow(color: timeColor.opacity(0.3), radius: 12)
                    .contentTransition(.numericText())

                HStack(spacing: 5) {
                    Circle()
                        .fill(statusColor)
                        .frame(width: 5, height: 5)
                    Text(statusLabel)
                        .font(.custom("AaXiaoGouGuaiGuaiXiangSuTi-2", size: 11))
                        .foregroundStyle(
                            customTextColorHex.isEmpty
                            ? themeManager.secondary
                            : Color(hex: customTextColorHex).opacity(0.7)
                        )
                }
            }
        }
        .animation(.easeInOut(duration: 0.3), value: timer.status)
    }

    private var timeColor: Color {
        let effAccent = customAccentColorHex.isEmpty
            ? themeManager.accent
            : Color(hex: customAccentColorHex)
        let effPrimary = customTextColorHex.isEmpty
            ? themeManager.primary
            : Color(hex: customTextColorHex)

        switch timer.status {
        case .finished:
            return customAccentColorHex.isEmpty ? .red : effAccent
        case .running:  return effAccent
        default:        return effPrimary
        }
    }

    private var displayFontSize: CGFloat {
        let chars = max(CGFloat(timer.displayTime.count), 4)
        let innerDiameter: CGFloat = 120 * 0.88
        let sideMargin: CGFloat = 120 * 0.025
        let availableWidth = innerDiameter - sideMargin * 2
        return min(availableWidth / (chars * 0.62), 28)
    }

    private var statusLabel: String {
        switch timer.status {
        case .running:  return "运行中"
        case .paused:   return "已暂停"
        case .finished: return "已完成"
        case .idle:     return "就绪"
        }
    }

    private var statusColor: Color {
        let effAccent = customAccentColorHex.isEmpty
            ? themeManager.accent
            : Color(hex: customAccentColorHex)

        switch timer.status {
        case .finished:
            return customAccentColorHex.isEmpty ? .red : effAccent
        case .running:  return effAccent
        case .paused:   return .orange
        case .idle:     return customTextColorHex.isEmpty
            ? themeManager.secondary
            : Color(hex: customTextColorHex).opacity(0.7)
        }
    }
}
