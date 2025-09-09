//
//  ExampleApp.swift
//  EQChatSDK示例应用
//
//  展示如何在实际项目中集成和使用EQChatSDK
//

import SwiftUI
// import EQChatSDK  // 在实际项目中取消注释

/// 示例应用主入口
/// 演示EQChatSDK的完整集成流程
@main
struct ExampleApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

/// 主内容视图
/// 包含聊天界面和功能演示
struct ContentView: View {
    /// 聊天消息状态管理
    @StateObject private var chatManager = ChatManager()
    
    var body: some View {
        NavigationView {
            VStack {
                // 聊天界面
                ChatView(messages: chatManager.messages) { draft in
                    chatManager.sendMessage(draft.text)
                }
                .chatTheme(
                    colors: ChatTheme.Colors(
                        mainTint: .blue,
                        messageMyBG: .blue,
                        messageFriendBG: Color(.systemGray5),
                        textMyFG: .white,
                        textFriendFG: .primary
                    ),
                    images: ChatTheme.Images(
                        sendButtonImage: Image(systemName: "paperplane.fill")
                    )
                )
            }
            .navigationTitle("EQChat示例")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button("添加示例消息") {
                            chatManager.addSampleMessage()
                        }
                        Button("清空聊天") {
                            chatManager.clearMessages()
                        }
                        Button("切换主题") {
                            chatManager.toggleTheme()
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
            }
        }
    }
}

/// 聊天管理器
/// 负责消息的发送、接收和状态管理
class ChatManager: ObservableObject {
    /// 消息列表
    @Published var messages: [Message] = []
    
    /// 当前用户
    private let currentUser = User(
        id: "current_user",
        name: "我",
        avatarURL: nil,
        isCurrentUser: true
    )
    
    /// 示例好友用户
    private let friendUser = User(
        id: "friend_user",
        name: "小明",
        avatarURL: nil,
        isCurrentUser: false
    )
    
    /// 当前主题模式
    @Published var isDarkTheme = false
    
    init() {
        loadSampleMessages()
    }
    
    /// 发送消息
    /// - Parameter text: 消息文本内容
    func sendMessage(_ text: String) {
        guard !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        
        let message = Message(
            id: UUID().uuidString,
            user: currentUser,
            status: .sending,
            createdAt: Date(),
            text: text
        )
        
        messages.append(message)
        
        // 模拟发送过程
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.updateMessageStatus(messageId: message.id, status: .sent)
            
            // 模拟好友回复
            self.simulateFriendReply()
        }
    }
    
    /// 更新消息状态
    /// - Parameters:
    ///   - messageId: 消息ID
    ///   - status: 新状态
    private func updateMessageStatus(messageId: String, status: Message.Status) {
        if let index = messages.firstIndex(where: { $0.id == messageId }) {
            var updatedMessage = messages[index]
            updatedMessage.status = status
            messages[index] = updatedMessage
        }
    }
    
    /// 模拟好友回复
    private func simulateFriendReply() {
        let replies = [
            "收到！",
            "好的，明白了",
            "这个想法不错",
            "让我想想...",
            "同意你的观点",
            "有道理"
        ]
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            let replyText = replies.randomElement() ?? "收到"
            let replyMessage = Message(
                id: UUID().uuidString,
                user: self.friendUser,
                status: .read,
                createdAt: Date(),
                text: replyText
            )
            
            self.messages.append(replyMessage)
        }
    }
    
    /// 添加示例消息
    func addSampleMessage() {
        let sampleMessages = [
            "这是一条示例消息",
            "EQChatSDK功能很强大！",
            "支持多种消息类型",
            "界面简洁美观"
        ]
        
        let text = sampleMessages.randomElement() ?? "示例消息"
        let message = Message(
            id: UUID().uuidString,
            user: friendUser,
            status: .read,
            createdAt: Date(),
            text: text
        )
        
        messages.append(message)
    }
    
    /// 清空消息
    func clearMessages() {
        messages.removeAll()
    }
    
    /// 切换主题
    func toggleTheme() {
        isDarkTheme.toggle()
    }
    
    /// 加载示例消息
    private func loadSampleMessages() {
        let sampleMessages = [
            Message(
                id: "welcome",
                user: friendUser,
                status: .read,
                createdAt: Date().addingTimeInterval(-3600),
                text: "欢迎使用EQChatSDK！这是一个功能强大的聊天组件。"
            ),
            Message(
                id: "features",
                user: currentUser,
                status: .read,
                createdAt: Date().addingTimeInterval(-1800),
                text: "看起来很不错，都有哪些功能呢？"
            ),
            Message(
                id: "feature_list",
                user: friendUser,
                status: .read,
                createdAt: Date().addingTimeInterval(-900),
                text: "支持文本消息、自定义主题、消息状态显示、滚动加载等功能。"
            )
        ]
        
        messages = sampleMessages
    }
}

/// 预览提供者
#Preview {
    ContentView()
}