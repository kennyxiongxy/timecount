import SwiftUI
import SwiftData
import UniformTypeIdentifiers
import AppKit

// MARK: - Container

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var selectedTab = 0

    var body: some View {
        VStack(spacing: 0) {
            // Header: tab bar + close button
            HStack(alignment: .center) {
                Picker("", selection: $selectedTab) {
                    Text("通用").tag(0)
                    Text("声音").tag(1)
                    Text("主题").tag(2)
                    Text("预设").tag(3)
                }
                .pickerStyle(.segmented)
                .frame(width: 300)

                Spacer()

                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(.white)
                        .frame(width: 20, height: 20)
                        .background(Circle().fill(Color.red))
                }
                .buttonStyle(.plain)
                .help("关闭")
                .keyboardShortcut(.cancelAction)
            }
            .padding(.horizontal, 16)
            .padding(.top, 14)

            Divider().padding(.top, 10)

            // Content
            VStack {
                switch selectedTab {
                case 0: GeneralSettingsView()
                case 1: SoundSettingsView()
                case 2: ThemeSettingsView()
                case 3: PresetManagementView()
                default: EmptyView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        }
        .frame(minWidth: 560, minHeight: 460)
    }
}

// MARK: - General

struct GeneralSettingsView: View {
    @AppStorage("timerFontName") private var fontName = "SF Mono"
    @State private var allFonts: [String] = NSFontManager.shared.availableFontFamilies

    var body: some View {
        ScrollView {
            Form {
                Section {
                    Text("自动适配：每行最多显示 4 个倒计时")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Section("计时器字体") {
                    Picker("字体", selection: $fontName) {
                        ForEach(allFonts, id: \.self) { name in
                            Text(name).tag(name)
                        }
                    }
                    .frame(height: 180)

                    // Preview
                    VStack(spacing: 4) {
                        Text("预览")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .frame(maxWidth: .infinity, alignment: .leading)

                        Text("01:30:00")
                            .font(.custom(fontName, size: 32))
                            .foregroundStyle(.primary)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color.black.opacity(0.3))
                            )
                    }
                }
            }
            .padding()
        }
    }
}

// MARK: - Sound

struct SoundSettingsView: View {
    @AppStorage("warningMinutes") private var warningMinutes = 1
    @AppStorage("startSoundMode") private var startModeRaw = SoundMode.system.rawValue
    @AppStorage("endSoundMode") private var endModeRaw = SoundMode.system.rawValue
    @AppStorage("warningSoundMode") private var warningModeRaw = SoundMode.system.rawValue
    @AppStorage("startBuiltIn") private var startBuiltIn = ""
    @AppStorage("endBuiltIn") private var endBuiltIn = ""
    @AppStorage("warningBuiltIn") private var warningBuiltIn = ""

    @EnvironmentObject var soundManager: SoundManager
    @State private var startCustom: URL? = nil
    @State private var endCustom: URL? = nil
    @State private var warningCustom: URL? = nil

    private var startMode: Binding<SoundMode> {
        Binding(get: { SoundMode(rawValue: startModeRaw) ?? .system },
                set: { startModeRaw = $0.rawValue })
    }
    private var endMode: Binding<SoundMode> {
        Binding(get: { SoundMode(rawValue: endModeRaw) ?? .system },
                set: { endModeRaw = $0.rawValue })
    }
    private var warningMode: Binding<SoundMode> {
        Binding(get: { SoundMode(rawValue: warningModeRaw) ?? .system },
                set: { warningModeRaw = $0.rawValue })
    }

    private var builtInNames: [String] { SoundManager.builtInSoundNames() }

    private func applyPersistedSettings() {
        for (modeRaw, builtIn, event) in [(startModeRaw, startBuiltIn, SoundManager.SoundEvent.start),
                                           (endModeRaw, endBuiltIn, .end),
                                           (warningModeRaw, warningBuiltIn, .warning)] {
            let mode = SoundMode(rawValue: modeRaw) ?? .system
            soundManager.setDisabled(mode == .off, for: event)
            if mode == .system {
                soundManager.resetToSystemDefault(for: event)
            } else if mode == .builtIn, !builtIn.isEmpty {
                soundManager.loadBuiltInSound(named: builtIn, for: event)
            }
        }
    }

    enum SoundMode: String, CaseIterable { case system = "系统默认", builtIn = "内置铃声", custom = "自定义文件", off = "关闭" }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                soundEventSection(title: "开始提示音", systemName: "Pop",
                                  mode: startMode, builtInName: $startBuiltIn, customURL: $startCustom,
                                  event: .start)

                Divider().padding(.vertical, 8)

                soundEventSection(title: "结束提示音", systemName: "Basso",
                                  mode: endMode, builtInName: $endBuiltIn, customURL: $endCustom,
                                  event: .end)

                Divider().padding(.vertical, 8)

                soundEventSection(title: "预警提示音", systemName: "Funk",
                                  mode: warningMode, builtInName: $warningBuiltIn, customURL: $warningCustom,
                                  event: .warning)

                Divider().padding(.vertical, 8)

                VStack(alignment: .leading, spacing: 6) {
                    Text("预警时间").font(.headline)
                    HStack {
                        Text("结束前").foregroundStyle(.secondary)
                        TextField("", value: $warningMinutes, format: .number)
                            .textFieldStyle(.roundedBorder)
                            .frame(width: 50)
                            .multilineTextAlignment(.center)
                        Text("分钟提醒")
                            .foregroundStyle(.secondary)
                    }
                }
                .padding(.vertical, 4)
            }
            .padding()
        }
        .onAppear { applyPersistedSettings() }
    }

    private func soundEventSection(
        title: String, systemName: String,
        mode: Binding<SoundMode>, builtInName: Binding<String>, customURL: Binding<URL?>,
        event: SoundManager.SoundEvent
    ) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title).font(.headline)

            Picker("来源", selection: mode) {
                ForEach(SoundMode.allCases, id: \.self) { m in Text(m.rawValue).tag(m) }
            }
            .pickerStyle(.segmented)
            .onChange(of: mode.wrappedValue) { _, newMode in
                soundManager.setDisabled(newMode == .off, for: event)
                if newMode == .off { soundManager.resetToSystemDefault(for: event) }
            }

            switch mode.wrappedValue {
            case .off:
                Text("已关闭").font(.caption).foregroundStyle(.tertiary)
                    .onAppear { soundManager.setDisabled(true, for: event) }

            case .system:
                HStack {
                    Image(systemName: "speaker.wave.2.fill").font(.caption).foregroundStyle(.secondary)
                    Text("系统默认（\(systemName)）").font(.caption).foregroundStyle(.secondary)
                    Spacer()
                    Button("试听") {
                        soundManager.resetToSystemDefault(for: event)
                        previewSound(for: event)
                    }
                    .buttonStyle(.borderless).font(.caption)
                }

            case .builtIn:
                HStack {
                    Picker("铃声", selection: builtInName) {
                        Text("选择铃声").tag("")
                        ForEach(builtInNames, id: \.self) { name in
                            Text(name).tag(name)
                        }
                    }
                    .onChange(of: builtInName.wrappedValue) { _, newName in
                        if !newName.isEmpty {
                            soundManager.loadBuiltInSound(named: newName, for: event)
                        }
                    }
                    Spacer()
                    if !builtInName.wrappedValue.isEmpty {
                        Button("试听") { previewSound(for: event) }
                            .buttonStyle(.borderless).font(.caption)
                    }
                }

            case .custom:
                HStack {
                    if let fileURL = customURL.wrappedValue {
                        Text(fileURL.lastPathComponent).font(.caption).foregroundStyle(.primary).lineLimit(1)
                        Button("清除") {
                            customURL.wrappedValue = nil
                            soundManager.resetToSystemDefault(for: event)
                        }
                        .buttonStyle(.borderless).font(.caption)
                    } else {
                        Text("未选择文件").font(.caption).foregroundStyle(.tertiary)
                    }
                    Spacer()
                    Button("选择文件...") {
                        if let url = openSoundFilePicker() {
                            customURL.wrappedValue = url
                            soundManager.setCustomSound(url: url, for: event)
                        }
                    }
                    .buttonStyle(.borderless).font(.caption)
                    if customURL.wrappedValue != nil {
                        Button("试听") { previewSound(for: event) }
                            .buttonStyle(.borderless).font(.caption)
                    }
                }
            }
        }
    }

    private func previewSound(for event: SoundManager.SoundEvent) {
        switch event {
        case .start:  soundManager.playStartSound()
        case .end:    soundManager.playEndSound()
        case .warning: soundManager.playWarningSound()
        }
    }

    private func openSoundFilePicker() -> URL? {
        let panel = NSOpenPanel()
        panel.allowedContentTypes = [.mp3, .wav, .aiff, UTType(filenameExtension: "m4a")].compactMap { $0 }
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = false
        panel.message = "选择音频文件"
        return panel.runModal() == .OK ? panel.url : nil
    }
}

// MARK: - Theme

struct ThemeSettingsView: View {
    @Query(filter: #Predicate<ThemeConfiguration> { $0.isBuiltIn == true },
           sort: \ThemeConfiguration.name) private var builtInThemes: [ThemeConfiguration]
    @Query(filter: #Predicate<ThemeConfiguration> { $0.isBuiltIn == false },
           sort: \ThemeConfiguration.name) private var customThemes: [ThemeConfiguration]
    @EnvironmentObject var themeManager: ThemeManager
    @Environment(\.modelContext) private var modelContext
    @State private var showCustomizer = false
    @State private var customizingTheme: ThemeConfiguration?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                Text("内置主题").font(.headline)
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 120))], spacing: 12) {
                    ForEach(builtInThemes) { theme in
                        ThemePreviewCard(
                            theme: theme,
                            isSelected: theme.id == themeManager.activeTheme.id,
                            onSelect: { themeManager.applyTheme(theme) }
                        )
                    }
                }

                if !customThemes.isEmpty {
                    Text("自定义主题").font(.headline).padding(.top)
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 120))], spacing: 12) {
                        ForEach(customThemes) { theme in
                            ThemePreviewCard(
                                theme: theme,
                                isSelected: theme.id == themeManager.activeTheme.id,
                                onSelect: { themeManager.applyTheme(theme) }
                            )
                        }
                    }
                }

                HStack {
                    Button("新建自定义主题") {
                        let newTheme = ThemeConfiguration(name: "自定义 \(customThemes.count + 1)")
                        modelContext.insert(newTheme)
                        try? modelContext.save()
                        customizingTheme = newTheme
                        showCustomizer = true
                    }
                    Button("恢复出厂设置") {
                        themeManager.resetToFactoryDefaults(in: modelContext)
                    }
                }
                .padding(.top)
            }
            .padding()
        }
        .sheet(isPresented: $showCustomizer) {
            if let theme = customizingTheme {
                ThemeCustomizationView(theme: theme)
            }
        }
    }
}

// MARK: - Preset

struct PresetManagementView: View {
    @Query(sort: \Preset.sortOrder) private var presets: [Preset]
    @Environment(\.modelContext) private var modelContext
    @State private var newPresetName = ""
    @State private var newHours = 0
    @State private var newMinutes = 5
    @State private var newSeconds = 0

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("管理预设时长").font(.headline)

            List {
                ForEach(presets) { preset in
                    HStack {
                        Toggle(isOn: Binding(
                            get: { preset.showInSidebar },
                            set: { preset.showInSidebar = $0; try? modelContext.save() }
                        )) {
                            Text(preset.name)
                        }
                        Spacer()
                        Text(TimeInterval.formatFull(preset.totalSeconds))
                            .foregroundStyle(.secondary)
                            .font(.caption.monospaced())
                        if !preset.isBuiltIn {
                            Button {
                                modelContext.delete(preset)
                                try? modelContext.save()
                            } label: {
                                Image(systemName: "xmark.circle.fill")
                                    .font(.caption)
                                    .foregroundStyle(.red.opacity(0.7))
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.vertical, 2)
                }
            }
            .listStyle(.plain)
            .frame(minHeight: 200)

            GroupBox("添加自定义预设") {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("名称")
                            .frame(width: 40, alignment: .leading)
                        TextField("例如：番茄钟", text: $newPresetName)
                            .textFieldStyle(.roundedBorder)
                            .frame(width: 160)
                    }

                    HStack(spacing: 6) {
                        Text("时长")
                            .frame(width: 40, alignment: .leading)
                        TextField("0", value: $newHours, format: .number)
                            .textFieldStyle(.roundedBorder)
                            .frame(width: 50)
                            .multilineTextAlignment(.center)
                        Text("时")
                            .font(.caption).foregroundStyle(.secondary)

                        TextField("5", value: $newMinutes, format: .number)
                            .textFieldStyle(.roundedBorder)
                            .frame(width: 50)
                            .multilineTextAlignment(.center)
                        Text("分")
                            .font(.caption).foregroundStyle(.secondary)

                        TextField("0", value: $newSeconds, format: .number)
                            .textFieldStyle(.roundedBorder)
                            .frame(width: 50)
                            .multilineTextAlignment(.center)
                        Text("秒")
                            .font(.caption).foregroundStyle(.secondary)

                        Spacer()

                        Button("添加") {
                            guard !newPresetName.isEmpty else { return }
                            let total = newHours * 3600 + newMinutes * 60 + newSeconds
                            guard total > 0 else { return }
                            let preset = Preset(
                                name: newPresetName,
                                totalSeconds: total,
                                sortOrder: presets.count
                            )
                            modelContext.insert(preset)
                            try? modelContext.save()
                            newPresetName = ""
                            newHours = 0
                            newMinutes = 5
                            newSeconds = 0
                        }
                        .disabled(newPresetName.isEmpty)
                    }
                }
            }
        }
        .padding()
    }
}
