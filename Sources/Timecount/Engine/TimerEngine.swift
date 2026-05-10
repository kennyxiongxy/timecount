import Foundation
import SwiftData
import Combine

@MainActor
final class TimerEngine: ObservableObject {
    @Published var tickCounter: Int = 0
    @Published var runningTimerIDs: Set<UUID> = []

    private let modelContext: ModelContext
    private var soundManager: SoundManager?
    private var timer: AnyCancellable?
    private let tickInterval: TimeInterval = 1.0
    private var isEngineRunning = false
    private var warningTriggeredFor: Set<UUID> = []

    init(modelContext: ModelContext, soundManager: SoundManager? = nil) {
        self.modelContext = modelContext
        self.soundManager = soundManager
        fixStaleRunningTimers()
    }

    private func fixStaleRunningTimers() {
        var descriptor = FetchDescriptor<TimerModel>()
        descriptor.predicate = #Predicate { $0.statusRawValue == "running" }
        guard let stale = try? modelContext.fetch(descriptor), !stale.isEmpty else { return }
        for timer in stale {
            timer.status = .paused
        }
        try? modelContext.save()
    }

    func setSoundManager(_ soundManager: SoundManager) {
        self.soundManager = soundManager
    }

    func start(timer: TimerModel) {
        guard timer.status != .running else { return }
        let wasFinished = timer.status == .finished
        if timer.remainingSeconds <= 0 {
            timer.remainingSeconds = timer.totalSeconds
        }
        timer.status = .running
        runningTimerIDs.insert(timer.id)
        try? modelContext.save()
        if wasFinished {
            soundManager?.stopEndSound()
        }
        soundManager?.playStartSound()
        ensureEngineRunning()
    }

    func pause(timer: TimerModel) {
        if timer.status == .finished {
            soundManager?.stopEndSound()
            timer.status = .idle
            try? modelContext.save()
            return
        }
        guard timer.status == .running else { return }
        timer.status = .paused
        runningTimerIDs.remove(timer.id)
        warningTriggeredFor.remove(timer.id)
        try? modelContext.save()
    }

    func reset(timer: TimerModel) {
        if timer.status == .running {
            runningTimerIDs.remove(timer.id)
        }
        if timer.status == .finished {
            soundManager?.stopEndSound()
        }
        warningTriggeredFor.remove(timer.id)
        timer.remainingSeconds = timer.totalSeconds
        timer.status = .idle
        try? modelContext.save()
    }

    func adjustTime(timer: TimerModel, deltaSeconds: Int) {
        let newRemaining = timer.remainingSeconds + deltaSeconds
        timer.remainingSeconds = max(0, newRemaining)
        if timer.totalSeconds < timer.remainingSeconds {
            timer.totalSeconds = timer.remainingSeconds
        }
        warningTriggeredFor.remove(timer.id)
        try? modelContext.save()
    }

    func setTime(timer: TimerModel, totalSeconds: Int) {
        timer.totalSeconds = totalSeconds
        timer.remainingSeconds = totalSeconds
        timer.status = .idle
        runningTimerIDs.remove(timer.id)
        warningTriggeredFor.remove(timer.id)
        try? modelContext.save()
    }

    func stopEngine() {
        timer?.cancel()
        timer = nil
        isEngineRunning = false
        for timerID in runningTimerIDs {
            if let t = fetchTimer(by: timerID) {
                t.status = .paused
            }
        }
        runningTimerIDs.removeAll()
        warningTriggeredFor.removeAll()
        try? modelContext.save()
    }

    private func ensureEngineRunning() {
        guard !isEngineRunning else { return }
        isEngineRunning = true
        timer = Timer.publish(every: tickInterval, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.tick()
            }
    }

    private func tick() {
        let snapshot = runningTimerIDs
        for timerID in snapshot {
            guard let timer = fetchTimer(by: timerID), timer.status == .running else {
                runningTimerIDs.remove(timerID)
                warningTriggeredFor.remove(timerID)
                continue
            }
            timer.remainingSeconds -= 1

            // Warning sound check
            let warningSeconds = timer.warningMinutesOverride ?? 1
            if timer.remainingSeconds > 0,
               timer.remainingSeconds <= warningSeconds * 60,
               !warningTriggeredFor.contains(timerID) {
                warningTriggeredFor.insert(timerID)
                soundManager?.playWarningSound()
            }

            // Finished check
            if timer.remainingSeconds <= 0 {
                timer.remainingSeconds = 0
                timer.status = .finished
                runningTimerIDs.remove(timerID)
                warningTriggeredFor.remove(timerID)
                soundManager?.playEndSoundLoop()
            }
        }
        try? modelContext.save()
        tickCounter += 1

        if runningTimerIDs.isEmpty {
            timer?.cancel()
            timer = nil
            isEngineRunning = false
        }
    }

    private func fetchTimer(by id: UUID) -> TimerModel? {
        var descriptor = FetchDescriptor<TimerModel>()
        descriptor.fetchLimit = 1
        descriptor.predicate = #Predicate { $0.id == id }
        return try? modelContext.fetch(descriptor).first
    }
}
