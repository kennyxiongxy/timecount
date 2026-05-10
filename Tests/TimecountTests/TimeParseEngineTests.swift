import Testing
@testable import Timecount

struct TimeParseEngineTests {

    // MARK: - Absolute time parsing

    @Test("Parse absolute: bare number defaults to seconds")
    func bareNumber() {
        #expect(TimeParseEngine.parse("30") == .absolute(seconds: 30))
        #expect(TimeParseEngine.parse("90") == .absolute(seconds: 90))
        #expect(TimeParseEngine.parse("1") == .absolute(seconds: 1))
    }

    @Test("Parse absolute: minutes only")
    func minutesOnly() {
        #expect(TimeParseEngine.parse("5m") == .absolute(seconds: 300))
        #expect(TimeParseEngine.parse("1m") == .absolute(seconds: 60))
        #expect(TimeParseEngine.parse("90m") == .absolute(seconds: 5400))
    }

    @Test("Parse absolute: seconds only")
    func secondsOnly() {
        #expect(TimeParseEngine.parse("30s") == .absolute(seconds: 30))
        #expect(TimeParseEngine.parse("90s") == .absolute(seconds: 90))
    }

    @Test("Parse absolute: hours only")
    func hoursOnly() {
        #expect(TimeParseEngine.parse("1h") == .absolute(seconds: 3600))
        #expect(TimeParseEngine.parse("2h") == .absolute(seconds: 7200))
    }

    @Test("Parse absolute: mixed units")
    func mixedUnits() {
        #expect(TimeParseEngine.parse("5m30s") == .absolute(seconds: 330))
        #expect(TimeParseEngine.parse("1h15m") == .absolute(seconds: 4500))
        #expect(TimeParseEngine.parse("1h30m45s") == .absolute(seconds: 5445))
        #expect(TimeParseEngine.parse("2h5m10s") == .absolute(seconds: 7510))
    }

    @Test("Parse absolute: long-form units")
    func longFormUnits() {
        #expect(TimeParseEngine.parse("1hour") == .absolute(seconds: 3600))
        #expect(TimeParseEngine.parse("30mins") == .absolute(seconds: 1800))
        #expect(TimeParseEngine.parse("1hour 30minutes") == .absolute(seconds: 5400))
        #expect(TimeParseEngine.parse("1 hour 30 min 45 sec") == .absolute(seconds: 5445))
    }

    @Test("Parse absolute: whitespace tolerant")
    func whitespaceTolerant() {
        #expect(TimeParseEngine.parse("  5m  ") == .absolute(seconds: 300))
        #expect(TimeParseEngine.parse(" 1h 30m ") == .absolute(seconds: 5400))
        #expect(TimeParseEngine.parse("\t5m30s\n") == .absolute(seconds: 330))
    }

    @Test("Parse absolute: spaces between digits and units")
    func spaceBetweenDigitAndUnit() {
        #expect(TimeParseEngine.parse("1 h 30 m") == .absolute(seconds: 5400))
        #expect(TimeParseEngine.parse("5 m") == .absolute(seconds: 300))
    }

    @Test("Parse absolute: max seconds clamp")
    func maxSecondsClamp() {
        #expect(TimeParseEngine.parse("100h") == .absolute(seconds: 359999))
        #expect(TimeParseEngine.parse("200h") == .absolute(seconds: 359999))
        #expect(TimeParseEngine.parse("1000h") == .absolute(seconds: 359999))
    }

    @Test("Parse absolute: zero is valid")
    func zeroIsValid() {
        #expect(TimeParseEngine.parse("0") == .absolute(seconds: 0))
        #expect(TimeParseEngine.parse("0s") == .absolute(seconds: 0))
        #expect(TimeParseEngine.parse("0m") == .absolute(seconds: 0))
    }

    // MARK: - Relative time parsing

    @Test("Parse relative: positive adjustment")
    func positiveRelative() {
        #expect(TimeParseEngine.parse("+5m") == .relative(seconds: 300))
        #expect(TimeParseEngine.parse("+30s") == .relative(seconds: 30))
        #expect(TimeParseEngine.parse("+1h") == .relative(seconds: 3600))
        #expect(TimeParseEngine.parse("+1h30m") == .relative(seconds: 5400))
        #expect(TimeParseEngine.parse("+30") == .relative(seconds: 30))
    }

    @Test("Parse relative: negative adjustment")
    func negativeRelative() {
        #expect(TimeParseEngine.parse("-5m") == .relative(seconds: -300))
        #expect(TimeParseEngine.parse("-30s") == .relative(seconds: -30))
        #expect(TimeParseEngine.parse("-1h") == .relative(seconds: -3600))
        #expect(TimeParseEngine.parse("-1h30m") == .relative(seconds: -5400))
        #expect(TimeParseEngine.parse("-10") == .relative(seconds: -10))
    }

    // MARK: - Invalid inputs

    @Test("Parse invalid: empty and whitespace-only")
    func invalidEmpty() {
        #expect(TimeParseEngine.parse("") == .invalid)
        #expect(TimeParseEngine.parse("   ") == .invalid)
    }

    @Test("Parse invalid: non-numeric")
    func invalidNonNumeric() {
        #expect(TimeParseEngine.parse("abc") == .invalid)
        #expect(TimeParseEngine.parse("hello") == .invalid)
    }

    @Test("Parse invalid: sign only")
    func invalidSignOnly() {
        #expect(TimeParseEngine.parse("+") == .invalid)
        #expect(TimeParseEngine.parse("-") == .invalid)
        #expect(TimeParseEngine.parse("+ ") == .invalid)
        #expect(TimeParseEngine.parse("- ") == .invalid)
    }

    @Test("Parse invalid: double sign")
    func invalidDoubleSign() {
        #expect(TimeParseEngine.parse("++5m") == .invalid)
        #expect(TimeParseEngine.parse("--30s") == .invalid)
    }

    @Test("Parse forgiving: space between sign and value")
    func forgivingSignSpace() {
        // Parser tolerates space between sign and value
        #expect(TimeParseEngine.parse("+ 5m") == .relative(seconds: 300))
    }

    @Test("Parse forgiving: extracts time patterns from mixed text")
    func forgivingMixedText() {
        // Parser extracts valid time patterns even with surrounding text
        #expect(TimeParseEngine.parse("xyz 5m") == .absolute(seconds: 300))
    }

    @Test("Parse invalid: purely garbage text with no time pattern")
    func invalidPureGarbage() {
        #expect(TimeParseEngine.parse("quick brown fox") == .invalid)
    }

    // MARK: - Edge cases from user scenarios

    @Test("Edge case: common user inputs")
    func commonUserInputs() {
        // Timer presets
        #expect(TimeParseEngine.parse("5m") == .absolute(seconds: 300))
        #expect(TimeParseEngine.parse("10m") == .absolute(seconds: 600))
        #expect(TimeParseEngine.parse("30m") == .absolute(seconds: 1800))
        #expect(TimeParseEngine.parse("1h") == .absolute(seconds: 3600))
        #expect(TimeParseEngine.parse("2h") == .absolute(seconds: 7200))

        // Coffee / cooking / presentation timers
        #expect(TimeParseEngine.parse("3m") == .absolute(seconds: 180))
        #expect(TimeParseEngine.parse("15m") == .absolute(seconds: 900))
        #expect(TimeParseEngine.parse("45m") == .absolute(seconds: 2700))
    }

    @Test("Edge case: running adjustment scenarios")
    func runningAdjustments() {
        // Adding time during countdown
        #expect(TimeParseEngine.parse("+1m") == .relative(seconds: 60))
        #expect(TimeParseEngine.parse("+30s") == .relative(seconds: 30))
        #expect(TimeParseEngine.parse("+5m30s") == .relative(seconds: 330))

        // Subtracting time during countdown
        #expect(TimeParseEngine.parse("-30s") == .relative(seconds: -30))
        #expect(TimeParseEngine.parse("-1m") == .relative(seconds: -60))
    }

    @Test("Edge case: single digit numbers")
    func singleDigit() {
        #expect(TimeParseEngine.parse("5") == .absolute(seconds: 5))
        #expect(TimeParseEngine.parse("9") == .absolute(seconds: 9))
        #expect(TimeParseEngine.parse("0") == .absolute(seconds: 0))
    }

    @Test("Edge case: very large numbers")
    func veryLargeNumbers() {
        #expect(TimeParseEngine.parse("999h") == .absolute(seconds: 359999))
        #expect(TimeParseEngine.parse("999999s") == .absolute(seconds: 359999))
    }

    @Test("Edge case: full spelling variations")
    func spellingVariations() {
        #expect(TimeParseEngine.parse("2hours") == .absolute(seconds: 7200))
        #expect(TimeParseEngine.parse("5min") == .absolute(seconds: 300))
        #expect(TimeParseEngine.parse("5minutes") == .absolute(seconds: 300))
        #expect(TimeParseEngine.parse("30sec") == .absolute(seconds: 30))
        #expect(TimeParseEngine.parse("30seconds") == .absolute(seconds: 30))
    }

    @Test("Edge case: unit case insensitivity")
    func unitCaseInsensitivity() {
        #expect(TimeParseEngine.parse("5M") == .absolute(seconds: 300))
        #expect(TimeParseEngine.parse("1H") == .absolute(seconds: 3600))
        #expect(TimeParseEngine.parse("30S") == .absolute(seconds: 30))
        #expect(TimeParseEngine.parse("1H30M") == .absolute(seconds: 5400))
    }
}
