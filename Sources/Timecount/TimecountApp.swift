import SwiftUI
import SwiftData

@main
struct TimecountApp: App {
    @StateObject private var timerEngine: TimerEngine
    @StateObject private var themeManager: ThemeManager
    @StateObject private var soundManager: SoundManager
    @StateObject private var windowManager: WindowManager

    let modelContainer: ModelContainer

    init() {
        do {
            modelContainer = try ModelContainer(for: TimerModel.self, Preset.self, ThemeConfiguration.self)
        } catch {
            fatalError("Failed to create ModelContainer: \(error)")
        }

        let context = modelContainer.mainContext
        let sounds = SoundManager()
        let engine = TimerEngine(modelContext: context, soundManager: sounds)
        let themes = ThemeManager(modelContext: context)
        let windows = WindowManager()
        windows.configure(timerEngine: engine, themeManager: themes, soundManager: sounds)

        _timerEngine = StateObject(wrappedValue: engine)
        _themeManager = StateObject(wrappedValue: themes)
        _soundManager = StateObject(wrappedValue: sounds)
        _windowManager = StateObject(wrappedValue: windows)

        DataSeeder.seedIfNeeded(in: context)
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .modelContainer(modelContainer)
                .environmentObject(timerEngine)
                .environmentObject(themeManager)
                .environmentObject(soundManager)
                .environmentObject(windowManager)
        }
        .windowStyle(.hiddenTitleBar)
        .defaultSize(width: 1000, height: 620)
        .windowResizability(.contentSize)

        MenuBarExtra("Timecount", systemImage: "timer") {
            MenuBarView()
                .modelContainer(modelContainer)
                .environmentObject(timerEngine)
                .environmentObject(themeManager)
                .environmentObject(soundManager)
                .environmentObject(windowManager)
        }
        .menuBarExtraStyle(.menu)
    }
}
