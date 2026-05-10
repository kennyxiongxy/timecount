import Foundation

enum ThemePresets {
    static let all: [(String, (ThemeConfiguration) -> Void)] = [
        ("Neon Nights", { t in
            t.backgroundColorHex = "#0A0A1A"
            t.cardBackgroundColorHex = "#0F0F2A"
            t.cardBorderColorHex = "#FF00FF"
            t.primaryTextColorHex = "#FF00FF"
            t.secondaryTextColorHex = "#8888AA"
            t.accentColorHex = "#00FFFF"
            t.glowColorHex = "#FF00FF"
            t.glowRadius = 12
            t.glowOpacity = 0.7
        }),
        ("Cyber Matrix", { t in
            t.backgroundColorHex = "#000800"
            t.cardBackgroundColorHex = "#001000"
            t.cardBorderColorHex = "#00FF41"
            t.primaryTextColorHex = "#00FF41"
            t.secondaryTextColorHex = "#008F11"
            t.accentColorHex = "#00FF41"
            t.glowColorHex = "#00FF41"
            t.glowRadius = 16
            t.glowOpacity = 0.85
        }),
        ("Synthwave", { t in
            t.backgroundColorHex = "#1A0030"
            t.cardBackgroundColorHex = "#2A0040"
            t.cardBorderColorHex = "#FF6B35"
            t.primaryTextColorHex = "#FF6B35"
            t.secondaryTextColorHex = "#9B59B6"
            t.accentColorHex = "#E84393"
            t.glowColorHex = "#FF6B35"
            t.glowRadius = 10
            t.glowOpacity = 0.6
        }),
        ("Cold Circuit", { t in
            t.backgroundColorHex = "#001020"
            t.cardBackgroundColorHex = "#001830"
            t.cardBorderColorHex = "#0080FF"
            t.primaryTextColorHex = "#4DA6FF"
            t.secondaryTextColorHex = "#336699"
            t.accentColorHex = "#00AAFF"
            t.glowColorHex = "#0080FF"
            t.glowRadius = 10
            t.glowOpacity = 0.6
        }),
        ("Void", { t in
            t.backgroundColorHex = "#000000"
            t.cardBackgroundColorHex = "#0A0A0A"
            t.cardBorderColorHex = "#666666"
            t.primaryTextColorHex = "#CCCCCC"
            t.secondaryTextColorHex = "#666666"
            t.accentColorHex = "#FFFFFF"
            t.glowColorHex = "#FFFFFF"
            t.glowRadius = 6
            t.glowOpacity = 0.3
        }),
        ("Crimson Grid", { t in
            t.backgroundColorHex = "#0A0005"
            t.cardBackgroundColorHex = "#1A000A"
            t.cardBorderColorHex = "#FF1744"
            t.primaryTextColorHex = "#FF1744"
            t.secondaryTextColorHex = "#880E1F"
            t.accentColorHex = "#FF5252"
            t.glowColorHex = "#FF1744"
            t.glowRadius = 14
            t.glowOpacity = 0.75
        }),
    ]
}
