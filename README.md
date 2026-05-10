# Timecount

面向 macOS 的多计时器倒计时应用，赛博朋克霓虹科幻风格界面，支持全屏展示与独立卡片配色。

<img width="1000" height="692" alt="iShot_2026-05-10_15 10 06" src="https://github.com/user-attachments/assets/537cc3f5-5ce1-410a-8c67-4633b53b1e0e" />

## 功能特性

- **多计时器管理** — 同时创建最多 8 个独立倒计时器，网格布局一行 4 卡，无需滚动
- **智能时间输入** — 支持 `5m30s`、`1h30m` 等自然时间格式，运行中可通过 `+1m` / `-30s` 动态调整
- **卡片独立配色** — 每张卡片可自定义背景色、文字色、进度环色，主题与个性并存
- **预设系统** — 内置常用预设（30s ~ 2h），支持自定义预设并显示在侧边栏/菜单栏
- **全屏模式** — 双击卡片进入沉浸式全屏，空格键切换播放/暂停，适合演讲、课堂等场景
- **6 套科幻主题** — Neon Nights、Cyber Matrix、Synthwave、Cold Circuit、Void、Crimson Grid
- **自定义主题** — 支持调整背景色、边框色、发光线、字体等，打造专属风格
- **声音提醒** — 开始/结束/警告三种声音事件，支持自定义音频文件
- **CRT 扫描线 & 粒子效果** — 可选复古 CRT 扫描线叠加和动态粒子效果
- **菜单栏快捷入口** — 菜单栏图标一键启动预设计时器
- **8 款 LCD 数字字体** — 内置 LiquidCrystal、DS-Digital 等经典 LCD 字体，默认 LiquidCrystal
- **中文字体** — 全界面中文统一使用 AaXiaoGouGuaiGuaiXiangSuTi-2 像素字体

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
| `Space` | 播放/暂停聚焦的计时器（全屏模式同样适用） |
| `R` | 重置聚焦的计时器 |
| `ESC` | 退出全屏窗口 |
| `,` | 打开设置 |

## 项目结构

```
Sources/Timecount/
├── App/                    # 应用入口 & 数据初始化
├── Engine/                 # 计时引擎 & 时间解析
├── Enums/                  # 枚举定义
├── Extensions/             # Swift 扩展
├── Managers/               # 主题管理 & 声音管理 & 字体管理
├── Models/                 # SwiftData 数据模型
├── Resources/              # 字体 & 图片资源
└── Views/
    ├── Components/         # 可复用 UI 组件（网格背景、霓虹 Logo 等）
    ├── Fullscreen/         # 全屏窗口 & 控制器
    ├── Grid/               # 网格布局 & 空状态
    ├── MenuBar/            # 菜单栏入口
    ├── Settings/           # 设置面板
    ├── Theme/              # 主题自定义
    └── Timer/              # 计时器卡片 & 控制 & 显示
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
