import Foundation
import Testing
@testable import Timecount

struct TimeFormattingTests {

    // MARK: - formatCompact

    @Test("formatCompact: seconds only")
    func compactSecondsOnly() {
        #expect(TimeInterval.formatCompact(0) == "0:00")
        #expect(TimeInterval.formatCompact(5) == "0:05")
        #expect(TimeInterval.formatCompact(30) == "0:30")
        #expect(TimeInterval.formatCompact(59) == "0:59")
    }

    @Test("formatCompact: minutes and seconds")
    func compactMinutesSeconds() {
        #expect(TimeInterval.formatCompact(60) == "1:00")
        #expect(TimeInterval.formatCompact(90) == "1:30")
        #expect(TimeInterval.formatCompact(300) == "5:00")
        #expect(TimeInterval.formatCompact(599) == "9:59")
        #expect(TimeInterval.formatCompact(600) == "10:00")
        #expect(TimeInterval.formatCompact(3599) == "59:59")
    }

    @Test("formatCompact: hours, minutes, seconds")
    func compactWithHours() {
        #expect(TimeInterval.formatCompact(3600) == "1:00:00")
        #expect(TimeInterval.formatCompact(3661) == "1:01:01")
        #expect(TimeInterval.formatCompact(7200) == "2:00:00")
        #expect(TimeInterval.formatCompact(86399) == "23:59:59")
    }

    @Test("formatCompact: edge case — max value")
    func compactMaxValue() {
        #expect(TimeInterval.formatCompact(359999) == "99:59:59")
    }

    // MARK: - formatFull

    @Test("formatFull: seconds only")
    func fullSecondsOnly() {
        #expect(TimeInterval.formatFull(0) == "0s")
        #expect(TimeInterval.formatFull(30) == "30s")
        #expect(TimeInterval.formatFull(59) == "59s")
    }

    @Test("formatFull: minutes and seconds")
    func fullMinutesSeconds() {
        #expect(TimeInterval.formatFull(60) == "1m 0s")
        #expect(TimeInterval.formatFull(90) == "1m 30s")
        #expect(TimeInterval.formatFull(300) == "5m 0s")
        #expect(TimeInterval.formatFull(330) == "5m 30s")
        #expect(TimeInterval.formatFull(3599) == "59m 59s")
    }

    @Test("formatFull: hours")
    func fullWithHours() {
        #expect(TimeInterval.formatFull(3600) == "1h 0m 0s")
        #expect(TimeInterval.formatFull(3661) == "1h 1m 1s")
        #expect(TimeInterval.formatFull(7200) == "2h 0m 0s")
        #expect(TimeInterval.formatFull(86399) == "23h 59m 59s")
    }
}
