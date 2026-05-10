import SwiftUI

struct TimerControlsView: View {
    @Bindable var timer: TimerModel
    @EnvironmentObject var timerEngine: TimerEngine
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var windowManager: WindowManager
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        HStack(spacing: 20) {
            Button(action: togglePlayPause) {
                Image(systemName: playPauseIcon)
                    .font(.title2)
                    .frame(width: 40, height: 40)
                    .foregroundStyle(themeManager.accent)
            }
            .buttonStyle(.plain)
            .disabled(timer.totalSeconds == 0)

            Button(action: { timerEngine.reset(timer: timer) }) {
                Image(systemName: "arrow.counterclockwise")
                    .font(.title2)
                    .frame(width: 40, height: 40)
                    .foregroundStyle(themeManager.secondary)
            }
            .buttonStyle(.plain)
            .disabled(timer.status == .idle)

            Button(action: toggleFullscreen) {
                Image(systemName: windowManager.isFullscreenOpen(for: timer.id)
                      ? "arrow.down.right.and.arrow.up.left"
                      : "arrow.up.left.and.arrow.down.right")
                    .font(.title2)
                    .frame(width: 40, height: 40)
                    .foregroundStyle(themeManager.secondary)
            }
            .buttonStyle(.plain)
        }
    }

    private var playPauseIcon: String {
        switch timer.status {
        case .running: return "pause.fill"
        case .finished: return "stop.fill"
        default: return "play.fill"
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
}
