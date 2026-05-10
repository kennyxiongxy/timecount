import AppKit
import SwiftUI
import SwiftData

final class FullscreenWindowController: NSWindowController, NSWindowDelegate {
    private let timerID: UUID
    private var localMonitor: Any?
    private let onClose: (() -> Void)?
    private let timerEngine: TimerEngine
    private let modelContext: ModelContext

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
        self.timerEngine = timerEngine
        self.modelContext = modelContext

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

        let rootView = SingleTimerFullscreenView(timerID: timerID, onClose: { [weak window] in
            window?.close()
        })
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
            if event.keyCode == 49 {
                self?.toggleTimer()
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

    private func toggleTimer() {
        var descriptor = FetchDescriptor<TimerModel>()
        descriptor.fetchLimit = 1
        descriptor.predicate = #Predicate { $0.id == timerID }
        guard let timer = try? modelContext.fetch(descriptor).first else { return }

        switch timer.status {
        case .running:
            timerEngine.pause(timer: timer)
        case .finished:
            timerEngine.pause(timer: timer)
        default:
            timerEngine.start(timer: timer)
        }
    }
}
