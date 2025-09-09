#!/bin/bash
#
# setup_github.sh - GitHub仓库初始化脚本
# 帮助快速设置EQChatSDK的GitHub仓库
#

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

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

print_info "EQChatSDK GitHub仓库初始化脚本"
echo "======================================"

# 检查git是否安装
if ! command -v git &> /dev/null; then
    print_error "Git未安装，请先安装Git"
    exit 1
fi

# 获取GitHub用户名和仓库名
read -p "请输入您的GitHub用户名: " GITHUB_USERNAME
read -p "请输入仓库名称 [EQChatSDK]: " REPO_NAME
REPO_NAME=${REPO_NAME:-EQChatSDK}

# 验证输入
if [ -z "$GITHUB_USERNAME" ]; then
    print_error "GitHub用户名不能为空"
    exit 1
fi

GITHUB_URL="https://github.com/$GITHUB_USERNAME/$REPO_NAME.git"

print_info "将要创建的仓库: $GITHUB_URL"

# 初始化git仓库
if [ ! -d ".git" ]; then
    print_info "初始化Git仓库"
    git init
    print_success "Git仓库初始化完成"
else
    print_warning "Git仓库已存在"
fi

# 更新podspec和README中的GitHub链接
print_info "更新配置文件中的GitHub链接"

# 更新podspec
if [ -f "EQChatSDK.podspec" ]; then
    sed -i '' "s|https://github.com/yourusername/EQChatSDK|$GITHUB_URL|g" EQChatSDK.podspec
    sed -i '' "s/yourusername/$GITHUB_USERNAME/g" EQChatSDK.podspec
    print_success "已更新EQChatSDK.podspec"
fi

# 更新README
if [ -f "README.md" ]; then
    sed -i '' "s|https://github.com/yourusername/EQChatSDK|$GITHUB_URL|g" README.md
    sed -i '' "s/yourusername/$GITHUB_USERNAME/g" README.md
    print_success "已更新README.md"
fi

# 创建.gitignore
if [ ! -f ".gitignore" ]; then
    print_info "创建.gitignore文件"
    cat > .gitignore << EOF
# Xcode
*.xcodeproj/*
!*.xcodeproj/project.pbxproj
!*.xcodeproj/*.xcscheme
!*.xcodeproj/xcshareddata/
*.xcworkspace/*
!*.xcworkspace/contents.xcworkspacedata
!*.xcworkspace/xcshareddata/

# Build products
build/
DerivedData/

# CocoaPods
Pods/
Podfile.lock

# Swift Package Manager
.build/
Packages/
*.xcodeproj/

# macOS
.DS_Store

# IDE
.vscode/
.idea/

# Temporary files
*.tmp
*.swp
*~
EOF
    print_success "已创建.gitignore文件"
fi

# 添加所有文件
print_info "添加文件到Git"
git add .

# 创建初始提交
if ! git rev-parse --verify HEAD >/dev/null 2>&1; then
    print_info "创建初始提交"
    git commit -m "Initial commit: EQChatSDK v1.0.0
    
    - 完整的SwiftUI聊天SDK实现
    - 支持消息发送、状态显示、回复功能
    - 完全可定制的主题系统
    - 零外部依赖
    - 支持CocoaPods和Swift Package Manager"
    print_success "初始提交创建完成"
else
    print_warning "已存在提交记录"
fi

# 设置远程仓库
if ! git remote get-url origin >/dev/null 2>&1; then
    print_info "添加远程仓库"
    git remote add origin "$GITHUB_URL"
    print_success "已添加远程仓库: $GITHUB_URL"
else
    print_warning "远程仓库已存在"
    git remote -v
fi

# 设置默认分支
git branch -M main

echo
print_success "GitHub仓库初始化完成！"
echo "======================================"
print_info "下一步操作："
echo "1. 在GitHub上创建新仓库: $REPO_NAME"
echo "2. 运行以下命令推送代码:"
echo "   git push -u origin main"
echo "3. 创建第一个release:"
echo "   ./release.sh 1.0.0"
echo "4. 注册CocoaPods Trunk账号（如果还没有）:"
echo "   pod trunk register your.email@example.com 'Your Name'"
echo
print_info "仓库地址: $GITHUB_URL"
print_info "CocoaPods安装命令: pod 'EQChatSDK', '~> 1.0'"