import Foundation
import AppKit
import AVFoundation

@MainActor
final class SoundManager: ObservableObject {
    @Published var isMuted: Bool = false
    @Published var globalVolume: Double = 1.0
    var startDisabled = false
    var endDisabled = false
    var warningDisabled = false

    private var startPlayer: AVAudioPlayer?
    private var endPlayer: AVAudioPlayer?
    private var warningPlayer: AVAudioPlayer?

    private var startSystemSound: NSSound?
    private var endSystemSound: NSSound?
    private var warningSystemSound: NSSound?

    private var endSoundStopTask: Task<Void, Never>?

    init() {
        preloadSystemSounds()
        restorePersistedSettings()
    }

    // MARK: - Built-in sounds

    static func builtInSoundNames() -> [String] {
        guard let url = Bundle.main.url(forResource: "Sounds", withExtension: nil) else { return [] }
        guard let files = try? FileManager.default.contentsOfDirectory(at: url, includingPropertiesForKeys: nil) else { return [] }
        return files.filter { $0.pathExtension == "mp3" }.map { $0.deletingPathExtension().lastPathComponent }.sorted()
    }

    func loadBuiltInSound(named name: String, for event: SoundEvent) {
        guard let url = Bundle.main.url(forResource: name, withExtension: "mp3", subdirectory: "Sounds") else { return }
        loadSound(url: url, for: event)
    }

    // MARK: - Playback

    func playStartSound() {
        guard !isMuted, !startDisabled else { return }
        if startPlayer != nil { startPlayer?.play() }
        else { startSystemSound?.play() }
    }

    func playEndSound() {
        guard !isMuted, !endDisabled else { return }
        if endPlayer != nil { endPlayer?.play() }
        else { endSystemSound?.play() }
    }

    func playEndSoundLoop() {
        guard !isMuted, !endDisabled else { return }
        endSoundStopTask?.cancel()

        if let player = endPlayer {
            player.numberOfLoops = -1
            player.play()
        } else {
            endSystemSound?.loops = true
            endSystemSound?.play()
        }

        endSoundStopTask = Task {
            try? await Task.sleep(for: .seconds(10))
            guard !Task.isCancelled else { return }
            stopEndSound()
        }
    }

    func stopEndSound() {
        endSoundStopTask?.cancel()
        endSoundStopTask = nil
        endSystemSound?.stop()
        endSystemSound?.loops = false
        endPlayer?.stop()
        endPlayer?.numberOfLoops = 0
    }

    func playWarningSound() {
        guard !isMuted, !warningDisabled else { return }
        if warningPlayer != nil { warningPlayer?.play() }
        else { warningSystemSound?.play() }
    }

    // MARK: - Sound management

    func setCustomSound(url: URL?, for event: SoundEvent) {
        guard let url = url else { return }
        loadSound(url: url, for: event)
    }

    func setDisabled(_ disabled: Bool, for event: SoundEvent) {
        switch event {
        case .start:  startDisabled = disabled
        case .end:    endDisabled = disabled
        case .warning: warningDisabled = disabled
        }
    }

    func resetToSystemDefault(for event: SoundEvent) {
        switch event {
        case .start:  startPlayer = nil
        case .end:    endPlayer = nil
        case .warning: warningPlayer = nil
        }
    }

    enum SoundEvent { case start, end, warning }

    // MARK: - Private

    private func loadSound(url: URL, for event: SoundEvent) {
        do {
            let player = try AVAudioPlayer(contentsOf: url)
            player.volume = Float(globalVolume)
            player.prepareToPlay()
            switch event {
            case .start:  startPlayer = player
            case .end:    endPlayer = player
            case .warning: warningPlayer = player
            }
        } catch {
            print("Failed to load sound: \(error)")
        }
    }

    private func preloadSystemSounds() {
        startSystemSound = NSSound(named: "Pop")
        endSystemSound = NSSound(named: "Basso")
        warningSystemSound = NSSound(named: "Funk")
    }

    private func restorePersistedSettings() {
        let defaults = UserDefaults.standard
        let modes = [
            (defaults.string(forKey: "startSoundMode") ?? "系统默认", defaults.string(forKey: "startBuiltIn") ?? "", defaults.string(forKey: "startCustomPath"), SoundEvent.start),
            (defaults.string(forKey: "endSoundMode") ?? "系统默认", defaults.string(forKey: "endBuiltIn") ?? "", defaults.string(forKey: "endCustomPath"), SoundEvent.end),
            (defaults.string(forKey: "warningSoundMode") ?? "系统默认", defaults.string(forKey: "warningBuiltIn") ?? "", defaults.string(forKey: "warningCustomPath"), SoundEvent.warning)
        ]

        for (modeRaw, builtIn, customPath, event) in modes {
            switch modeRaw {
            case "关闭":
                setDisabled(true, for: event)
                resetToSystemDefault(for: event)
            case "内置铃声" where !builtIn.isEmpty:
                setDisabled(false, for: event)
                loadBuiltInSound(named: builtIn, for: event)
            case "自定义文件":
                setDisabled(false, for: event)
                if let path = customPath, !path.isEmpty, FileManager.default.fileExists(atPath: path) {
                    setCustomSound(url: URL(fileURLWithPath: path), for: event)
                } else {
                    resetToSystemDefault(for: event)
                }
            default: // "系统默认"
                setDisabled(false, for: event)
                resetToSystemDefault(for: event)
            }
        }
    }
}
