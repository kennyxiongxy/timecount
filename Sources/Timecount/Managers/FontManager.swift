import Foundation
import CoreText

struct FontManager {
    static let defaultTimerFont = "LiquidCrystal"

    static func registerCustomFonts() {
        let fontNames = [
            "DS-Digital",
            "DigifaceWide",
            "LCD-BQ",
            "LCD",
            "LiquidCrystal",
            "led_board-7",
            "led_counter-7",
            "AaXiaoGouGuaiGuaiXiangSuTi-2",
        ]

        for name in fontNames {
            guard let url = Bundle.module.url(forResource: name, withExtension: "ttf")
                  ?? Bundle.module.url(forResource: name, withExtension: "TTF") else {
                continue
            }

            var error: Unmanaged<CFError>?
            CTFontManagerRegisterFontsForURL(url as CFURL, .process, &error)

            if let error = error?.takeRetainedValue() {
                let description = CFErrorCopyDescription(error) as String
                print("Failed to register font \(name): \(description)")
            }
        }
    }
}
