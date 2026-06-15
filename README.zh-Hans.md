# ArXiv Finder

<p align="center">
  <strong>一款用于发现、筛选和阅读 arXiv 论文的原生 SwiftUI 应用。</strong>
</p>

<p align="center">
  <img alt="Platform" src="https://img.shields.io/badge/Platform-macOS%20%7C%20iOS-0A84FF">
  <img alt="SwiftUI" src="https://img.shields.io/badge/UI-SwiftUI-34C759">
  <img alt="Persistence" src="https://img.shields.io/badge/Data-SwiftData-FF9F0A">
  <img alt="API" src="https://img.shields.io/badge/API-arXiv-5E5CE6">
  <img alt="Version" src="https://img.shields.io/badge/Version-2.0.0-0A84FF">
</p>

<p align="center">
  <a href="README.md">English</a> · <strong>简体中文</strong>
</p>

## 2.0 版本新特性

- **App Sandbox（应用沙盒）+ 强化运行时（Hardened Runtime）**，并配置网络客户端权限（面向分发的安全模型）。
- **设置即时生效**——切换自动刷新或修改刷新间隔现在会在运行时立即应用。
- **PDF 更快更流畅**——PDF 在后台线程加载（界面不再卡顿），并通过本地磁盘缓存提供，缓存会遵循开关与大小上限。
- **更可靠**——更安全的收藏持久化、带校验的 PDF 下载（检查 HTTP 状态码与 `%PDF` 标识）、网络超时，以及本地存储无法打开时的优雅降级。
- **更精致的界面**——更小的最小窗口、纯英文文案、无障碍标签，以及可调整大小的设置窗口。

## 概述

ArXiv Finder 是一款跨平台的 Apple 应用（macOS + iOS），让你可以：

- 按 arXiv 主要学科浏览最新论文
- 通过关键词搜索论文，并按类别筛选
- 按日期、标题或引用数排序结果
- 收藏论文并通过本地存储持久保存
- 在应用内阅读论文详情与 PDF
- 通过内置的“设置”页面自定义行为与界面

该应用使用 SwiftUI 构建，采用 SwiftData 进行持久化，并依赖 [ArxivKit](https://github.com/ivicamil/ArxivKit) 进行 arXiv API 查询。

## 截图

### 主工作区
![ArXiv Finder 主工作区](Screenshots/app-overview.png)

### 内置 PDF 阅读器
![ArXiv Finder PDF 阅读器](Screenshots/app-pdf-view.png)

### 设置
![ArXiv Finder 设置](Screenshots/app-settings.png)

## 主要功能

- 类别浏览：
  - 最新（Latest）
  - 计算机科学（Computer Science）
  - 数学（Mathematics）
  - 物理（Physics）
  - 定量生物学（Quantitative Biology）
  - 定量金融（Quantitative Finance）
  - 统计学（Statistics）
  - 电气工程（Electrical Engineering）
  - 经济学（Economics）
- 强大的搜索：
  - 基于查询的搜索，支持类别筛选
  - 搜索历史快捷入口
- 排序控件：
  - 日期
  - 标题
  - 引用数
- 阅读流程：
  - 丰富的详情面板（作者、日期、摘要、类别、链接）
  - 通过 PDFKit 内置渲染 PDF
  - PDF 的下载/分享操作
- 收藏：
  - 在列表和详情页一键切换收藏
  - 通过 SwiftData 持久保存收藏状态
- 可配置的应用行为：
  - 每次加载的最大论文数
  - 默认类别
  - 自动刷新与刷新间隔
  - 强调色、紧凑模式、摘要预览、字体大小
  - PDF 缓存开关与清除缓存

## 系统要求

- macOS 15.5 或更高版本（用于 macOS 应用）
- 支持现代 SwiftUI/SwiftData 的 Xcode（用于从源码构建）
- 用于从 arXiv 获取论文的网络连接

## 安装与运行

### 方式一：通过 DMG 安装（推荐普通用户）

1. 下载最新的 `ArXiv-Finder-<版本号>-macOS.dmg`。
2. 打开 DMG。
3. 将 `ArXiv Finder.app` 拖入 `Applications`（应用程序）。
4. 从“应用程序”启动。

如果 macOS 在首次启动时阻止运行，请右键点击该应用，选择“打开”，然后确认。

### 方式二：从源码构建并运行

```bash
git clone https://github.com/linroger/ArXiv-Finder.git
cd ArXiv-Finder
open "ArXiv Finder.xcodeproj"
```

随后在 Xcode 中选择 `ArXiv Finder` scheme 并运行。

命令行构建（macOS 目标）：

```bash
xcodebuild \
  -project "ArXiv Finder.xcodeproj" \
  -scheme "ArXiv Finder" \
  -destination "platform=macOS" \
  build
```

## 制作 DMG 安装包

本仓库包含一个打包脚本：

```bash
./scripts/build-dmg.sh
```

输出：

- DMG 文件：`dist/ArXiv-Finder-<营销版本号>-macOS.dmg`
- Release 应用包（位于 derived data）：`.build-macos/Build/Products/Release/ArXiv Finder.app`

## 如何使用

1. 启动 `ArXiv Finder`。
2. 从侧边栏（macOS）或类别菜单（iOS）选择一个类别。
3. 使用排序菜单按日期、标题或引用数重新排序。
4. 打开一篇论文以查看详情，并在“详情（Details）”与“PDF”之间切换。
5. 点击/轻点心形图标以添加/移除收藏。
6. 使用搜索页面执行关键词搜索并按类别筛选。
7. 打开“设置”以配置刷新行为、界面偏好与缓存选项。

## 架构概览

```text
ArXiv Finder/
├── Models/
│   └── ArXivPaper.swift
├── Services/
│   └── ArXivService.swift
├── Controllers/
│   └── ArXivController.swift
├── Views/
│   ├── MainView.swift
│   ├── SidebarView.swift
│   ├── PapersListView.swift
│   ├── SearchResultsView.swift
│   ├── PaperDetailView.swift
│   ├── ArXivPaperRow.swift
│   ├── PDFKitView.swift
│   └── SettingsView.swift
└── Managers/
    └── CacheManager.swift
```

## 说明与当前行为

- 引用数是**根据论文 id 派生的确定性示意占位值**（arXiv 不提供引用数）。该值在刷新之间保持稳定，因此按引用数排序是一致的。
- PDF 缓存由 `CacheManager` 处理：它遵循缓存开关与配置的大小上限（最旧优先淘汰），并可在“设置”中清除。
- 搜索使用基于 ArxivKit 的查询，并支持按类别筛选。
- macOS 应用在 **App Sandbox（应用沙盒）** 下运行；DMG 构建经过 ad-hoc 签名并启用强化运行时，但**未经过公证（notarization）**，因此首次启动需要右键 →“打开”这一 Gatekeeper 步骤。

## 测试与冒烟检查

```bash
# 轻量级项目冒烟检查
./init.sh

# 构建
xcodebuild -project "ArXiv Finder.xcodeproj" -scheme "ArXiv Finder" -destination "platform=macOS" build

# 运行单元测试
xcodebuild -project "ArXiv Finder.xcodeproj" -scheme "ArXiv Finder" -destination "platform=macOS" test
```

共享 scheme 会运行**单元测试**（`ArXiv FinderTests`）。UI 测试（`ArXiv FinderUITests`）在 scheme 中被有意跳过，因为 UI 测试运行器无法在无界面/CI 环境中初始化；如有需要，可在桌面会话中重新启用它们。

## 许可证

本仓库当前未包含许可证文件。
