# Timecount 项目完整文档

## 1. 项目概览

**Timecount** 是一个面向 macOS 的多计时器倒计时应用，具有科幻/霓虹灯风格的视觉主题，支持全屏显示。

### 技术栈
- **语言**: Swift 5.9
- **UI 框架**: SwiftUI
- **数据持久化**: SwiftData
- **平台**: macOS 14.0+
- **包管理**: Swift Package Manager (Package.swift)
- **架构**: arm64 (Apple Silicon)
- **Bundle ID**: `com.timecount.app`
- **版本号**: 1.0 (Build 1)

### 架构模式
采用 **MVVM + Manager 模式**，但不使用严格的 ViewModel 类。各 Manager 作为 `@StateObject` 在 App 根节点创建，通过 SwiftUI 的 `@EnvironmentObject` 传递给整个视图树。业务逻辑集中在 Engine/Manager 层，视图仅负责渲染和用户交互。

```
App Entry (TimecountApp)
  ├── TimerEngine       — 驱动所有计时器的核心引擎
  ├── ThemeManager      — 主题色彩管理
  ├── SoundManager      — 音频播放管理
  ├── WindowManager     — 全屏窗口生命周期管理
  └── ContentView       — 主界面
```

---

## 2. 完整功能列表

### 2.1 多计时器管理
- **功能描述**: 支持同时创建、运行多个独立倒计时器
- **用户交互**: 通过侧边栏"New Timer"按钮或快捷键 Cmd+N 创建新计时器，默认 5 分钟
- **状态**: idle (就绪) -> running (运行中) -> paused (已暂停) / finished (已完成)
- **边缘情况**:
  - 计时器 totalSeconds 为 0 时，播放/暂停按钮被禁用
  - finished 状态点击播放会先 reset 再 start
  - running 状态的计时器在 delete 时会先 pause 再删除

### 2.2 计时器控制
- **播放/暂停**: 通过卡片上的 Play/Pause 按钮，或空格键（针对聚焦的计时器）
- **重置**: 通过 Reset 按钮或 R 键
- **全屏**: 每个计时器可进入独立的边框窗口（borderless window），支持原生全屏切换
- **时间微调**: 运行/暂停状态下可输入相对时间（如 `+30s`、`-5m`）调整剩余时间

### 2.3 预设系统
- **内置预设 (9 个)**: 30s, 1min, 3min, 5min, 10min, 15min, 30min, 1h, 2h
- **自定义预设**: 用户可在设置中创建任意时长的预设（分钟步长）
- **预设应用**: 点击预设应用到聚焦的计时器；若无聚焦计时器则创建新计时器
- **预设删除**: 仅自定义预设可通过滑动删除

### 2.4 时间解析输入
- **绝对时间**: 在 idle 状态下输入 `5m30s` 设置并启动计时器
- **相对时间**: 在 running/paused 状态下输入 `+1m` 或 `-30s` 调整剩余时间
- **实时反馈**: 无效输入时输入框显示红色边框，2 秒后自动清除

### 2.5 全屏模式
- **功能**: 每个计时器可作为独立全屏窗口展示大字体倒计时
- **交互**: 点击画面切换控制按钮显示/隐藏；ESC 退出全屏
- **窗口特性**: borderless + fullSizeContentView，支持原生全屏切换

### 2.6 主题系统
- 6 个内置科幻风格主题，1 个活跃主题
- 支持自定义主题，通过 ColorPicker 和滑条调整颜色和效果
- CRT 扫描线效果和粒子效果可开关

### 2.7 声音提醒
- 三个声音事件：开始(Start)、结束(End)、警告(Warning)
- 分别使用系统声音 Pop、Basso、Funk
- 支持自定义音频文件 (mp3, wav, aiff, m4a)
- 警告阈值可配置（1-30 分钟前触发）
- 全局静音控制

### 2.8 快捷键
| 快捷键 | 功能 |
|--------|------|
| Cmd+N | 新建计时器 |
| Cmd+, | 打开设置 |
| 空格 | 播放/暂停聚焦的计时器 |
| R | 重置聚焦的计时器 |
| ESC | 退出全屏窗口 |

### 2.9 网格布局
- 多计时器以自适应网格布局展示
- 列数可在设置中配置（1-6 列）
- 卡片最小宽度 280px，最大 400px

---

## 3. 架构详解

### 3.1 TimerEngine — 计时引擎

**文件**: `Sources/Timecount/Engine/TimerEngine.swift`

TimerEngine 是整个应用的核心，负责驱动所有计时器的倒计时：

```
TimerEngine (ObservableObject, @MainActor)
├── tick() — 每秒执行一次，遍历所有运行中的计时器
│   ├── 递减 remainingSeconds
│   ├── 触发警告音（剩余时间 <= warningMinutes * 60 秒）
│   ├── 检测计时结束，播放结束音
│   └── 所有计时器停止后自动注销 Timer
├── start(timer:) — 启动计时器
│   ├── 若 remainingSeconds <= 0，重置为 totalSeconds
│   ├── 设置为 .running 状态
│   └── 若从 idle/finished 启动，播放开始音
├── pause(timer:) — 暂停计时器
├── reset(timer:) — 重置为 totalSeconds，状态回到 idle
├── adjustTime(timer:deltaSeconds:) — 调整剩余时间（相对增减）
├── setTime(timer:totalSeconds:) — 设置新总时间并回到 idle
└── stopEngine() — 停止引擎，所有计时器变为 paused
```

**关键设计**:
- 使用 `Timer.publish` + Combine 实现 1 秒精度的 tick
- 引擎仅在有待运行的计时器时运行，无任务时自动停止
- warningTriggeredFor 集合防止警告音重复触发
- 每个 tick 结束后调用 modelContext.save() 持久化

### 3.2 ThemeManager — 主题管理

**文件**: `Sources/Timecount/Managers/ThemeManager.swift`

```
ThemeManager (ObservableObject, @MainActor)
├── activeTheme: ThemeConfiguration — 当前活跃主题
├── applyTheme(_:) — 切换主题（反激活旧主题，激活新主题）
├── resetToFactoryDefaults(in:) — 删除所有自定义主题，激活第一个内置主题
└── 便捷色彩属性: bg, cardBg, cardBorder, primary, secondary, accent, glow
```

### 3.3 SoundManager — 声音管理

**文件**: `Sources/Timecount/Managers/SoundManager.swift`

```
SoundManager (ObservableObject, @MainActor)
├── 三个系统声音: Pop(开始), Basso(结束), Funk(警告)
├── 三个自定义播放器: startPlayer, endPlayer, warningPlayer
├── isMuted / globalVolume 全局控制
├── setCustomSound(url:for:) — 加载自定义音频文件
├── resetToSystemDefault(for:) — 恢复系统默认声音
└── SoundEvent 枚举: start, end, warning
```

### 3.4 WindowManager — 窗口管理

**文件**: `Sources/Timecount/App/WindowManager.swift`

```
WindowManager (ObservableObject, @MainActor)
├── controllers: [UUID: FullscreenWindowController] — 计时器ID到全屏窗口的映射
├── openFullscreen(for:modelContext:) — 创建并显示全屏窗口
├── closeFullscreen(for:) — 关闭指定计时器的全屏窗口
└── isFullscreenOpen(for:) -> Bool — 查询全屏状态
```

### 3.5 DataSeeder — 初始数据播种

**文件**: `Sources/Timecount/App/DataSeeder.swift`

应用启动时检查是否需要播种初始数据：
- 播种 9 个内置预设（仅在无内置预设时）
- 播种 6 个内置主题（仅在无内置主题时），激活第一个（按名称排序）

### 3.6 数据流图

```
用户交互
    │
    ▼
┌─────────────────────────────────────────────────────┐
│                    ContentView                        │
│  ┌──────────┐  ┌──────────────┐  ┌───────────────┐  │
│  │ Sidebar  │  │ MultiTimerGrid│  │   Settings    │  │
│  │ (Presets)│  │  (GridView)   │  │   (TabView)   │  │
│  └────┬─────┘  └───────┬──────┘  └──────┬────────┘  │
│       │                │                 │            │
└───────┼────────────────┼─────────────────┼────────────┘
        │                │                 │
        ▼                ▼                 ▼
┌──────────────┐ ┌──────────────┐ ┌──────────────────┐
│  TimerEngine │ │ WindowManager│ │  ThemeManager    │
│  (tick 引擎) │ │  (全屏窗口)  │ │  (主题色彩)     │
│              │ │              │ │                  │
│  SoundManager│ │              │ │  ThemePresets    │
│  (音频播放)  │ │              │ │  (内置主题数据)  │
└──────┬───────┘ └──────────────┘ └──────────────────┘
       │
       ▼
┌──────────────────────────────────────────────────┐
│                SwiftData ModelContainer           │
│  ┌───────────┐  ┌────────┐  ┌─────────────────┐  │
│  │ TimerModel│  │ Preset │  │ThemeConfiguration│  │
│  └───────────┘  └────────┘  └─────────────────┘  │
└──────────────────────────────────────────────────┘
```

---

## 4. 数据模型

### 4.1 TimerModel

**文件**: `Sources/Timecount/Models/TimerModel.swift`

| 属性 | 类型 | 持久化 | 描述 |
|------|------|--------|------|
| `id` | `UUID` | 是 (@Attribute(.unique)) | 计时器唯一标识，自动生成 |
| `name` | `String` | 是 | 计时器名称，默认空字符串 |
| `totalSeconds` | `Int` | 是 | 总秒数，倒计时的初始值 |
| `remainingSeconds` | `Int` | 是 | 剩余秒数，每秒递减 |
| `statusRawValue` | `String` | 是 | 状态原始值，默认 "idle" |
| `backgroundColorHex` | `String` | 是 | 卡片背景色十六进制值 |
| `sortOrder` | `Int` | 是 | 排序序号，决定网格中的显示顺序 |
| `createdAt` | `Date` | 是 | 创建时间 |
| `warningMinutesOverride` | `Int?` | 是 | 覆盖警告分钟数，nil 使用全局设置 |
| `customEndSoundURL` | `String?` | 是 | 自定义结束音文件路径 |
| `status` | `TimerStatus` | 否 (@Transient) | 计算属性，statusRawValue 的枚举映射 |
| `isRunning` | `Bool` | 否 (@Transient) | status == .running |
| `progress` | `Double` | 否 (@Transient) | remainingSeconds / totalSeconds |
| `displayTime` | `String` | 否 (@Transient) | 格式化显示时间，如 "5:00" |

**Init**: `init(name:totalSeconds:sortOrder:)` — remainingSeconds 初始等于 totalSeconds

### 4.2 Preset

**文件**: `Sources/Timecount/Models/Preset.swift`

| 属性 | 类型 | 持久化 | 描述 |
|------|------|--------|------|
| `id` | `UUID` | 是 (@Attribute(.unique)) | 预设唯一标识 |
| `name` | `String` | 是 | 预设名称，如 "5 minutes" |
| `totalSeconds` | `Int` | 是 | 预设时长秒数 |
| `isBuiltIn` | `Bool` | 是 | 是否为内置预设（内置不可删除） |
| `sortOrder` | `Int` | 是 | 排序序号 |

**Init**: `init(name:totalSeconds:isBuiltIn:sortOrder:)`

### 4.3 ThemeConfiguration

**文件**: `Sources/Timecount/Models/ThemeConfiguration.swift`

| 属性 | 类型 | 默认值 | 描述 |
|------|------|--------|------|
| `id` | `UUID` | 自动生成 | 主题唯一标识 |
| `name` | `String` | "" | 主题名称 |
| `isBuiltIn` | `Bool` | false | 是否为内置主题 |
| `isActive` | `Bool` | false | 是否为当前活跃主题 |
| `backgroundColorHex` | `String` | `#0A0A1A` | 背景色 |
| `cardBackgroundColorHex` | `String` | `#0F0F2A` | 卡片背景色 |
| `cardBorderColorHex` | `String` | `#FF00FF` | 卡片边框色 |
| `primaryTextColorHex` | `String` | `#FF00FF` | 主文本色 |
| `secondaryTextColorHex` | `String` | `#8888AA` | 次文本色 |
| `accentColorHex` | `String` | `#00FFFF` | 强调色 |
| `glowColorHex` | `String` | `#FF00FF` | 发光色 |
| `glowRadius` | `Double` | `12.0` | 发光半径 |
| `glowOpacity` | `Double` | `0.7` | 发光不透明度 |
| `timerFontName` | `String` | `SF Mono` | 计时器字体 |
| `uiFontName` | `String` | `.AppleSystemUIFont` | UI 字体 |
| `timerFontSize` | `Double` | `48.0` | 计时器字号 |
| `useScanlines` | `Bool` | `false` | CRT 扫描线效果开关 |
| `useParticleEffect` | `Bool` | `false` | 粒子效果开关 |
| `borderStyleRaw` | `String` | `"glowing"` | 边框样式 |

**Init**: `init(name:isBuiltIn:)`

---

## 5. 文件清单（35 个 Swift 文件）

### 根目录
| 文件 | 内容 |
|------|------|
| `Package.swift` | SPM 包定义：Swift 5.9, macOS 14+, 可执行目标 Timecount |

### App 入口
| 文件 | 内容 |
|------|------|
| `Sources/Timecount/TimecountApp.swift` | `@main` 入口 `TimecountApp: App`。创建 ModelContainer，初始化所有 Manager，注入 EnvironmentObject |
| `Sources/Timecount/App/DataSeeder.swift` | `DataSeeder` struct，播种 9 个内置预设和 6 个内置主题 |
| `Sources/Timecount/App/WindowManager.swift` | `WindowManager: ObservableObject`，管理 FullscreenWindowController 字典 |

### Models
| 文件 | 内容 |
|------|------|
| `Sources/Timecount/Models/TimerModel.swift` | `TimerModel` @Model，10 个持久化属性 + 4 个 @Transient |
| `Sources/Timecount/Models/Preset.swift` | `Preset` @Model，5 个持久化属性 |
| `Sources/Timecount/Models/ThemeConfiguration.swift` | `ThemeConfiguration` @Model，19 个持久化属性 |

### Engine
| 文件 | 内容 |
|------|------|
| `Sources/Timecount/Engine/TimerEngine.swift` | `TimerEngine: ObservableObject`，计时核心，1秒 tick |
| `Sources/Timecount/Engine/TimeParseEngine.swift` | `TimeParseEngine` struct，正则解析时间字符串 |

### Enums
| 文件 | 内容 |
|------|------|
| `Sources/Timecount/Enums/TimerStatus.swift` | `TimerStatus` 枚举：idle, running, paused, finished |
| `Sources/Timecount/Enums/TimeParseResult.swift` | `TimeParseResult` 枚举：absolute, relative, invalid |

### Extensions
| 文件 | 内容 |
|------|------|
| `Sources/Timecount/Extensions/Color+Hex.swift` | `Color(hex:)` 和 `toHex()`，依赖 AppKit.NSColor |
| `Sources/Timecount/Extensions/TimeInterval+Formatting.swift` | `formatCompact` / `formatFull` 时间格式化 |
| `Sources/Timecount/Extensions/View+Glow.swift` | `neonGlow(color:radius:)` 霓虹发光修饰器 |

### Managers
| 文件 | 内容 |
|------|------|
| `Sources/Timecount/Managers/ThemeManager.swift` | `ThemeManager: ObservableObject`，便捷色彩属性 |
| `Sources/Timecount/Managers/ThemePresets.swift` | `ThemePresets` enum，6 个内置主题配置 |
| `Sources/Timecount/Managers/SoundManager.swift` | `SoundManager: ObservableObject`，NSSound + AVAudioPlayer |

### Views — 主视图
| 文件 | 内容 |
|------|------|
| `Sources/Timecount/Views/ContentView.swift` | 主视图，NavigationSplitView 布局，键盘事件监听 |

### Views — Grid
| 文件 | 内容 |
|------|------|
| `Sources/Timecount/Views/Grid/MultiTimerGridView.swift` | LazyVGrid 自适应布局 |
| `Sources/Timecount/Views/Grid/EmptyStateView.swift` | 空状态占位视图 |

### Views — Timer
| 文件 | 内容 |
|------|------|
| `Sources/Timecount/Views/Timer/TimerCardView.swift` | 计时器卡片，双击重命名，右键菜单 |
| `Sources/Timecount/Views/Timer/TimerDisplayView.swift` | 圆形进度环 + 时间数字 + 状态标签 |
| `Sources/Timecount/Views/Timer/TimerControlsView.swift` | Play/Pause/Reset/Fullscreen 按钮行 |
| `Sources/Timecount/Views/Timer/TimeInputView.swift` | 时间文本输入框 + Apply 按钮 |

### Views — Components
| 文件 | 内容 |
|------|------|
| `Sources/Timecount/Views/Components/CircularProgressView.swift` | 圆形进度环组件 |
| `Sources/Timecount/Views/Components/GlowText.swift` | 霓虹发光文本组件 |
| `Sources/Timecount/Views/Components/GradientBackground.swift` | 动画 AngularGradient 背景 |
| `Sources/Timecount/Views/Components/NeonBorder.swift` | 霓虹边框修饰器 |
| `Sources/Timecount/Views/Components/ScanlineOverlay.swift` | CRT 扫描线 Canvas 叠加层 |
| `Sources/Timecount/Views/Components/SciFiButtonStyle.swift` | 科幻按钮风格 |

### Views — Fullscreen
| 文件 | 内容 |
|------|------|
| `Sources/Timecount/Views/Fullscreen/FullscreenWindowController.swift` | AppKit NSWindowController，borderless 全屏窗口 |
| `Sources/Timecount/Views/Fullscreen/SingleTimerFullscreenView.swift` | 全屏计时器视图内容 |

### Views — Settings
| 文件 | 内容 |
|------|------|
| `Sources/Timecount/Views/Settings/SettingsView.swift` | 设置 TabView + 4 个子视图（General/Sound/Theme/Preset） |

### Views — Theme
| 文件 | 内容 |
|------|------|
| `Sources/Timecount/Views/Theme/ThemeCustomizationView.swift` | 主题自定义表单 |
| `Sources/Timecount/Views/Theme/ThemePreviewCard.swift` | 主题预览卡片 |

---

## 6. 时间解析规范

**实现位置**: `TimeParseEngine` (`Sources/Timecount/Engine/TimeParseEngine.swift`)

### 6.1 正则表达式

```
(\d+)\s*(h(?:ou?rs?)?|m(?:in(?:ute)?s?)?|s(?:ec(?:ond)?s?)?)?
```

### 6.2 接受格式

#### 绝对时间格式（无前缀 / idle 状态）

| 输入示例 | 解析结果 | 备注 |
|----------|----------|------|
| `30` | 30 秒 | 无单位默认为秒 |
| `5m30s` | 330 秒 (5×60+30) | |
| `1h30m` | 5400 秒 | |
| `2 hours` | 7200 秒 | 支持完整拼写 |
| `1h 30m 45s` | 5445 秒 | 空格分隔 |
| `1hour 30min` | 5400 秒 | 支持缩写变体 |
| `90s` | 90 秒 | |
| `1m` | 60 秒 | |

#### 相对时间格式（+/- 前缀 / running/paused 状态）

| 输入示例 | 解析结果 | 效果 |
|----------|----------|------|
| `+30` | relative +30s | 剩余时间 +30s |
| `-1m` | relative -60s | 剩余时间 -60s |
| `+5m30s` | relative +330s | 剩余时间 +330s |

### 6.3 无效输入

| 输入示例 | 原因 |
|----------|------|
| `""` (空字符串) | 空输入 |
| `+` | 仅有符号无数字 |
| `-` | 仅有符号无数字 |
| `+-5m` | 双重符号 |
| `abc` | 无匹配数字 |
| `0` (absolute) | seconds == 0（被 TimeInputView 拒绝） |

### 6.4 边界情况

- 最大时长限制: 359,999 秒（99h 59m 59s）
- adjustTime 中 remainingSeconds 不能为负数
- adjustTime 后若 totalSeconds < remainingSeconds，totalSeconds 自动增大

---

## 7. 六种内置主题

### 1. Neon Nights（默认）
`#0A0A1A` `#0F0F2A` `#FF00FF` `#00FFFF` glow:12

### 2. Cyber Matrix
`#000D00` `#001A00` `#00FF41` glow:14

### 3. Synthwave
`#1A0030` `#2A0040` `#FF6B35` `#E84393` glow:10

### 4. Cold Circuit
`#001020` `#001830` `#0080FF` `#4DA6FF` glow:10

### 5. Void
`#000000` `#0A0A0A` `#CCCCCC` `#FFFFFF` glow:6 opacity:0.3

### 6. Crimson Grid
`#0A0005` `#1A000A` `#FF1744` `#FF5252` glow:14 opacity:0.75

---

## 8. 声音系统

| 事件 | 触发时机 | 系统声音 |
|------|----------|----------|
| Start | 从 idle/finished 启动 | `NSSound("Pop")` |
| End | remainingSeconds 减到 0 | `NSSound("Basso")` |
| Warning | 剩余秒数 <= warningMinutes×60 | `NSSound("Funk")` |

- 警告基于 `warningMinutesOverride ?? 1`（默认 1 分钟）和 `warningTriggeredFor` 去重
- 支持自定义音频文件（mp3, wav, aiff, m4a），使用 AVAudioPlayer

---

## 9. 键盘快捷键

| 快捷键 | 功能 |
|--------|------|
| Cmd+N | 新建计时器 |
| Cmd+, | 打开设置 |
| Space | 播放/暂停聚焦的计时器 |
| R | 重置聚焦的计时器 |
| ESC | 退出全屏窗口 |

- 空格和 R 仅在不按住 Cmd 时触发
- ESC 在 MainWindow 透传，在 Fullscreen 消费

---

## 10. 构建与运行

```bash
# Debug 构建
cd /Users/yaoxiong/Downloads/APP开发/Timecount
DEVELOPER_DIR="/Applications/Xcode.app/Contents/Developer" swift build

# Release 构建
DEVELOPER_DIR="/Applications/Xcode.app/Contents/Developer" swift build -c release

# 运行 App Bundle
open /Users/yaoxiong/Downloads/APP开发/Timecount/Timecount.app
```

### App Bundle 结构
```
Timecount.app/
└── Contents/
    ├── Info.plist        — com.timecount.app, v1.0, macOS 14.0+
    ├── MacOS/Timecount   — arm64 可执行文件
    ├── Resources/
    │   └── AppIcon.icns  — 赛博朋克风格图标
    ├── PkgInfo           — "APPL????"
    └── _CodeSignature/
```

### 环境要求
- macOS 14.0+ (Sonoma)
- Xcode 15.0+ (Xcode.app Developer 目录，非 Command Line Tools)
- Apple Silicon (arm64)

---

**生成日期**: 2026-05-09
**源文件总数**: 35 个 Swift 文件
**项目根目录**: `/Users/yaoxiong/Downloads/APP开发/Timecount`
