import Foundation
import SwiftData

@Model
final class TimerModel {
    @Attribute(.unique) var id: UUID = UUID()
    var name: String = ""
    var totalSeconds: Int = 0
    var remainingSeconds: Int = 0
    var statusRawValue: String = TimerStatus.idle.rawValue
    var backgroundColorHex: String = ""
    var sortOrder: Int = 0
    var createdAt: Date = Date()
    var warningMinutesOverride: Int? = nil
    var customEndSoundURL: String? = nil

    @Transient
    var status: TimerStatus {
        get { TimerStatus(rawValue: statusRawValue) ?? .idle }
        set { statusRawValue = newValue.rawValue }
    }

    @Transient
    var isRunning: Bool {
        status == .running
    }

    @Transient
    var progress: Double {
        guard totalSeconds > 0 else { return 0 }
        return Double(remainingSeconds) / Double(totalSeconds)
    }

    @Transient
    var displayTime: String {
        TimeInterval.formatCompact(remainingSeconds)
    }

    init(name: String, totalSeconds: Int, sortOrder: Int = 0) {
        self.name = name
        self.totalSeconds = totalSeconds
        self.remainingSeconds = totalSeconds
        self.sortOrder = sortOrder
    }
}
