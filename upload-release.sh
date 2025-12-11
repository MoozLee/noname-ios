#!/bin/bash

# GitHub Release 上传脚本
# 使用方法: ./upload-release.sh [tag] [ipa_file_path] [github_token]

set -e

# 颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# 配置
REPO_OWNER="MoozLee"
REPO_NAME="noname-ios"
TAG_NAME="${1:-v1.0.0}"
IPA_FILE="${2:-platforms/ios/build/export/无名杀.ipa}"
GITHUB_TOKEN="${3:-${GITHUB_TOKEN}}"

# 检查参数
if [ -z "$GITHUB_TOKEN" ]; then
    echo -e "${RED}错误: 需要GitHub Token${NC}"
    echo "使用方法:"
    echo "  1. 设置环境变量: export GITHUB_TOKEN=your_token"
    echo "  2. 或作为参数传递: ./upload-release.sh v1.0.0 path/to/file.ipa your_token"
    echo ""
    echo "获取Token: https://github.com/settings/tokens"
    exit 1
fi

# 检查IPA文件是否存在
if [ ! -f "$IPA_FILE" ]; then
    echo -e "${RED}错误: IPA文件不存在: ${IPA_FILE}${NC}"
    exit 1
fi

echo -e "${GREEN}开始上传IPA到GitHub Release...${NC}"
echo -e "仓库: ${REPO_OWNER}/${REPO_NAME}"
echo -e "标签: ${TAG_NAME}"
echo -e "文件: ${IPA_FILE}"
echo ""

# 获取文件信息
FILE_NAME=$(basename "$IPA_FILE")
FILE_SIZE=$(stat -f%z "$IPA_FILE" 2>/dev/null || stat -c%s "$IPA_FILE" 2>/dev/null)
FILE_SIZE_MB=$(echo "scale=2; $FILE_SIZE / 1024 / 1024" | bc)

echo -e "${YELLOW}文件大小: ${FILE_SIZE_MB} MB${NC}"

# API端点
API_BASE="https://api.github.com/repos/${REPO_OWNER}/${REPO_NAME}"

# 检查release是否存在
echo -e "${YELLOW}检查Release是否存在...${NC}"
RELEASE_RESPONSE=$(curl -s -w "\n%{http_code}" \
    -H "Authorization: token ${GITHUB_TOKEN}" \
    -H "Accept: application/vnd.github.v3+json" \
    "${API_BASE}/releases/tags/${TAG_NAME}")

HTTP_CODE=$(echo "$RELEASE_RESPONSE" | tail -n1)
RELEASE_DATA=$(echo "$RELEASE_RESPONSE" | sed '$d')

if [ "$HTTP_CODE" = "404" ]; then
    # 创建新的release
    echo -e "${YELLOW}创建新的Release...${NC}"
    RELEASE_RESPONSE=$(curl -s -w "\n%{http_code}" \
        -X POST \
        -H "Authorization: token ${GITHUB_TOKEN}" \
        -H "Accept: application/vnd.github.v3+json" \
        -H "Content-Type: application/json" \
        -d "{
            \"tag_name\": \"${TAG_NAME}\",
            \"name\": \"无名杀 iOS ${TAG_NAME}\",
            \"body\": \"## 无名杀 iOS 版本 ${TAG_NAME}\\n\\n### 安装说明\\n\\n1. 下载IPA文件\\n2. 使用AltStore、Sideloadly或其他工具安装到iOS设备\\n\\n### 注意事项\\n\\n- 需要iOS 11.0或更高版本\\n- 首次安装需要信任开发者证书\\n- 文件大小: ${FILE_SIZE_MB} MB\",
            \"draft\": false,
            \"prerelease\": false
        }" \
        "${API_BASE}/releases")
    
    HTTP_CODE=$(echo "$RELEASE_RESPONSE" | tail -n1)
    RELEASE_DATA=$(echo "$RELEASE_RESPONSE" | sed '$d')
    
    if [ "$HTTP_CODE" != "201" ]; then
        echo -e "${RED}创建Release失败 (HTTP ${HTTP_CODE})${NC}"
        echo "$RELEASE_DATA" | jq '.' 2>/dev/null || echo "$RELEASE_DATA"
        exit 1
    fi
    
    echo -e "${GREEN}Release创建成功${NC}"
else
    if [ "$HTTP_CODE" != "200" ]; then
        echo -e "${RED}获取Release失败 (HTTP ${HTTP_CODE})${NC}"
        echo "$RELEASE_DATA" | jq '.' 2>/dev/null || echo "$RELEASE_DATA"
        exit 1
    fi
    
    echo -e "${GREEN}Release已存在${NC}"
    
    # 检查是否已存在同名文件
    UPLOAD_URL=$(echo "$RELEASE_DATA" | jq -r '.upload_url' | sed 's/{?name,label}//')
    EXISTING_ASSETS=$(echo "$RELEASE_DATA" | jq -r '.assets[] | select(.name == "'"$FILE_NAME"'") | .id')
    
    if [ -n "$EXISTING_ASSETS" ]; then
        echo -e "${YELLOW}删除已存在的文件...${NC}"
        for ASSET_ID in $EXISTING_ASSETS; do
            curl -s -X DELETE \
                -H "Authorization: token ${GITHUB_TOKEN}" \
                -H "Accept: application/vnd.github.v3+json" \
                "${API_BASE}/releases/assets/${ASSET_ID}"
        done
    fi
fi

# 获取上传URL
UPLOAD_URL=$(echo "$RELEASE_DATA" | jq -r '.upload_url' | sed 's/{?name,label}//')
if [ -z "$UPLOAD_URL" ] || [ "$UPLOAD_URL" = "null" ]; then
    # 如果从创建响应中获取
    UPLOAD_URL=$(echo "$RELEASE_DATA" | jq -r '.upload_url' | sed 's/{?name,label}//')
fi

echo -e "${YELLOW}上传IPA文件 (这可能需要几分钟)...${NC}"

# 上传文件
UPLOAD_RESPONSE=$(curl -s -w "\n%{http_code}" \
    -X POST \
    -H "Authorization: token ${GITHUB_TOKEN}" \
    -H "Accept: application/vnd.github.v3+json" \
    -H "Content-Type: application/octet-stream" \
    --data-binary "@${IPA_FILE}" \
    "${UPLOAD_URL}?name=${FILE_NAME}")

UPLOAD_HTTP_CODE=$(echo "$UPLOAD_RESPONSE" | tail -n1)
UPLOAD_DATA=$(echo "$UPLOAD_RESPONSE" | sed '$d')

if [ "$UPLOAD_HTTP_CODE" = "201" ]; then
    DOWNLOAD_URL=$(echo "$UPLOAD_DATA" | jq -r '.browser_download_url')
    echo -e "${GREEN}✓ IPA文件上传成功!${NC}"
    echo -e "下载地址: ${DOWNLOAD_URL}"
    echo ""
    echo -e "${GREEN}Release页面: https://github.com/${REPO_OWNER}/${REPO_NAME}/releases/tag/${TAG_NAME}${NC}"
else
    echo -e "${RED}上传失败 (HTTP ${UPLOAD_HTTP_CODE})${NC}"
    echo "$UPLOAD_DATA" | jq '.' 2>/dev/null || echo "$UPLOAD_DATA"
    exit 1
fi

echo -e "${GREEN}完成!${NC}"

