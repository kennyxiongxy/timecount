import AppKit
import SwiftUI
import SwiftData

final class FullscreenWindowController: NSWindowController, NSWindowDelegate {
    private let timerID: UUID
    private var localMonitor: Any?
    private let onClose: (() -> Void)?

    init(
        timerID: UUID,
        modelContext: ModelContext,
        timerEngine: TimerEngine,
        themeManager: ThemeManager,
        soundManager: SoundManager,
        onClose: (() -> Void)? = nil
    ) {
        self.onClose = onClose
        self.timerID = timerID

        let screenFrame = NSScreen.main?.frame ?? NSRect(x: 0, y: 0, width: 1920, height: 1080)

        let window = NSWindow(
            contentRect: screenFrame,
            styleMask: [.borderless, .fullSizeContentView],
            backing: .buffered,
            defer: false
        )
        window.level = NSWindow.Level(rawValue: Int(CGWindowLevelForKey(.mainMenuWindow)) + 2)
        window.isOpaque = true
        window.backgroundColor = .black
        window.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        window.isReleasedWhenClosed = false
        window.hasShadow = false
        window.hidesOnDeactivate = false

        let rootView = SingleTimerFullscreenView(timerID: timerID)
            .modelContext(modelContext)
            .environmentObject(timerEngine)
            .environmentObject(themeManager)
            .environmentObject(soundManager)
        window.contentView = NSHostingView(rootView: rootView)

        super.init(window: window)
        window.delegate = self

        localMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { [weak self] event in
            if event.keyCode == 53 {
                self?.close()
                return nil
            }
            return event
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func showWindow(_ sender: Any?) {
        super.showWindow(sender)
        window?.makeKeyAndOrderFront(nil)
        window?.setFrame(window!.screen!.frame, display: true)
    }

    func windowWillClose(_ notification: Notification) {
        onClose?()
    }

    deinit {
        if let monitor = localMonitor {
            NSEvent.removeMonitor(monitor)
        }
    }
}
