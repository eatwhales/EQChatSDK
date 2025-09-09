# EQChatSDK

[![Version](https://img.shields.io/cocoapods/v/EQChatSDK.svg?style=flat)](https://cocoapods.org/pods/EQChatSDK)
[![License](https://img.shields.io/cocoapods/l/EQChatSDK.svg?style=flat)](https://cocoapods.org/pods/EQChatSDK)
[![Platform](https://img.shields.io/cocoapods/p/EQChatSDK.svg?style=flat)](https://cocoapods.org/pods/EQChatSDK)

现代化SwiftUI聊天SDK - 为iOS应用提供完整的聊天界面组件

## 功能特性

- ✅ **纯SwiftUI实现** - 完全基于SwiftUI，支持iOS 16.0+
- ✅ **零外部依赖** - 无需额外的第三方库
- ✅ **完全可定制** - 支持自定义消息视图、输入框和菜单
- ✅ **现代化设计** - 遵循iOS设计规范的现代界面
- ✅ **主题系统** - 完整的颜色和样式定制支持
- ✅ **消息状态** - 发送中、已发送、已读状态显示
- ✅ **回复功能** - 支持消息引用回复
- ✅ **表情反应** - 消息表情反应支持
- ✅ **MVVM架构** - 清晰的代码架构和数据流

## 安装

### CocoaPods

在你的 `Podfile` 中添加：

```ruby
pod 'EQChatSDK', '~> 1.0'
```

然后运行：

```bash
pod install
```

### Swift Package Manager

在Xcode中，选择 `File` > `Add Package Dependencies`，然后输入仓库URL：

```
https://github.com/eatwhales/EQChatSDK.git
```

## 快速开始

### 基础使用

```swift
import SwiftUI
import EQChatSDK

struct ContentView: View {
    @State var messages: [Message] = []
    
    var body: some View {
        ChatView(messages: messages) { draft in
            // 处理消息发送
            let newMessage = Message(
                id: UUID().uuidString,
                user: User(id: "current", name: "我", avatarURL: nil, isCurrentUser: true),
                status: .sending,
                text: draft.text
            )
            messages.append(newMessage)
            
            // 模拟发送完成
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                if let index = messages.firstIndex(where: { $0.id == newMessage.id }) {
                    messages[index].status = .sent
                }
            }
        }
    }
}
```

### 自定义主题

```swift
ChatView(messages: messages) { draft in
    // 处理消息发送
}
.chatTheme(
    colors: ChatTheme.Colors(
        mainTint: .blue,
        messageMyBG: .blue,
        messageFriendBG: .gray.opacity(0.2)
    )
)
```

### 自定义消息视图

```swift
ChatView(messages: messages, messageBuilder: { message, _, _, _, _, _ in
    // 自定义消息视图
    HStack {
        Text(message.text)
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(12)
    }
}) { draft in
    // 处理消息发送
}
```

## 核心组件

### Message

消息数据模型，包含消息的所有信息：

```swift
let message = Message(
    id: "unique_id",
    user: user,
    status: .sent,
    createdAt: Date(),
    text: "Hello, World!",
    reactions: [],
    replyMessage: nil
)
```

### User

用户信息模型：

```swift
let user = User(
    id: "user_id",
    name: "用户名",
    avatarURL: URL(string: "https://example.com/avatar.jpg"),
    isCurrentUser: false
)
```

### ChatTheme

主题配置，支持完全自定义：

```swift
let theme = ChatTheme(
    colors: ChatTheme.Colors(
        mainBG: .white,
        mainTint: .blue,
        messageMyBG: .blue,
        messageFriendBG: .gray.opacity(0.2)
    ),
    images: ChatTheme.Images(
        sendButton: Image(systemName: "paperplane.fill")
    )
)
```

## 高级功能

### 消息回复

```swift
let replyMessage = ReplyMessage(
    id: originalMessage.id,
    user: originalMessage.user,
    text: originalMessage.text
)

let newMessage = Message(
    id: UUID().uuidString,
    user: currentUser,
    text: "这是回复内容",
    replyMessage: replyMessage
)
```

### 表情反应

```swift
let reaction = Reaction(
    id: "reaction_id",
    emoji: "👍",
    users: [user1, user2]
)

message.reactions.append(reaction)
```

### 自定义输入框

```swift
ChatView(
    messages: messages,
    inputViewBuilder: { textBinding, attachments, state, style, actionClosure, dismissClosure in
        // 自定义输入框视图
        CustomInputView(
            text: textBinding,
            onSend: actionClosure
        )
    }
) { draft in
    // 处理消息发送
}
```

## 示例项目

项目包含完整的示例代码，展示了如何集成和使用EQChatSDK的各种功能。

## 系统要求

- iOS 16.0+
- Xcode 14.0+
- Swift 5.0+

## 许可证

EQChatSDK 使用 MIT 许可证。详情请查看 [LICENSE](LICENSE) 文件。

## 贡献

欢迎提交 Issue 和 Pull Request！

## 支持

如果你觉得这个项目有用，请给我们一个 ⭐️！

---

**注意**: 这是一个现代化的SwiftUI聊天SDK，专为iOS 16.0+设计，提供最佳的用户体验和开发体验。