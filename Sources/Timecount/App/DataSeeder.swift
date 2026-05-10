import Foundation
import SwiftData

struct DataSeeder {
    static func seedIfNeeded(in context: ModelContext) {
        seedPresets(in: context)
        seedThemes(in: context)
    }

    private static func seedPresets(in context: ModelContext) {
        var descriptor = FetchDescriptor<Preset>()
        descriptor.predicate = #Predicate { $0.isBuiltIn == true }
        guard let count = try? context.fetchCount(descriptor), count == 0 else { return }

        let presets: [(String, Int)] = [
            ("30 seconds", 30),
            ("1 minute", 60),
            ("3 minutes", 180),
            ("5 minutes", 300),
            ("10 minutes", 600),
            ("15 minutes", 900),
            ("30 minutes", 1800),
            ("1 hour", 3600),
            ("2 hours", 7200),
        ]

        for (index, (name, seconds)) in presets.enumerated() {
            context.insert(Preset(name: name, totalSeconds: seconds, isBuiltIn: true, sortOrder: index))
        }
        try? context.save()
    }

    private static func seedThemes(in context: ModelContext) {
        var descriptor = FetchDescriptor<ThemeConfiguration>()
        descriptor.predicate = #Predicate { $0.isBuiltIn == true }
        guard let count = try? context.fetchCount(descriptor), count == 0 else { return }

        for (name, configure) in ThemePresets.all {
            let theme = ThemeConfiguration(name: name, isBuiltIn: true)
            configure(theme)
            context.insert(theme)
        }
        // Activate the first theme
        var themeDescriptor = FetchDescriptor<ThemeConfiguration>()
        themeDescriptor.predicate = #Predicate { $0.isBuiltIn == true }
        themeDescriptor.sortBy = [SortDescriptor(\.name)]
        themeDescriptor.fetchLimit = 1
        if let firstTheme = try? context.fetch(themeDescriptor).first {
            firstTheme.isActive = true
        }
        try? context.save()
    }
}
