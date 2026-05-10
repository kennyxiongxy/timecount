import Foundation

struct TimeParseEngine {
    static let maxSeconds: Int = 359_999 // 99h 59m 59s

    private static let pattern = #"(\d+)\s*(h(?:ou?rs?)?|m(?:in(?:ute)?s?)?|s(?:ec(?:ond)?s?)?)?"#
    private static let regex = try! NSRegularExpression(pattern: pattern, options: [.caseInsensitive])

    static func parse(_ input: String) -> TimeParseResult {
        let trimmed = input.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return .invalid }

        var isRelative = false
        var signMultiplier = 1
        var working = trimmed

        if working.hasPrefix("+") {
            isRelative = true
            working.removeFirst()
        } else if working.hasPrefix("-") {
            isRelative = true
            signMultiplier = -1
            working.removeFirst()
        }

        guard !working.isEmpty else { return .invalid }
        // Guard against double sign
        if working.hasPrefix("+") || working.hasPrefix("-") {
            return .invalid
        }

        let nsRange = NSRange(working.startIndex..., in: working)
        let matches = regex.matches(in: working, range: nsRange)
        guard !matches.isEmpty else { return .invalid }

        var totalSeconds = 0
        var matchedAny = false

        for match in matches {
            guard let digitsRange = Range(match.range(at: 1), in: working) else { continue }
            guard let digits = Int(working[digitsRange]) else { continue }

            let unitStr: String
            if let unitRange = Range(match.range(at: 2), in: working) {
                unitStr = String(working[unitRange]).lowercased()
            } else {
                unitStr = ""
            }

            let multiplier: Int = {
                if unitStr.isEmpty { return 1 }
                switch unitStr.first {
                case "h": return 3600
                case "m": return 60
                case "s": return 1
                default:  return 1
                }
            }()

            totalSeconds += digits * multiplier
            matchedAny = true
        }

        guard matchedAny else { return .invalid }

        totalSeconds = min(totalSeconds, maxSeconds)

        if isRelative {
            return .relative(seconds: signMultiplier * totalSeconds)
        }
        return .absolute(seconds: totalSeconds)
    }
}
