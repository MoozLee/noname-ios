# GitHub Release 上传指南

## 快速开始

### 1. 获取GitHub Personal Access Token

1. 访问 https://github.com/settings/tokens
2. 点击 "Generate new token" → "Generate new token (classic)"
3. 设置权限：
   - ✅ `repo` (完整仓库访问权限)
4. 生成并复制Token

### 2. 设置环境变量

```bash
export GITHUB_TOKEN=your_token_here
```

### 3. 执行上传脚本

```bash
./upload-release.sh v1.0.0 platforms/ios/build/export/无名杀.ipa
```

或者直接传递token：

```bash
./upload-release.sh v1.0.0 platforms/ios/build/export/无名杀.ipa your_token_here
```

## 手动上传方式

如果脚本无法使用，可以手动上传：

1. 访问 https://github.com/MoozLee/noname-ios/releases
2. 点击 "Draft a new release" 或编辑现有release
3. 选择标签 `v1.0.0`
4. 填写Release信息
5. 拖拽IPA文件到 "Attach binaries" 区域
6. 点击 "Publish release"

## 使用GitHub CLI (推荐)

如果安装了GitHub CLI (`gh`):

```bash
# 安装 (如果未安装)
brew install gh

# 登录
gh auth login

# 创建release并上传文件
gh release create v1.0.0 \
  platforms/ios/build/export/无名杀.ipa \
  --title "无名杀 iOS v1.0.0" \
  --notes "## 无名杀 iOS 版本 v1.0.0

### 安装说明

1. 下载IPA文件
2. 使用AltStore、Sideloadly或其他工具安装到iOS设备

### 注意事项

- 需要iOS 11.0或更高版本
- 首次安装需要信任开发者证书
- 文件大小: 1.4GB"
```

## 脚本参数说明

```bash
./upload-release.sh [tag] [ipa_file] [github_token]
```

- `tag`: Release标签 (默认: v1.0.0)
- `ipa_file`: IPA文件路径 (默认: platforms/ios/build/export/无名杀.ipa)
- `github_token`: GitHub Token (可选，优先使用环境变量)

## 故障排除

### 错误: 需要GitHub Token
- 确保设置了 `GITHUB_TOKEN` 环境变量
- 或作为第三个参数传递token

### 错误: IPA文件不存在
- 检查文件路径是否正确
- 确保已运行 `./build-ipa.sh` 生成IPA文件

### 上传失败: 文件过大
- GitHub单个文件限制为2GB
- 当前IPA文件约1.4GB，应该可以上传

### 权限错误
- 确保token有 `repo` 权限
- 检查token是否过期

