import Foundation
import SwiftData

@Model
final class ThemeConfiguration {
    @Attribute(.unique) var id: UUID = UUID()
    var name: String = ""
    var isBuiltIn: Bool = false
    var isActive: Bool = false

    var backgroundColorHex: String = "#0A0A1A"
    var cardBackgroundColorHex: String = "#0F0F2A"
    var cardBorderColorHex: String = "#FF00FF"
    var primaryTextColorHex: String = "#FF00FF"
    var secondaryTextColorHex: String = "#8888AA"
    var accentColorHex: String = "#00FFFF"

    var glowColorHex: String = "#FF00FF"
    var glowRadius: Double = 12.0
    var glowOpacity: Double = 0.7

    var timerFontName: String = "LiquidCrystal"
    var uiFontName: String = ".AppleSystemUIFont"
    var timerFontSize: Double = 48.0

    var useScanlines: Bool = false
    var useParticleEffect: Bool = false
    var borderStyleRaw: String = "glowing"

    init(name: String, isBuiltIn: Bool = false) {
        self.name = name
        self.isBuiltIn = isBuiltIn
    }
}
