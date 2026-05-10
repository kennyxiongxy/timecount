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
    @State private var showMaxTimerAlert = false

    var body: some View {
        HStack(spacing: 0) {
            // Sidebar
            sidebar
                .frame(width: 220)
                .background(themeManager.bg)

            Divider()
                .overlay(themeManager.cardBorder.opacity(0.15))

            // Main content
            mainContent
                .background(themeManager.bg)
        }
        .overlay(
            CyberGridBackground(
                lineColor: themeManager.cardBorder.opacity(0.06),
                lineSpacing: 44
            )
            .ignoresSafeArea()
        )
        .sheet(isPresented: $showSettings) {
            SettingsView()
        }
        .alert("提示", isPresented: $showMaxTimerAlert) {
            Button("确定", role: .cancel) {}
        } message: {
            Text("最多只能创建 8 个计时器")
                .font(.custom("AaXiaoGouGuaiGuaiXiangSuTi-2", size: 13))
        }
    }

    // MARK: - Sidebar

    private var sidebar: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Brand header
            brandHeader
                .padding(.horizontal, 16)
                .padding(.top, 20)
                .padding(.bottom, 16)

            // Navigation-style preset list
            VStack(alignment: .leading, spacing: 0) {
                HStack(spacing: 6) {
                    Image(systemName: "bolt.fill")
                        .font(.system(size: 10))
                        .foregroundStyle(themeManager.accent.opacity(0.7))
                    Text("快速预设")
                        .font(.custom("AaXiaoGouGuaiGuaiXiangSuTi-2", size: 11))
                        .foregroundStyle(themeManager.secondary)
                        .textCase(.uppercase)
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 8)

                ScrollView {
                    VStack(spacing: 4) {
                        PresetListView(onSelectPreset: createTimerFromPreset)
                    }
                    .padding(.horizontal, 12)
                    .padding(.bottom, 8)
                }
            }

            Divider()
                .overlay(themeManager.cardBorder.opacity(0.12))
                .padding(.horizontal, 12)
                .padding(.vertical, 8)

            // System Status decoration
            systemStatusBlock
                .padding(.horizontal, 16)
                .padding(.bottom, 8)

            Spacer()

            Divider()
                .overlay(themeManager.cardBorder.opacity(0.12))
                .padding(.horizontal, 12)

            // Settings button
            Button(action: { showSettings = true }) {
                HStack(spacing: 10) {
                    Image(systemName: "gearshape.fill")
                        .font(.system(size: 12))
                    Text("设置")
                        .font(.custom("AaXiaoGouGuaiGuaiXiangSuTi-2", size: 13))
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.system(size: 10))
                        .foregroundStyle(themeManager.secondary.opacity(0.5))
                }
                .foregroundStyle(themeManager.secondary)
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.white.opacity(0.02))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .strokeBorder(themeManager.cardBorder.opacity(0.15), lineWidth: 1)
                )
            }
            .buttonStyle(.plain)
            .padding(12)
        }
        .background(themeManager.bg)
    }

    private var brandHeader: some View {
        HStack {
            NeonLogoView()
        }
    }

    private var systemStatusBlock: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 6) {
                Image(systemName: "cpu")
                    .font(.system(size: 10))
                    .foregroundStyle(themeManager.accent.opacity(0.6))
                Text("系统状态")
                    .font(.custom("AaXiaoGouGuaiGuaiXiangSuTi-2", size: 10))
                    .foregroundStyle(themeManager.secondary.opacity(0.7))
            }

            VStack(alignment: .leading, spacing: 6) {
                statusRow(label: "计时器", value: "\(timers.count) 个活跃")
                statusRow(label: "运行中", value: "\(timers.filter(\.isRunning).count) 个")
                statusRow(label: "系统", value: "在线")

                // Mini waveform decoration
                HStack(spacing: 2) {
                    ForEach(0..<16, id: \.self) { i in
                        RoundedRectangle(cornerRadius: 1)
                            .fill(themeManager.accent.opacity(0.3 + Double.random(in: 0...0.4)))
                            .frame(width: 2, height: CGFloat.random(in: 4...14))
                    }
                }
                .frame(height: 16)
                .padding(.top, 4)
            }
        }
    }

    private func statusRow(label: String, value: String) -> some View {
        HStack {
            Text(label)
                .font(.custom("AaXiaoGouGuaiGuaiXiangSuTi-2", size: 10))
                .foregroundStyle(themeManager.secondary.opacity(0.5))
            Spacer()
            Text(value)
                .font(.custom("AaXiaoGouGuaiGuaiXiangSuTi-2", size: 10))
                .foregroundStyle(themeManager.accent.opacity(0.7))
        }
    }

    // MARK: - Main Content

    private var mainContent: some View {
        VStack(spacing: 0) {
            // Top title bar
            HStack {
                HStack(spacing: 6) {
                    Image(systemName: "timer")
                        .font(.system(size: 14))
                        .foregroundStyle(themeManager.accent)
                    Text("我的计时器")
                        .font(.custom("AaXiaoGouGuaiGuaiXiangSuTi-2", size: 15))
                        .foregroundStyle(themeManager.primary)
                }

                Spacer()

                HStack(spacing: 12) {
                    // Active timer count
                    HStack(spacing: 4) {
                        Circle()
                            .fill(themeManager.accent)
                            .frame(width: 6, height: 6)
                        Text("\(timers.filter(\.isRunning).count) 运行中")
                            .font(.custom("AaXiaoGouGuaiGuaiXiangSuTi-2", size: 11))
                            .foregroundStyle(themeManager.secondary)
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 16)
            .padding(.bottom, 12)

            // Quick input bar
            quickInputBar
                .padding(.horizontal, 16)
                .padding(.bottom, 12)

            if timers.isEmpty {
                EmptyStateView(onAdd: {})
            } else {
                MultiTimerGridView(timers: timers)
            }
        }
    }

    private var quickInputBar: some View {
        HStack(spacing: 8) {
            Image(systemName: "terminal")
                .font(.system(size: 11))
                .foregroundStyle(themeManager.accent.opacity(0.5))

            NeonTextField(
                placeholder: "输入时间后回车，快速创建倒计时",
                text: $quickInput,
                borderColor: themeManager.accent.opacity(0.35),
                font: .custom("AaXiaoGouGuaiGuaiXiangSuTi-2", size: 13),
                onSubmit: createTimerFromQuickInput
            )

            Image(systemName: "return")
                .foregroundStyle(themeManager.accent.opacity(0.4))
                .font(.caption)
        }
        .padding(10)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(themeManager.cardBg.opacity(0.6))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .strokeBorder(themeManager.cardBorder.opacity(0.2), lineWidth: 1)
        )
    }

    // MARK: - Timer creation

    private func createTimerFromQuickInput() {
        guard !quickInput.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        let result = TimeParseEngine.parse(quickInput)

        switch result {
        case .absolute(let seconds):
            guard seconds > 0 else { return }
            guard let timer = createTimer(seconds: seconds) else {
                showMaxTimerAlert = true
                return
            }
            timerEngine.start(timer: timer)
            quickInput = ""
        case .relative(let seconds):
            let total = max(1, seconds)
            guard let timer = createTimer(seconds: total) else {
                showMaxTimerAlert = true
                return
            }
            timerEngine.start(timer: timer)
            quickInput = ""
        case .invalid:
            return
        }
    }

    private func createTimerFromPreset(_ preset: Preset) {
        guard let timer = createTimer(seconds: preset.totalSeconds, name: preset.name) else {
            showMaxTimerAlert = true
            return
        }
        timerEngine.start(timer: timer)
    }

    private func createTimer(seconds: Int, name: String? = nil) -> TimerModel? {
        guard timers.count < 8 else { return nil }
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

// MARK: - Preset List (nav-style)

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
            HStack(spacing: 10) {
                // Small green indicator
                RoundedRectangle(cornerRadius: 1)
                    .fill(themeManager.accent.opacity(isHovered ? 0.9 : 0.5))
                    .frame(width: 3, height: 16)

                Text(preset.name)
                    .font(.system(size: 12, design: .monospaced))
                    .foregroundStyle(isHovered ? themeManager.primary : themeManager.secondary)

                Spacer()

                Text(TimeInterval.formatCompact(preset.totalSeconds))
                    .font(.system(size: 11, design: .monospaced))
                    .foregroundStyle(isHovered ? themeManager.accent : themeManager.accent.opacity(0.6))
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 7)
        }
        .buttonStyle(.plain)
        .contentShape(Rectangle())
        .background(
            RoundedRectangle(cornerRadius: 6)
                .fill(isHovered ? themeManager.cardBg.opacity(0.8) : Color.clear)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 6)
                .strokeBorder(
                    isHovered ? themeManager.cardBorder.opacity(0.4) : Color.clear,
                    lineWidth: 1
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
