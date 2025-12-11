# 无名杀 iOS 版

这是「无名杀」三国杀游戏的 iOS 移动端应用，基于 Apache Cordova 框架开发。

## 项目简介

无名杀是一款开源的三国杀卡牌游戏，本项目为其 iOS 移动端实现版本。通过 Cordova 技术将 Web 应用打包为原生 iOS 应用，保持了游戏的完整功能和体验。

## 技术栈

- **Apache Cordova**: 混合应用开发框架
- **Cordova iOS**: iOS 平台支持（v7.1.0）
- **WKWebView**: iOS 高性能 WebView 引擎
- **JavaScript/HTML5/CSS3**: 核心游戏逻辑和界面

## 使用的 Cordova 插件

- `cordova-plugin-file`: 文件系统访问
- `cordova-plugin-ionic-webview`: 增强的 WebView 支持
- `cordova-plugin-splashscreen`: 启动画面
- `cordova-plugin-statusbar`: 状态栏控制
- `cordova-plugin-whitelist`: 安全白名单配置
- `cordova-plugin-wkwebview-file-xhr`: WKWebView 文件访问支持

## 环境要求

### 开发环境
- **macOS**: 需要 macOS 系统（用于 iOS 开发）
- **Xcode**: 最新版本（从 Mac App Store 安装）
- **Xcode Command Line Tools**: 
  ```bash
  xcode-select --install
  ```
- **Node.js**: v14.0.0 或更高版本
- **npm**: v6.0.0 或更高版本
- **Cordova CLI**: 全局安装
  ```bash
  npm install -g cordova
  ```
- **CocoaPods**: iOS 依赖管理工具
  ```bash
  sudo gem install cocoapods
  ```

### 运行要求
- **iOS 设备**: iPhone/iPad（iOS 11.0 或更高版本）
- **iOS 模拟器**: 通过 Xcode 提供

## 安装步骤

### 1. 克隆项目
```bash
git clone git@github.com:MoozLee/noname-ios.git
cd noname-ios
```

### 2. 安装依赖
```bash
npm install
```

### 3. 添加 iOS 平台
```bash
cordova platform add ios
```

### 4. 安装 CocoaPods 依赖
```bash
cd platforms/ios
pod install
cd ../..
```

## 构建和运行

### 在模拟器中运行
```bash
cordova emulate ios
```

### 在真机上运行
```bash
cordova run ios --device
```

### 构建发布版本
```bash
cordova build ios --release
```

### 使用 Xcode 构建
1. 打开 Xcode 项目：
   ```bash
   open platforms/ios/无名杀.xcworkspace
   ```
2. 在 Xcode 中选择目标设备
3. 点击 Run 按钮（⌘+R）或 Build 按钮（⌘+B）

## 项目结构

```
noname-ios/
├── config.xml              # Cordova 项目配置文件
├── package.json            # Node.js 依赖配置
├── package-lock.json       # 依赖版本锁定文件
├── www/                    # 游戏资源目录（Web 应用）
│   ├── index.html         # 主入口页面
│   ├── noname.js          # 游戏核心脚本
│   ├── service-worker.js  # Service Worker
│   ├── audio/             # 音频资源（背景音乐、音效）
│   ├── card/              # 卡牌素材
│   ├── character/         # 武将素材
│   ├── css/               # 样式文件
│   ├── extension/         # 扩展包
│   ├── font/              # 字体文件
│   ├── game/              # 游戏逻辑代码
│   ├── image/             # 图片资源
│   ├── layout/            # 布局配置
│   ├── mode/              # 游戏模式
│   └── theme/             # 主题样式
├── platforms/              # Cordova 平台代码（自动生成）
└── plugins/                # Cordova 插件（自动生成）
```

## 配置说明

### config.xml
主要配置项：
- **App ID**: `com.noname.game`
- **App 名称**: 无名杀
- **版本号**: 1.0.0
- **内容入口**: `index.html`

### 修改配置
如需修改应用配置，请编辑 `config.xml` 文件，然后重新构建：
```bash
cordova prepare ios
```

## 开发调试

### 查看日志
```bash
cordova run ios --device --consolelogs
```

### 在 Safari 中调试
1. 在 iOS 设备上：设置 → Safari → 高级 → 启用"Web 检查器"
2. 在 Mac 上：Safari → 开发 → [你的设备名] → 选择应用页面
3. 使用 Safari 开发者工具进行调试

### 常见问题

#### 1. 构建失败：找不到开发者证书
- 在 Xcode 中打开项目
- 选择项目 Target → Signing & Capabilities
- 配置你的开发团队（Team）

#### 2. 插件安装失败
```bash
# 清除插件缓存
cordova plugin remove [plugin-name]
cordova plugin add [plugin-name]
```

#### 3. CocoaPods 依赖问题
```bash
cd platforms/ios
pod repo update
pod install
```

## 许可证

本项目使用 Apache License 2.0 许可证。详见项目中的 LICENSE 文件。

## 资源说明

项目包含大量游戏资源：
- **音频文件**: 约 7,300+ 个音效和背景音乐文件（MP3 格式）
- **图片资源**: 约 6,000+ 个武将、卡牌、背景图片（JPG/PNG/WebP 格式）
- **字体文件**: 多个中文字体文件（TTF 格式）
- **总大小**: 约 1.5GB

## 贡献

欢迎提交 Issue 和 Pull Request！

## 相关链接

- [Cordova 官方文档](https://cordova.apache.org/docs/en/latest/)
- [Cordova iOS 平台指南](https://cordova.apache.org/docs/en/latest/guide/platforms/ios/)
- [无名杀官方项目](https://github.com/libccy/noname)

## 作者

MoozLee

---

**注意**: 本项目仅供学习交流使用，请勿用于商业用途。
