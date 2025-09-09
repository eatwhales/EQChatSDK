# EQChatSDK 集成指南

本指南将详细介绍如何在您的iOS项目中集成和使用EQChatSDK。

## 📋 系统要求

- iOS 14.0+
- Xcode 12.0+
- Swift 5.3+

## 🚀 安装方式

### 方式一：CocoaPods

1. 在项目根目录创建或编辑 `Podfile`：

```ruby
platform :ios, '14.0'
use_frameworks!

target 'YourApp' do
  pod 'EQChatSDK', '~> 1.0.0'
end
```

2. 运行安装命令：

```bash
pod install
```

### 方式二：Swift Package Manager

1. 在Xcode中选择 `File` → `Add Package Dependencies`
2. 输入仓库URL：`https://github.com/yourusername/EQChatSDK.git`
3. 选择版本并添加到项目

## 🎯 快速开始

### 1. 导入SDK

```swift
import SwiftUI
import EQChatSDK
```

### 2. 创建基础聊天界面

```swift
struct ChatExampleView: View {
    @State private var messages: [Message] = []
    
    var body: some View {
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
        }
    }
}
```

### 3. 自定义主题

```swift
ChatView(messages: messages) { draft in
    // 消息处理逻辑
}
.chatTheme(
    colors: ChatTheme.Colors(
        mainTint: .blue,
        messageMyBG: .blue,
        messageFriendBG: Color(.systemGray5)
    )
)
```

## 🔧 核心组件详解

### Message 消息模型

```swift
let message = Message(
    id: "unique_id",           // 唯一标识符
    user: user,                // 发送用户
    status: .sent,             // 消息状态
    createdAt: Date(),         // 创建时间
    text: "消息内容"            // 文本内容
)
```

**消息状态类型：**
- `.sending` - 发送中
- `.sent` - 已发送
- `.read` - 已读
- `.error` - 发送失败

### User 用户模型

```swift
let user = User(
    id: "user_id",             // 用户ID
    name: "用户名",            // 显示名称
    avatarURL: URL(string: "..."), // 头像URL（可选）
    isCurrentUser: false       // 是否为当前用户
)
```

**用户类型：**
- `.current` - 当前用户
- `.friend` - 好友用户

### ChatTheme 主题配置

```swift
let theme = ChatTheme(
    colors: ChatTheme.Colors(
        mainTint: .blue,           // 主色调
        messageMyBG: .blue,        // 我的消息背景色
        messageFriendBG: .gray,    // 好友消息背景色
        textMyFG: .white,          // 我的消息文字色
        textFriendFG: .black       // 好友消息文字色
    ),
    images: ChatTheme.Images(
        sendButtonImage: Image(systemName: "paperplane.fill")
    )
)
```

## 🎨 高级功能

### 1. 消息状态管理

```swift
class ChatManager: ObservableObject {
    @Published var messages: [Message] = []
    
    func sendMessage(_ text: String) {
        let message = Message(
            id: UUID().uuidString,
            user: currentUser,
            status: .sending,
            text: text
        )
        
        messages.append(message)
        
        // 模拟网络请求
        sendToServer(message) { [weak self] success in
            DispatchQueue.main.async {
                self?.updateMessageStatus(
                    messageId: message.id,
                    status: success ? .sent : .error
                )
            }
        }
    }
    
    private func updateMessageStatus(messageId: String, status: Message.Status) {
        if let index = messages.firstIndex(where: { $0.id == messageId }) {
            messages[index].status = status
        }
    }
}
```

### 2. 自定义消息视图

```swift
ChatView(messages: messages) { draft in
    // 发送逻辑
} messageBuilder: { message in
    // 自定义消息视图
    CustomMessageView(message: message)
}
```

### 3. 输入框自定义

```swift
ChatView(messages: messages) { draft in
    // 发送逻辑
}
.inputViewBuilder { binding, onSend in
    CustomInputView(text: binding, onSend: onSend)
}
```

## 🔍 最佳实践

### 1. 消息分页加载

```swift
class ChatManager: ObservableObject {
    @Published var messages: [Message] = []
    private var currentPage = 0
    private let pageSize = 20
    
    func loadMoreMessages() {
        // 加载历史消息
        loadMessages(page: currentPage, size: pageSize) { [weak self] newMessages in
            DispatchQueue.main.async {
                self?.messages.insert(contentsOf: newMessages, at: 0)
                self?.currentPage += 1
            }
        }
    }
}
```

### 2. 消息持久化

```swift
class MessageStorage {
    func saveMessages(_ messages: [Message]) {
        // 保存到本地数据库
        let encoder = JSONEncoder()
        if let data = try? encoder.encode(messages) {
            UserDefaults.standard.set(data, forKey: "saved_messages")
        }
    }
    
    func loadMessages() -> [Message] {
        // 从本地数据库加载
        guard let data = UserDefaults.standard.data(forKey: "saved_messages"),
              let messages = try? JSONDecoder().decode([Message].self, from: data) else {
            return []
        }
        return messages
    }
}
```

### 3. 网络状态处理

```swift
class NetworkManager: ObservableObject {
    @Published var isConnected = true
    
    func sendMessage(_ message: Message, completion: @escaping (Bool) -> Void) {
        guard isConnected else {
            completion(false)
            return
        }
        
        // 发送网络请求
        URLSession.shared.dataTask(with: createRequest(for: message)) { data, response, error in
            let success = error == nil && (response as? HTTPURLResponse)?.statusCode == 200
            DispatchQueue.main.async {
                completion(success)
            }
        }.resume()
    }
}
```

## 🐛 常见问题

### Q: 消息不显示怎么办？
A: 检查消息数组是否正确绑定，确保使用 `@State` 或 `@Published` 修饰符。

### Q: 如何自定义消息气泡样式？
A: 使用 `chatTheme` 修饰符或实现自定义 `messageBuilder`。

### Q: 支持哪些消息类型？
A: 当前版本主要支持文本消息，未来版本将支持图片、语音等类型。

### Q: 如何处理大量消息的性能问题？
A: 建议实现分页加载和消息回收机制，避免一次性加载过多消息。

## 📞 技术支持

如果您在使用过程中遇到问题，可以通过以下方式获取帮助：

- 📧 邮箱：support@eqchatsdk.com
- 🐛 问题反馈：[GitHub Issues](https://github.com/yourusername/EQChatSDK/issues)
- 📖 文档：[完整文档](https://eqchatsdk.com/docs)

## 📄 许可证

EQChatSDK 使用 MIT 许可证。详情请查看 [LICENSE](LICENSE) 文件。