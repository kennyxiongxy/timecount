import Foundation

enum TimerStatus: String, Codable, CaseIterable {
    case idle
    case running
    case paused
    case finished
}
