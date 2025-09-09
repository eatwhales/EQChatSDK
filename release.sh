#!/bin/bash
#
# release.sh - EQChatSDK自动发布脚本
# 用于自动化版本发布、标签创建和CocoaPods推送
#

set -e  # 遇到错误立即退出

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 打印带颜色的消息
print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# 检查参数
if [ $# -eq 0 ]; then
    print_error "请提供版本号，例如: ./release.sh 1.0.0"
    exit 1
fi

VERSION=$1
print_info "准备发布版本: $VERSION"

# 检查是否在git仓库中
if ! git rev-parse --git-dir > /dev/null 2>&1; then
    print_error "当前目录不是git仓库"
    exit 1
fi

# 检查工作区是否干净
if [ -n "$(git status --porcelain)" ]; then
    print_warning "工作区有未提交的更改"
    git status --short
    read -p "是否继续？(y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        print_info "发布已取消"
        exit 1
    fi
fi

# 更新podspec版本
print_info "更新podspec版本到 $VERSION"
sed -i '' "s/spec.version.*=.*/spec.version      = \"$VERSION\"/" EQChatSDK.podspec

# 验证podspec
print_info "验证podspec文件"
if command -v pod >/dev/null 2>&1; then
    pod spec lint EQChatSDK.podspec --allow-warnings
    if [ $? -ne 0 ]; then
        print_error "podspec验证失败"
        exit 1
    fi
    print_success "podspec验证通过"
else
    print_warning "未安装CocoaPods，跳过podspec验证"
fi

# 提交更改
print_info "提交版本更新"
git add .
git commit -m "Release version $VERSION"

# 创建标签
print_info "创建git标签: v$VERSION"
git tag -a "v$VERSION" -m "Release version $VERSION"

# 推送到远程仓库
print_info "推送到远程仓库"
git push origin main
git push origin "v$VERSION"

# 推送到CocoaPods（可选）
read -p "是否推送到CocoaPods Trunk？(y/N): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    if command -v pod >/dev/null 2>&1; then
        print_info "推送到CocoaPods Trunk"
        pod trunk push EQChatSDK.podspec --allow-warnings
        print_success "已推送到CocoaPods Trunk"
    else
        print_error "未安装CocoaPods，无法推送到Trunk"
    fi
fi

print_success "版本 $VERSION 发布完成！"
print_info "GitHub Release: https://github.com/yourusername/EQChatSDK/releases/tag/v$VERSION"
print_info "CocoaPods: https://cocoapods.org/pods/EQChatSDK"