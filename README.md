# Timecount

面向 macOS 的多计时器倒计时应用，赛博朋克/霓虹灯科幻风格界面，支持全屏展示。
<img width="1000" height="692" alt="iShot_2026-05-10_15 10 06" src="https://github.com/user-attachments/assets/537cc3f5-5ce1-410a-8c67-4633b53b1e0e" />


## 功能特性

- **多计时器管理** — 同时创建、运行多个独立倒计时器，网格布局自适应排列
- **智能时间输入** — 支持 `5m30s`、`1h30m` 等自然时间格式，运行中可通过 `+1m` / `-30s` 动态调整
- **预设系统** — 内置 9 个常用预设（30s ~ 2h），支持自定义预设
- **全屏模式** — 每个计时器可独立进入全屏窗口，适合演讲、教室等场景
- **6 套科幻主题** — Neon Nights、Cyber Matrix、Synthwave、Cold Circuit、Void、Crimson Grid
- **自定义主题** — 支持调整背景色、边框色、发光线、字体等，打造专属风格
- **声音提醒** — 开始/结束/警告三种声音事件，支持自定义音频文件
- **CRT 扫描线 & 粒子效果** — 可选复古 CRT 扫描线叠加和动态粒子效果
- **键盘快捷键** — 完整的键盘操作支持

## 系统要求

- macOS 14.0+ (Sonoma)
- Apple Silicon (arm64)
- Xcode 15.0+

## 快速开始

```bash
# 克隆仓库
git clone https://github.com/kennyxiongxy/timecount.git
cd timecount

# Debug 构建
DEVELOPER_DIR="/Applications/Xcode.app/Contents/Developer" swift build

# Release 构建
DEVELOPER_DIR="/Applications/Xcode.app/Contents/Developer" swift build -c release

# 运行
open Timecount.app
```

## 技术栈

- **语言**: Swift 5.9
- **UI**: SwiftUI
- **数据持久化**: SwiftData
- **架构**: MVVM + Manager 模式
- **包管理**: Swift Package Manager

## 键盘快捷键

| 快捷键 | 功能 |
|--------|------|
| `Cmd + N` | 新建计时器 |
| `Cmd + ,` | 打开设置 |
| `Space` | 播放/暂停聚焦的计时器 |
| `R` | 重置聚焦的计时器 |
| `ESC` | 退出全屏窗口 |

## 项目结构

```
Sources/Timecount/
├── App/                    # 应用入口 & 窗口管理
├── Engine/                 # 计时引擎 & 时间解析
├── Enums/                  # 枚举定义
├── Extensions/             # Swift 扩展
├── Managers/               # 主题管理 & 声音管理
├── Models/                 # SwiftData 数据模型
└── Views/
    ├── Components/         # 可复用 UI 组件
    ├── Fullscreen/         # 全屏窗口
    ├── Grid/               # 网格布局
    ├── Settings/           # 设置面板
    ├── Theme/              # 主题自定义
    └── Timer/              # 计时器卡片 & 控制
```

## 内置主题

| 主题 | 风格 |
|------|------|
| Neon Nights | 紫红霓虹，默认主题 |
| Cyber Matrix | 绿色矩阵，黑客帝国风 |
| Synthwave | 橙紫合成波，80 年代复古 |
| Cold Circuit | 蓝白冷光，极简科技感 |
| Void | 黑白灰，极暗风格 |
| Crimson Grid | 红黑深红，警示风格 |

## License

MIT
