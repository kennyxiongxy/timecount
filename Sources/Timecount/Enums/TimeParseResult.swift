import Foundation

enum TimeParseResult: Equatable {
    case absolute(seconds: Int)
    case relative(seconds: Int)
    case invalid
}
