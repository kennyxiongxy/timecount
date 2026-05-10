import Foundation
import SwiftUI
import Testing
@testable import Timecount

struct TimerModelTests {

    @Test("TimerModel initializes with correct defaults")
    func initializerDefaults() {
        let timer = TimerModel(name: "Test", totalSeconds: 300)
        #expect(timer.name == "Test")
        #expect(timer.totalSeconds == 300)
        #expect(timer.remainingSeconds == 300)
        #expect(timer.status == .idle)
        #expect(timer.isRunning == false)
        #expect(timer.sortOrder == 0)
        #expect(timer.backgroundColorHex == "")
        #expect(timer.warningMinutesOverride == nil)
        #expect(timer.customEndSoundURL == nil)
    }

    @Test("TimerModel progress calculation")
    func progressCalculation() {
        let timer = TimerModel(name: "Test", totalSeconds: 100)

        #expect(timer.progress == 1.0) // remaining == total

        timer.remainingSeconds = 50
        #expect(timer.progress == 0.5)

        timer.remainingSeconds = 0
        #expect(timer.progress == 0.0)
    }

    @Test("TimerModel progress with zero total should be zero")
    func progressWithZeroTotal() {
        let timer = TimerModel(name: "Test", totalSeconds: 0)
        #expect(timer.progress == 0.0)
    }

    @Test("TimerModel displayTime")
    func displayTime() {
        let timer = TimerModel(name: "Test", totalSeconds: 300)
        #expect(timer.displayTime == "5:00")

        timer.remainingSeconds = 90
        #expect(timer.displayTime == "1:30")

        timer.remainingSeconds = 0
        #expect(timer.displayTime == "0:00")
    }

    @Test("TimerModel status transitions via rawValue")
    func statusRawValueRoundtrip() {
        let timer = TimerModel(name: "Test", totalSeconds: 100)

        #expect(timer.status == .idle)
        #expect(timer.statusRawValue == "idle")

        timer.status = .running
        #expect(timer.status == .running)
        #expect(timer.statusRawValue == "running")
        #expect(timer.isRunning == true)

        timer.status = .paused
        #expect(timer.status == .paused)
        #expect(timer.statusRawValue == "paused")
        #expect(timer.isRunning == false)

        timer.status = .finished
        #expect(timer.status == .finished)
        #expect(timer.statusRawValue == "finished")
        #expect(timer.isRunning == false)

        timer.status = .idle
        #expect(timer.status == .idle)
    }
}

struct TimerStatusTests {

    @Test("TimerStatus has exactly 4 cases")
    func caseCount() {
        #expect(TimerStatus.allCases.count == 4)
    }

    @Test("TimerStatus all cases exist")
    func allCasesExist() {
        let expected: Set<String> = ["idle", "running", "paused", "finished"]
        let actual = Set(TimerStatus.allCases.map(\.rawValue))
        #expect(actual == expected)
    }
}

struct ColorHexTests {

    @Test("Color hex parsing: valid colors")
    func validHexColors() {
        let color = SwiftUI.Color(hex: "#FF0000")
        let hex = color.toHex()
        #expect(hex == "#FF0000")

        let black = SwiftUI.Color(hex: "000000")
        #expect(black.toHex() == "#000000")

        let white = SwiftUI.Color(hex: "FFFFFF")
        #expect(white.toHex() == "#FFFFFF")
    }

    @Test("Color hex parsing: cyberpunk theme colors")
    func themeColors() {
        let magenta = SwiftUI.Color(hex: "#FF00FF")
        #expect(magenta.toHex() == "#FF00FF")

        let cyan = SwiftUI.Color(hex: "#00FFFF")
        #expect(cyan.toHex() == "#00FFFF")

        let bg = SwiftUI.Color(hex: "#0A0A1A")
        #expect(bg.toHex() == "#0A0A1A")
    }

    @Test("Color hex parsing: invalid falls back to black")
    func invalidHex() {
        let invalid = SwiftUI.Color(hex: "notacolor")
        #expect(invalid.toHex() == "#000000")
    }
}
