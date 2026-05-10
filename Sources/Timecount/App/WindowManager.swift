import Foundation
import SwiftData

@MainActor
final class WindowManager: ObservableObject {
    private var controllers: [UUID: FullscreenWindowController] = [:]

    private weak var timerEngine: TimerEngine?
    private weak var themeManager: ThemeManager?
    private weak var soundManager: SoundManager?

    func configure(
        timerEngine: TimerEngine,
        themeManager: ThemeManager,
        soundManager: SoundManager
    ) {
        self.timerEngine = timerEngine
        self.themeManager = themeManager
        self.soundManager = soundManager
    }

    func openFullscreen(for timerID: UUID, modelContext: ModelContext) {
        guard controllers[timerID] == nil else { return }
        guard let engine = timerEngine,
              let theme = themeManager,
              let sound = soundManager else { return }

        let controller = FullscreenWindowController(
            timerID: timerID,
            modelContext: modelContext,
            timerEngine: engine,
            themeManager: theme,
            soundManager: sound,
            onClose: { [weak self] in
                self?.removeController(for: timerID)
            }
        )
        controllers[timerID] = controller
        controller.showWindow(nil)
    }

    func closeFullscreen(for timerID: UUID) {
        controllers[timerID]?.close()
        controllers.removeValue(forKey: timerID)
    }

    func isFullscreenOpen(for timerID: UUID) -> Bool {
        controllers[timerID] != nil
    }

    func removeController(for timerID: UUID) {
        controllers.removeValue(forKey: timerID)
    }
}
