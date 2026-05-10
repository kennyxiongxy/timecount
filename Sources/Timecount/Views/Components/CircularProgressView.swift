import SwiftUI

struct CircularProgressView: View {
    let totalSeconds: Int
    let remainingSeconds: Int
    let isRunning: Bool
    let isFinished: Bool
    var themeManager: ThemeManager?
    var customAccentColorHex: String = ""
    var outerLineWidth: CGFloat = 8
    var innerLineWidth: CGFloat = 5

    private var totalMinutes: Int { (totalSeconds + 59) / 60 }
    private var remainingMinutes: Int { (remainingSeconds + 59) / 60 }
    private var minuteProgress: Double {
        guard totalMinutes > 0 else { return 0 }
        return Double(remainingMinutes) / Double(totalMinutes)
    }
    private var secondProgress: Double {
        guard remainingSeconds > 0 else { return 0 }
        return Double(remainingSeconds % 60) / 60.0
    }

    var body: some View {
        ZStack {
            // Outer ring — minute progress
            Circle()
                .stroke(
                    Color.white.opacity(0.06),
                    lineWidth: outerWidth
                )
            Circle()
                .trim(from: 0, to: minuteProgress)
                .stroke(
                    outerColor,
                    style: StrokeStyle(lineWidth: outerWidth, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .animation(.easeInOut(duration: 0.6), value: minuteProgress)

            // Inner ring — second progress
            Circle()
                .stroke(
                    Color.white.opacity(0.06),
                    lineWidth: innerWidth
                )
                .scaleEffect(0.88)
            Circle()
                .trim(from: 0, to: secondProgress)
                .stroke(
                    innerColor,
                    style: StrokeStyle(lineWidth: innerWidth, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .scaleEffect(0.88)
                .animation(.easeInOut(duration: 0.3), value: secondProgress)
        }
    }

    private var outerWidth: CGFloat { outerLineWidth }
    private var innerWidth: CGFloat { innerLineWidth }

    private var effectiveAccent: Color {
        if customAccentColorHex.isEmpty {
            return themeManager?.accent ?? Color(hex: "#00FFFF")
        }
        return Color(hex: customAccentColorHex)
    }

    private var effectivePrimary: Color {
        themeManager?.primary ?? Color(hex: "#FF00FF")
    }

    private var outerColor: Color {
        if isFinished {
            return customAccentColorHex.isEmpty
                ? .red.opacity(0.6)
                : effectiveAccent.opacity(0.4)
        }
        if isRunning { return effectiveAccent.opacity(0.55) }
        if !customAccentColorHex.isEmpty { return effectiveAccent.opacity(0.4) }
        return (themeManager?.glow ?? Color(hex: "#FF00FF")).opacity(0.4)
    }

    private var innerColor: Color {
        if isFinished {
            return customAccentColorHex.isEmpty
                ? .red
                : effectiveAccent
        }
        if isRunning { return effectiveAccent }
        if !customAccentColorHex.isEmpty { return effectiveAccent }
        return effectivePrimary
    }
}
