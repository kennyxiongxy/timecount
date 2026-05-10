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
            ("30秒", 30),
            ("1分钟", 60),
            ("3分钟", 180),
            ("5分钟", 300),
            ("10分钟", 600),
            ("15分钟", 900),
            ("30分钟", 1800),
            ("1小时", 3600),
            ("2小时", 7200),
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
