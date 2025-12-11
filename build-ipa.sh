#!/bin/bash

# 无名杀 iOS 项目 IPA 构建脚本
# 使用方法: ./build-ipa.sh [development|ad-hoc|app-store|enterprise]

set -e

# 颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# 配置
PROJECT_NAME="无名杀"
WORKSPACE_NAME="${PROJECT_NAME}.xcworkspace"
SCHEME_NAME="${PROJECT_NAME}"
BUILD_DIR="$(pwd)/platforms/ios/build"
ARCHIVE_PATH="${BUILD_DIR}/archives/${PROJECT_NAME}.xcarchive"
EXPORT_PATH="${BUILD_DIR}/export"
IPA_PATH="${EXPORT_PATH}/${PROJECT_NAME}.ipa"

# 导出方法 (development, ad-hoc, app-store, enterprise)
EXPORT_METHOD="${1:-development}"

echo -e "${GREEN}开始构建 IPA 文件...${NC}"
echo -e "项目名称: ${PROJECT_NAME}"
echo -e "导出方法: ${EXPORT_METHOD}"
echo ""

# 切换到iOS平台目录
cd "$(dirname "$0")/platforms/ios"

# 检查workspace是否存在
if [ ! -d "${WORKSPACE_NAME}" ]; then
    echo -e "${RED}错误: 找不到 ${WORKSPACE_NAME}${NC}"
    exit 1
fi

# 清理之前的构建
echo -e "${YELLOW}清理之前的构建...${NC}"
rm -rf "${BUILD_DIR}"
mkdir -p "${BUILD_DIR}/archives"
mkdir -p "${BUILD_DIR}/export"

# 创建Archive
echo -e "${YELLOW}正在创建 Archive...${NC}"
xcodebuild clean archive \
    -workspace "${WORKSPACE_NAME}" \
    -scheme "${SCHEME_NAME}" \
    -configuration Release \
    -archivePath "${ARCHIVE_PATH}" \
    CODE_SIGN_IDENTITY="" \
    CODE_SIGNING_REQUIRED=NO \
    CODE_SIGNING_ALLOWED=NO \
    PROVISIONING_PROFILE_SPECIFIER="" \
    || {
    echo -e "${RED}Archive 创建失败，尝试使用自动签名...${NC}"
    xcodebuild clean archive \
        -workspace "${WORKSPACE_NAME}" \
        -scheme "${SCHEME_NAME}" \
        -configuration Release \
        -archivePath "${ARCHIVE_PATH}" \
        -allowProvisioningUpdates
}

if [ ! -d "${ARCHIVE_PATH}" ]; then
    echo -e "${RED}错误: Archive 创建失败${NC}"
    exit 1
fi

echo -e "${GREEN}Archive 创建成功: ${ARCHIVE_PATH}${NC}"

# 创建ExportOptions.plist
echo -e "${YELLOW}创建导出配置...${NC}"
EXPORT_OPTIONS_PLIST="${BUILD_DIR}/ExportOptions.plist"
cat > "${EXPORT_OPTIONS_PLIST}" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>method</key>
    <string>${EXPORT_METHOD}</string>
    <key>teamID</key>
    <string></string>
    <key>compileBitcode</key>
    <false/>
    <key>uploadSymbols</key>
    <false/>
    <key>signingStyle</key>
    <string>automatic</string>
</dict>
</plist>
EOF

# 导出IPA
echo -e "${YELLOW}正在导出 IPA...${NC}"
xcodebuild -exportArchive \
    -archivePath "${ARCHIVE_PATH}" \
    -exportPath "${EXPORT_PATH}" \
    -exportOptionsPlist "${EXPORT_OPTIONS_PLIST}" \
    -allowProvisioningUpdates \
    || {
    echo -e "${YELLOW}使用无签名方式导出...${NC}"
    # 如果导出失败，尝试手动创建IPA
    APP_PATH="${ARCHIVE_PATH}/Products/Applications/${PROJECT_NAME}.app"
    if [ -d "${APP_PATH}" ]; then
        echo -e "${YELLOW}手动打包 IPA...${NC}"
        mkdir -p "${EXPORT_PATH}/Payload"
        cp -r "${APP_PATH}" "${EXPORT_PATH}/Payload/"
        cd "${EXPORT_PATH}"
        zip -r "${PROJECT_NAME}.ipa" Payload
        rm -rf Payload
        echo -e "${GREEN}IPA 文件已创建: ${IPA_PATH}${NC}"
    else
        echo -e "${RED}错误: 找不到 .app 文件${NC}"
        exit 1
    fi
}

# 检查IPA文件
if [ -f "${IPA_PATH}" ]; then
    IPA_SIZE=$(du -h "${IPA_PATH}" | cut -f1)
    echo -e "${GREEN}✓ IPA 文件生成成功!${NC}"
    echo -e "文件路径: ${IPA_PATH}"
    echo -e "文件大小: ${IPA_SIZE}"
elif [ -f "${EXPORT_PATH}/${PROJECT_NAME}.ipa" ]; then
    IPA_SIZE=$(du -h "${EXPORT_PATH}/${PROJECT_NAME}.ipa" | cut -f1)
    echo -e "${GREEN}✓ IPA 文件生成成功!${NC}"
    echo -e "文件路径: ${EXPORT_PATH}/${PROJECT_NAME}.ipa"
    echo -e "文件大小: ${IPA_SIZE}"
else
    echo -e "${YELLOW}警告: 未找到标准IPA文件，检查导出目录...${NC}"
    ls -lh "${EXPORT_PATH}"
fi

echo -e "${GREEN}构建完成!${NC}"

