import Foundation
import SwiftData

@Model
final class Preset {
    @Attribute(.unique) var id: UUID = UUID()
    var name: String = ""
    var totalSeconds: Int = 0
    var isBuiltIn: Bool = false
    var showInSidebar: Bool = true
    var sortOrder: Int = 0

    init(name: String, totalSeconds: Int, isBuiltIn: Bool = false, showInSidebar: Bool = true, sortOrder: Int = 0) {
        self.name = name
        self.totalSeconds = totalSeconds
        self.isBuiltIn = isBuiltIn
        self.showInSidebar = showInSidebar
        self.sortOrder = sortOrder
    }
}
