//
//  TestIntegration.swift
//  EQChatSDK测试集成
//
//  用于验证SDK的基本功能和集成正确性
//

import SwiftUI
// import EQChatSDK  // 在实际项目中取消注释

/// SDK集成测试视图
/// 验证EQChatSDK的基本功能是否正常工作
struct TestIntegrationView: View {
    /// 测试消息数组
    @State private var messages: [Message] = [
        Message(
            id: "test_1",
            user: User(id: "user1", name: "测试用户", avatarURL: nil, isCurrentUser: false),
            status: .read,
            createdAt: Date(),
            text: "这是一条测试消息"
        ),
        Message(
            id: "test_2",
            user: User(id: "current", name: "我", avatarURL: nil, isCurrentUser: true),
            status: .sent,
            createdAt: Date(),
            text: "SDK集成测试成功！"
        )
    ]
    
    var body: some View {
        NavigationView {
            ChatView(messages: messages) { draft in
                // 处理消息发送
                let newMessage = Message(
                    id: UUID().uuidString,
                    user: User(id: "current", name: "我", avatarURL: nil, isCurrentUser: true),
                    status: .sending,
                    createdAt: Date(),
                    text: draft.text
                )
                
                messages.append(newMessage)
                
                // 模拟发送完成
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    if let index = messages.firstIndex(where: { $0.id == newMessage.id }) {
                        messages[index] = Message(
                            id: newMessage.id,
                            user: newMessage.user,
                            status: .sent,
                            createdAt: newMessage.createdAt,
                            text: newMessage.text
                        )
                    }
                }
            }
            .navigationTitle("EQChatSDK测试")
            .chatTheme(
                colors: ChatTheme.Colors(
                    mainTint: .blue,
                    messageMyBG: .blue,
                    messageFriendBG: .gray.opacity(0.2)
                )
            )
        }
    }
}

/// 预览提供者
#Preview {
    TestIntegrationView()
}

/// SDK功能测试类
/// 用于验证SDK的各个组件是否正常工作
class EQChatSDKTests {
    
    /// 测试消息创建
    static func testMessageCreation() -> Bool {
        let user = User(id: "test", name: "Test User", avatarURL: nil, isCurrentUser: false)
        let message = Message(
            id: "test_msg",
            user: user,
            status: .sent,
            text: "Test message"
        )
        
        return message.id == "test_msg" && 
               message.user.name == "Test User" && 
               message.text == "Test message"
    }
    
    /// 测试用户创建
    static func testUserCreation() -> Bool {
        let user = User(id: "test_user", name: "Test", avatarURL: nil, isCurrentUser: true)
        return user.isCurrentUser && user.type == .current
    }
    
    /// 测试主题配置
    static func testThemeConfiguration() -> Bool {
        let theme = ChatTheme(
            colors: ChatTheme.Colors(mainTint: .blue),
            images: ChatTheme.Images()
        )
        return theme.colors.mainTint == .blue
    }
    
    /// 运行所有测试
    static func runAllTests() -> [String: Bool] {
        return [
            "Message Creation": testMessageCreation(),
            "User Creation": testUserCreation(),
            "Theme Configuration": testThemeConfiguration()
        ]
    }
}