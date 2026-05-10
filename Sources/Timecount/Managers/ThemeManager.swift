import SwiftUI
import SwiftData

@MainActor
final class ThemeManager: ObservableObject {
    @Published var activeTheme: ThemeConfiguration

    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        self.activeTheme = ThemeConfiguration(name: "Neon Nights")
        loadActiveTheme()
    }

    func applyTheme(_ theme: ThemeConfiguration) {
        // Deactivate previous active theme
        if activeTheme.id != theme.id {
            let prevID = activeTheme.id
            var descriptor = FetchDescriptor<ThemeConfiguration>()
            descriptor.predicate = #Predicate { $0.id == prevID }
            if let prev = try? modelContext.fetch(descriptor).first {
                prev.isActive = false
            }
        }
        theme.isActive = true
        activeTheme = theme
        try? modelContext.save()
    }

    func resetToFactoryDefaults(in context: ModelContext) {
        // Remove all custom themes
        var customDescriptor = FetchDescriptor<ThemeConfiguration>()
        customDescriptor.predicate = #Predicate { $0.isBuiltIn == false }
        if let customs = try? context.fetch(customDescriptor) {
            for c in customs { context.delete(c) }
        }
        // Deactivate all, then activate first built-in
        let allDescriptor = FetchDescriptor<ThemeConfiguration>()
        if let all = try? context.fetch(allDescriptor) {
            for t in all { t.isActive = false }
        }
        var firstDescriptor = FetchDescriptor<ThemeConfiguration>()
        firstDescriptor.predicate = #Predicate { $0.isBuiltIn == true }
        firstDescriptor.sortBy = [SortDescriptor(\.name)]
        firstDescriptor.fetchLimit = 1
        if let first = try? context.fetch(firstDescriptor).first {
            first.isActive = true
            activeTheme = first
        }
        try? context.save()
    }

    var bg: Color { Color(hex: activeTheme.backgroundColorHex) }
    var cardBg: Color { Color(hex: activeTheme.cardBackgroundColorHex) }
    var cardBorder: Color { Color(hex: activeTheme.cardBorderColorHex) }
    var primary: Color { Color(hex: activeTheme.primaryTextColorHex) }
    var secondary: Color { Color(hex: activeTheme.secondaryTextColorHex) }
    var accent: Color { Color(hex: activeTheme.accentColorHex) }
    var glow: Color { Color(hex: activeTheme.glowColorHex) }

    private func loadActiveTheme() {
        var descriptor = FetchDescriptor<ThemeConfiguration>()
        descriptor.predicate = #Predicate { $0.isActive == true }
        descriptor.fetchLimit = 1
        if let theme = try? modelContext.fetch(descriptor).first {
            activeTheme = theme
        }
    }
}
