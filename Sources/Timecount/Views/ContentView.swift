import SwiftUI
import SwiftData

struct ContentView: View {
    @EnvironmentObject var timerEngine: TimerEngine
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var windowManager: WindowManager

    @Query(sort: \TimerModel.sortOrder) private var timers: [TimerModel]
    @Query(sort: \ThemeConfiguration.name) private var allThemes: [ThemeConfiguration]
    @Environment(\.modelContext) private var modelContext
    @State private var showSettings = false
    @State private var quickInput = ""
    @State private var themeIndex = 0

    var body: some View {
        HStack(spacing: 0) {
            // Sidebar
            sidebar
                .frame(width: 200)
                .background(themeManager.bg)

            // Main content
            mainContent
                .background(themeManager.bg)
        }
        .sheet(isPresented: $showSettings) {
            SettingsView()
        }
    }

    // MARK: - Sidebar

    private var sidebar: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header
            Text("预设时长")
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(themeManager.primary)
                .padding(.horizontal, 16)
                .padding(.top, 16)
                .padding(.bottom, 10)

            // Preset list
            ScrollView {
                VStack(spacing: 6) {
                    PresetListView(onSelectPreset: createTimerFromPreset)
                }
                .padding(.horizontal, 10)
                .padding(.bottom, 16)
            }

            Divider()
                .overlay(themeManager.cardBorder.opacity(0.3))

            // Settings button at bottom
            VStack(spacing: 6) {
                Button(action: { showSettings = true }) {
                    HStack {
                        Image(systemName: "gear")
                        Text("设置")
                    }
                    .font(.system(size: 13))
                    .foregroundStyle(themeManager.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 6)
                            .fill(Color.white.opacity(0.03))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 6)
                            .strokeBorder(themeManager.cardBorder.opacity(0.2), lineWidth: 1)
                    )
                }
                .buttonStyle(.plain)
            }
            .padding(10)
        }
        .background(themeManager.bg)
    }

    // MARK: - Main Content

    private var mainContent: some View {
        VStack(spacing: 0) {
            // Quick input bar
            quickInputBar
                .padding(.horizontal, 12)
                .padding(.top, 12)
                .padding(.bottom, 8)

            if timers.isEmpty {
                EmptyStateView(onAdd: {})
            } else {
                MultiTimerGridView(timers: timers)
            }
        }
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button(action: { showSettings = true }) {
                    Label("设置", systemImage: "gear")
                }
                .keyboardShortcut(",")
            }
        }
    }

    private var quickInputBar: some View {
        HStack(spacing: 8) {
            NeonTextField(
                placeholder: "输入时间后回车，快速创建倒计时",
                text: $quickInput,
                borderColor: themeManager.accent.opacity(0.35),
                font: .system(size: 13, design: .monospaced),
                onSubmit: createTimerFromQuickInput
            )

            Image(systemName: "return")
                .foregroundStyle(themeManager.accent.opacity(0.4))
                .font(.caption)
        }
        .padding(8)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(themeManager.cardBg)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .strokeBorder(themeManager.cardBorder.opacity(0.25), lineWidth: 1)
        )
    }

    // MARK: - Timer creation

    private func createTimerFromQuickInput() {
        guard !quickInput.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        let result = TimeParseEngine.parse(quickInput)

        switch result {
        case .absolute(let seconds):
            guard seconds > 0 else { return }
            let timer = createTimer(seconds: seconds)
            timerEngine.start(timer: timer)
            quickInput = ""
        case .relative(let seconds):
            let total = max(1, seconds)
            let timer = createTimer(seconds: total)
            timerEngine.start(timer: timer)
            quickInput = ""
        case .invalid:
            return
        }
    }

    private func createTimerFromPreset(_ preset: Preset) {
        let timer = createTimer(seconds: preset.totalSeconds, name: preset.name)
        timerEngine.start(timer: timer)
    }

    private func createTimer(seconds: Int, name: String? = nil) -> TimerModel {
        let maxOrder = timers.map(\.sortOrder).max() ?? -1
        let timerName = name ?? "计时器 \(timers.count + 1)"

        let theme = allThemes.isEmpty ? nil : allThemes[themeIndex % allThemes.count]
        themeIndex += 1

        let timer = TimerModel(
            name: timerName,
            totalSeconds: seconds,
            sortOrder: maxOrder + 1
        )
        if let bgHex = theme?.cardBackgroundColorHex {
            timer.backgroundColorHex = bgHex
        }
        modelContext.insert(timer)
        try? modelContext.save()
        return timer
    }
}

// MARK: - Preset List (card-style)

struct PresetListView: View {
    @Query(filter: #Predicate<Preset> { $0.showInSidebar == true },
           sort: \Preset.sortOrder) private var visiblePresets: [Preset]
    @EnvironmentObject var themeManager: ThemeManager
    @Environment(\.modelContext) private var modelContext
    let onSelectPreset: (Preset) -> Void

    var body: some View {
        ForEach(visiblePresets) { preset in
            PresetRow(preset: preset, onSelect: { onSelectPreset(preset) }, onDelete: {
                if !preset.isBuiltIn {
                    modelContext.delete(preset)
                    try? modelContext.save()
                }
            })
        }
    }
}

struct PresetRow: View {
    let preset: Preset
    let onSelect: () -> Void
    var onDelete: (() -> Void)? = nil
    @EnvironmentObject var themeManager: ThemeManager
    @State private var isHovered = false

    var body: some View {
        Button(action: onSelect) {
            HStack {
                Text(preset.name)
                    .font(.system(size: 13))
                    .foregroundStyle(isHovered ? themeManager.primary : themeManager.secondary)
                Spacer()
                Text(TimeInterval.formatCompact(preset.totalSeconds))
                    .font(.system(size: 11, design: .monospaced))
                    .foregroundStyle(isHovered ? themeManager.accent : themeManager.accent.opacity(0.7))
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
        }
        .buttonStyle(.plain)
        .contentShape(Rectangle())
        .background(
            RoundedRectangle(cornerRadius: 6)
                .fill(isHovered ? themeManager.cardBg : themeManager.cardBg.opacity(0.6))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 6)
                .strokeBorder(
                    isHovered ? themeManager.cardBorder.opacity(0.6) : themeManager.cardBorder.opacity(0.2),
                    lineWidth: isHovered ? 1.5 : 1
                )
        )
        .onHover { hovering in
            withAnimation(.easeInOut(duration: 0.15)) {
                isHovered = hovering
            }
        }
        .contextMenu {
            if let onDelete = onDelete, !preset.isBuiltIn {
                Button("删除", role: .destructive, action: onDelete)
            }
        }
    }
}
