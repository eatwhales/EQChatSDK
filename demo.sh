#!/bin/bash

# EQChatSDK 演示脚本
# 用于快速创建演示项目并测试SDK功能

set -e

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

# 检查依赖
check_dependencies() {
    print_info "检查系统依赖..."
    
    # 检查Xcode
    if ! command -v xcodebuild &> /dev/null; then
        print_error "Xcode未安装或未正确配置"
        exit 1
    fi
    
    # 检查CocoaPods
    if ! command -v pod &> /dev/null; then
        print_warning "CocoaPods未安装，正在安装..."
        sudo gem install cocoapods
    fi
    
    print_success "依赖检查完成"
}

# 创建演示项目
create_demo_project() {
    local project_name="EQChatSDKDemo"
    local project_path="./Demo/$project_name"
    
    print_info "创建演示项目: $project_name"
    
    # 创建项目目录
    mkdir -p "./Demo"
    cd "./Demo"
    
    # 检查项目是否已存在
    if [ -d "$project_name" ]; then
        print_warning "演示项目已存在，是否删除重建？(y/n)"
        read -r response
        if [[ "$response" =~ ^[Yy]$ ]]; then
            rm -rf "$project_name"
        else
            print_info "使用现有项目"
            cd "$project_name"
            return
        fi
    fi
    
    # 创建Xcode项目结构
    mkdir -p "$project_name/$project_name"
    cd "$project_name"
    
    # 创建Podfile
    cat > Podfile << EOF
platform :ios, '14.0'
use_frameworks!

target '$project_name' do
  # 使用本地SDK进行开发测试
  pod 'EQChatSDK', :path => '../../'
  
  # 如果要使用发布版本，请注释上面一行，取消注释下面一行
  # pod 'EQChatSDK', '~> 1.0'
end
EOF
    
    # 创建基础App文件
    cat > "$project_name/App.swift" << 'EOF'
import SwiftUI
import EQChatSDK

@main
struct DemoApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
EOF
    
    # 创建主视图
    cat > "$project_name/ContentView.swift" << 'EOF'
import SwiftUI
import EQChatSDK

struct ContentView: View {
    @StateObject private var chatManager = DemoChatManager()
    
    var body: some View {
        NavigationView {
            ChatView(messages: chatManager.messages) { draft in
                chatManager.sendMessage(draft.text)
            }
            .chatTheme(
                colors: ChatTheme.Colors(
                    mainTint: .blue,
                    messageMyBG: .blue,
                    messageFriendBG: Color(.systemGray5)
                )
            )
            .navigationTitle("EQChatSDK演示")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("添加消息") {
                        chatManager.addSampleMessage()
                    }
                }
            }
        }
    }
}

class DemoChatManager: ObservableObject {
    @Published var messages: [Message] = []
    
    private let currentUser = User(
        id: "demo_user",
        name: "演示用户",
        avatarURL: nil,
        isCurrentUser: true
    )
    
    private let botUser = User(
        id: "bot_user",
        name: "AI助手",
        avatarURL: nil,
        isCurrentUser: false
    )
    
    init() {
        loadWelcomeMessage()
    }
    
    func sendMessage(_ text: String) {
        let message = Message(
            id: UUID().uuidString,
            user: currentUser,
            status: .sending,
            createdAt: Date(),
            text: text
        )
        
        messages.append(message)
        
        // 模拟发送
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.updateMessageStatus(messageId: message.id, status: .sent)
            self.simulateBotReply(to: text)
        }
    }
    
    func addSampleMessage() {
        let sampleTexts = [
            "这是一条示例消息",
            "EQChatSDK功能演示",
            "支持实时聊天",
            "界面美观易用"
        ]
        
        let message = Message(
            id: UUID().uuidString,
            user: botUser,
            status: .read,
            createdAt: Date(),
            text: sampleTexts.randomElement() ?? "示例消息"
        )
        
        messages.append(message)
    }
    
    private func updateMessageStatus(messageId: String, status: Message.Status) {
        if let index = messages.firstIndex(where: { $0.id == messageId }) {
            messages[index].status = status
        }
    }
    
    private func simulateBotReply(to userMessage: String) {
        let replies = [
            "收到您的消息：\"\(userMessage)\"",
            "这是一个自动回复",
            "EQChatSDK演示正在运行",
            "感谢您的测试！"
        ]
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            let reply = Message(
                id: UUID().uuidString,
                user: self.botUser,
                status: .read,
                createdAt: Date(),
                text: replies.randomElement() ?? "自动回复"
            )
            
            self.messages.append(reply)
        }
    }
    
    private func loadWelcomeMessage() {
        let welcomeMessage = Message(
            id: "welcome",
            user: botUser,
            status: .read,
            createdAt: Date(),
            text: "欢迎使用EQChatSDK演示！\n\n这个演示展示了SDK的基本功能：\n• 发送和接收消息\n• 消息状态显示\n• 自定义主题\n• 流畅的动画效果\n\n请随意发送消息进行测试！"
        )
        
        messages = [welcomeMessage]
    }
}

#Preview {
    ContentView()
}
EOF
    
    # 创建Info.plist
    cat > "$project_name/Info.plist" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleDevelopmentRegion</key>
    <string>\$(DEVELOPMENT_LANGUAGE)</string>
    <key>CFBundleExecutable</key>
    <string>\$(EXECUTABLE_NAME)</string>
    <key>CFBundleIdentifier</key>
    <string>\$(PRODUCT_BUNDLE_IDENTIFIER)</string>
    <key>CFBundleInfoDictionaryVersion</key>
    <string>6.0</string>
    <key>CFBundleName</key>
    <string>\$(PRODUCT_NAME)</string>
    <key>CFBundlePackageType</key>
    <string>\$(PRODUCT_BUNDLE_PACKAGE_TYPE)</string>
    <key>CFBundleShortVersionString</key>
    <string>1.0</string>
    <key>CFBundleVersion</key>
    <string>1</string>
    <key>LSRequiresIPhoneOS</key>
    <true/>
    <key>UIApplicationSceneManifest</key>
    <dict>
        <key>UIApplicationSupportsMultipleScenes</key>
        <true/>
    </dict>
    <key>UIApplicationSupportsIndirectInputEvents</key>
    <true/>
    <key>UILaunchScreen</key>
    <dict/>
    <key>UIRequiredDeviceCapabilities</key>
    <array>
        <string>armv7</string>
    </array>
    <key>UISupportedInterfaceOrientations</key>
    <array>
        <string>UIInterfaceOrientationPortrait</string>
        <string>UIInterfaceOrientationLandscapeLeft</string>
        <string>UIInterfaceOrientationLandscapeRight</string>
    </array>
    <key>UISupportedInterfaceOrientations~ipad</key>
    <array>
        <string>UIInterfaceOrientationPortrait</string>
        <string>UIInterfaceOrientationPortraitUpsideDown</string>
        <string>UIInterfaceOrientationLandscapeLeft</string>
        <string>UIInterfaceOrientationLandscapeRight</string>
    </array>
</dict>
</plist>
EOF
    
    print_success "演示项目创建完成: $project_path"
}

# 安装依赖
install_dependencies() {
    print_info "安装项目依赖..."
    
    # 安装CocoaPods依赖
    pod install
    
    print_success "依赖安装完成"
}

# 打开项目
open_project() {
    local workspace_file="EQChatSDKDemo.xcworkspace"
    
    if [ -f "$workspace_file" ]; then
        print_info "打开Xcode项目..."
        open "$workspace_file"
        print_success "项目已在Xcode中打开"
    else
        print_error "找不到workspace文件: $workspace_file"
        exit 1
    fi
}

# 运行演示
run_demo() {
    print_info "构建并运行演示项目..."
    
    # 构建项目
    xcodebuild -workspace EQChatSDKDemo.xcworkspace \
               -scheme EQChatSDKDemo \
               -destination 'platform=iOS Simulator,name=iPhone 15 Pro' \
               build
    
    # 运行项目
    xcodebuild -workspace EQChatSDKDemo.xcworkspace \
               -scheme EQChatSDKDemo \
               -destination 'platform=iOS Simulator,name=iPhone 15 Pro' \
               test
    
    print_success "演示运行完成"
}

# 清理演示项目
clean_demo() {
    print_info "清理演示项目..."
    
    if [ -d "./Demo" ]; then
        rm -rf "./Demo"
        print_success "演示项目已清理"
    else
        print_warning "没有找到演示项目"
    fi
}

# 显示帮助信息
show_help() {
    echo "EQChatSDK 演示脚本"
    echo ""
    echo "用法: $0 [选项]"
    echo ""
    echo "选项:"
    echo "  create    创建演示项目"
    echo "  install   安装依赖"
    echo "  open      打开项目"
    echo "  run       运行演示"
    echo "  clean     清理演示项目"
    echo "  full      执行完整演示流程 (create + install + open)"
    echo "  help      显示此帮助信息"
    echo ""
    echo "示例:"
    echo "  $0 full     # 创建完整演示项目"
    echo "  $0 create   # 仅创建项目结构"
    echo "  $0 clean    # 清理演示项目"
}

# 主函数
main() {
    case "${1:-help}" in
        "create")
            check_dependencies
            create_demo_project
            ;;
        "install")
            install_dependencies
            ;;
        "open")
            open_project
            ;;
        "run")
            run_demo
            ;;
        "clean")
            clean_demo
            ;;
        "full")
            check_dependencies
            create_demo_project
            install_dependencies
            open_project
            ;;
        "help")
            show_help
            ;;
        *)
            print_error "未知选项: $1"
            show_help
            exit 1
            ;;
    esac
}

# 脚本入口
main "$@"