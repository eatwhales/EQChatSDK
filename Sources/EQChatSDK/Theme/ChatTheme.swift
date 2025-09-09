import SwiftUI

public extension EnvironmentValues {
    #if swift(>=6.0)
    @Entry var chatTheme = ChatTheme()
    #else
    var chatTheme: ChatTheme {
        get { self[ChatThemeKey.self] }
        set { self[ChatThemeKey.self] = newValue }
    }
    #endif
}

// Define keys only for older versions
#if swift(<6.0)
@preconcurrency public struct ChatThemeKey: EnvironmentKey {
    public static let defaultValue = ChatTheme()
}
#endif

extension View {

    public func chatTheme(_ theme: ChatTheme) -> some View {
        self.environment(\.chatTheme, theme)
    }

    public func chatTheme(
        colors: ChatTheme.Colors = .init(),
        images: ChatTheme.Images = .init()
    ) -> some View {
        self.environment(\.chatTheme, ChatTheme(colors: colors, images: images))
    }
}

/// 聊天主题配置结构体 - 定义整个聊天界面的主题样式
/// 包含颜色、图片资源和样式配置
public struct ChatTheme {
    /// 颜色配置
    public let colors: ChatTheme.Colors
    /// 图片资源配置
    public let images: ChatTheme.Images
    /// 样式配置
    public let style: ChatTheme.Style

    /// 初始化聊天主题
    /// - Parameters:
    ///   - colors: 颜色配置，默认使用系统颜色
    ///   - images: 图片资源配置，默认使用系统图标
    ///   - style: 样式配置，默认使用标准样式
    public init(
        colors: ChatTheme.Colors = .init(),
        images: ChatTheme.Images = .init(),
        style: ChatTheme.Style = .init()
    ) {
        self.style = style
        self.images = images
        
        // if background images have been set then override the mainBG color to be clear
        self.colors = if images.background != nil {
            ChatTheme.Colors(copy: colors, mainBG: .clear)
        } else {
            colors
        }
    }
    
    internal init(accentColor: Color, images: ChatTheme.Images) {
        self.init(
            colors: .init(
                mainTint: accentColor,
                messageMyBG: accentColor,
                messageMyTimeText: Color.white.opacity(0.5),
                sendButtonBackground: accentColor
            ),
            images: images
        )
    }
    
    @available(iOS 18.0, *)
    internal init(accentColor: Color, background: ThemedBackgroundStyle = .mixedWithAccentColor(), improveContrast: Bool) {
        let backgroundColor: Color = background.getBackgroundColor(withAccent: accentColor, improveContrast: improveContrast)
        let friendMessageColor: Color = background.getFriendMessageColor(improveContrast: improveContrast, background: backgroundColor)
        self.init(
            colors: .init(
                mainBG: backgroundColor,
                mainTint: accentColor,
                messageMyBG: accentColor,
                messageMyText: Color.white,
                messageMyTimeText: Color.white.opacity(0.5),
                messageFriendBG: friendMessageColor,
                inputBG: friendMessageColor,
                menuBG: backgroundColor,
                sendButtonBackground: accentColor
            )
        )
    }

    /// 颜色配置结构体 - 定义聊天界面所有颜色主题
    /// 包含主界面、消息、输入框、菜单和状态等各种颜色配置
    public struct Colors {
        /// 主背景色
        public var mainBG: Color
        /// 主题色调
        public var mainTint: Color
        /// 主文本颜色
        public var mainText: Color
        /// 副标题文本颜色
        public var mainCaptionText: Color

        /// 我的消息背景色
        public var messageMyBG: Color
        /// 我的消息文本颜色
        public var messageMyText: Color
        /// 我的消息时间文本颜色
        public var messageMyTimeText: Color

        /// 好友消息背景色
        public var messageFriendBG: Color
        /// 好友消息文本颜色
        public var messageFriendText: Color
        /// 好友消息时间文本颜色
        public var messageFriendTimeText: Color
        
        /// 系统消息背景色
        public var messageSystemBG: Color
        /// 系统消息文本颜色
        public var messageSystemText: Color
        /// 系统消息时间文本颜色
        public var messageSystemTimeText: Color

        /// 输入框背景色
        public var inputBG: Color
        /// 输入框文本颜色
        public var inputText: Color
        /// 输入框占位符文本颜色
        public var inputPlaceholderText: Color

        /// 签名输入框背景色
        public var inputSignatureBG: Color
        /// 签名输入框文本颜色
        public var inputSignatureText: Color
        /// 签名输入框占位符文本颜色
        public var inputSignaturePlaceholderText: Color

        /// 菜单背景色
        public var menuBG: Color
        /// 菜单文本颜色
        public var menuText: Color
        /// 菜单删除文本颜色
        public var menuTextDelete: Color

        /// 错误状态颜色
        public var statusError: Color
        /// 灰色状态颜色
        public var statusGray: Color

        /// 发送按钮背景色
        public var sendButtonBackground: Color

        /// 初始化颜色配置
        /// 使用系统默认颜色值，确保在没有自定义颜色资源时也能正常显示
        /// - Parameters: 各种界面元素的颜色配置，均有合理的默认值
        public init(
            mainBG: Color = Color(UIColor.systemBackground),
            mainTint: Color = Color.blue,
            mainText: Color = Color(UIColor.label),
            mainCaptionText: Color = Color(UIColor.secondaryLabel),
            messageMyBG: Color = Color.blue,
            messageMyText: Color = Color.white,
            messageMyTimeText: Color = Color.white.opacity(0.7),
            messageFriendBG: Color = Color(UIColor.secondarySystemBackground),
            messageFriendText: Color = Color(UIColor.label),
            messageFriendTimeText: Color = Color(UIColor.secondaryLabel),
            messageSystemBG: Color = Color(UIColor.tertiarySystemBackground),
            messageSystemText: Color = Color(UIColor.secondaryLabel),
            messageSystemTimeText: Color = Color(UIColor.tertiaryLabel),
            inputBG: Color = Color(UIColor.secondarySystemBackground),
            inputText: Color = Color(UIColor.label),
            inputPlaceholderText: Color = Color(UIColor.placeholderText),
            inputSignatureBG: Color = Color(UIColor.secondarySystemBackground),
            inputSignatureText: Color = Color(UIColor.label),
            inputSignaturePlaceholderText: Color = Color(UIColor.placeholderText),
            menuBG: Color = Color(UIColor.systemBackground),
            menuText: Color = Color(UIColor.label),
            menuTextDelete: Color = Color.red,
            statusError: Color = Color.red,
            statusGray: Color = Color(UIColor.systemGray),
            sendButtonBackground: Color = Color.blue
        ) {
            self.mainBG = mainBG
            self.mainTint = mainTint
            self.mainText = mainText
            self.mainCaptionText = mainCaptionText
            self.messageMyBG = messageMyBG
            self.messageMyText = messageMyText
            self.messageMyTimeText = messageMyTimeText
            self.messageFriendBG = messageFriendBG
            self.messageFriendText = messageFriendText
            self.messageFriendTimeText = messageFriendTimeText
            self.messageSystemBG = messageSystemBG
            self.messageSystemText = messageSystemText
            self.messageSystemTimeText = messageSystemTimeText
            self.inputBG = inputBG
            self.inputText = inputText
            self.inputPlaceholderText = inputPlaceholderText
            self.inputSignatureBG = inputSignatureBG
            self.inputSignatureText = inputSignatureText
            self.inputSignaturePlaceholderText = inputSignaturePlaceholderText
            self.menuBG = menuBG
            self.menuText = menuText
            self.menuTextDelete = menuTextDelete
            self.statusError = statusError
            self.statusGray = statusGray
            self.sendButtonBackground = sendButtonBackground
        }
        
        public init(copy: Colors, mainBG: Color) {
            self.mainBG = mainBG
            self.mainTint = copy.mainTint
            self.mainText = copy.mainText
            self.mainCaptionText = copy.mainCaptionText
            self.messageMyBG = copy.messageMyBG
            self.messageMyText = copy.messageMyText
            self.messageMyTimeText = copy.messageMyTimeText
            self.messageFriendBG = copy.messageFriendBG
            self.messageFriendText = copy.messageFriendText
            self.messageFriendTimeText = copy.messageFriendTimeText
            self.messageSystemBG = copy.messageSystemBG
            self.messageSystemText = copy.messageSystemText
            self.messageSystemTimeText = copy.messageSystemTimeText
            self.inputBG = copy.inputBG
            self.inputText = copy.inputText
            self.inputPlaceholderText = copy.inputPlaceholderText
            self.inputSignatureBG = copy.inputSignatureBG
            self.inputSignatureText = copy.inputSignatureText
            self.inputSignaturePlaceholderText = copy.inputSignaturePlaceholderText
            self.menuBG = copy.menuBG
            self.menuText = copy.menuText
            self.menuTextDelete = copy.menuTextDelete
            self.statusError = copy.statusError
            self.statusGray = copy.statusGray
            self.sendButtonBackground = copy.sendButtonBackground
        }
    }

    /// 图片资源配置结构体 - 定义聊天界面所有图片资源
    /// 包含背景图片、按钮图标、消息状态图标等
    public struct Images {
      
        /// 背景图片配置结构体 - 定义不同方向和主题的背景图片
        public struct Background {
            
            /// 安全区域配置
            let safeAreaRegions: SafeAreaRegions
            /// 安全区域边缘设置
            let safeAreaEdges: Edge.Set
            /// 竖屏浅色主题背景图片
            let portraitBackgroundLight: Image
            /// 竖屏深色主题背景图片
            let portraitBackgroundDark: Image
            /// 横屏浅色主题背景图片
            let landscapeBackgroundLight: Image
            /// 横屏深色主题背景图片
            let landscapeBackgroundDark: Image

            public init(
                safeAreaRegions: SafeAreaRegions = .all,
                safeAreaEdges: Edge.Set = .all,
                portraitBackgroundLight: Image,
                portraitBackgroundDark: Image,
                landscapeBackgroundLight: Image,
                landscapeBackgroundDark: Image
            ) {
                self.safeAreaRegions = safeAreaRegions
                self.safeAreaEdges = safeAreaEdges
                self.portraitBackgroundLight = portraitBackgroundLight
                self.portraitBackgroundDark = portraitBackgroundDark
                self.landscapeBackgroundLight = landscapeBackgroundLight
                self.landscapeBackgroundDark = landscapeBackgroundDark
            }
        }

        /// 附件菜单图片配置结构体（预留扩展）
        public struct AttachMenu {
        }

        /// 输入视图图片配置结构体 - 定义输入相关的图标
        public struct InputView {
            /// 发送箭头图标
            public var arrowSend: Image
        }

        /// 消息状态图片配置结构体 - 定义消息状态相关图标
        public struct Message {
            /// 错误状态图标
            public var error: Image
            /// 已读状态图标
            public var read: Image
            /// 发送中状态图标
            public var sending: Image
            /// 已发送状态图标
            public var sent: Image
        }

        /// 消息菜单图片配置结构体 - 定义消息操作菜单图标
        public struct MessageMenu {
            /// 删除图标
            public var delete: Image
            /// 编辑图标
            public var edit: Image
            /// 转发图标
            public var forward: Image
            /// 重试图标
            public var retry: Image
            /// 保存图标
            public var save: Image
            /// 选择图标
            public var select: Image
        }

        /// 回复功能图片配置结构体 - 定义回复相关图标
        public struct Reply {
            /// 取消回复图标
            public var cancelReply: Image
            /// 回复消息图标
            public var replyToMessage: Image
        }
      
        /// 背景图片配置（可选）
        public var background: Background? = nil
  
        /// 返回按钮图标
        public var backButton: Image
        /// 滚动到底部按钮图标
        public var scrollToBottom: Image

        /// 附件菜单图片配置
        public var attachMenu: AttachMenu
        /// 输入视图图片配置
        public var inputView: InputView
        /// 消息状态图片配置
        public var message: Message
        /// 消息菜单图片配置
        public var messageMenu: MessageMenu
        /// 回复功能图片配置
        public var reply: Reply

        public init(
            arrowSend: Image? = nil,
            error: Image? = nil,
            read: Image? = nil,
            sending: Image? = nil,
            sent: Image? = nil,
            delete: Image? = nil,
            edit: Image? = nil,
            forward: Image? = nil,
            retry: Image? = nil,
            save: Image? = nil,
            select: Image? = nil,
            cancelReply: Image? = nil,
            replyToMessage: Image? = nil,
            backButton: Image? = nil,
            scrollToBottom: Image? = nil,
            background: Background? = nil
        ) {
            self.backButton = backButton ?? Image("backArrow", bundle: .current)
            self.scrollToBottom = scrollToBottom ?? Image(systemName: "chevron.down")
            
            self.background = background

            self.attachMenu = AttachMenu()

            self.inputView = InputView(
                arrowSend: arrowSend ?? Image("arrowSend", bundle: .current)
            )

            self.message = Message(
                error: error ?? Image(systemName: "exclamationmark.circle.fill"),
                read: read ?? Image(systemName: "checkmark.circle.fill"),
                sending: sending ?? Image(systemName: "clock"),
                sent: sent ?? Image(systemName: "checkmark.circle")
            )

            self.messageMenu = MessageMenu(
                delete: delete ?? Image("delete", bundle: .current),
                edit: edit ?? Image("edit", bundle: .current),
                forward: forward ?? Image("forward", bundle: .current),
                retry: retry ?? Image("retry", bundle: .current),
                save: save ?? Image("save", bundle: .current),
                select: select ?? Image("select", bundle: .current)
            )

            self.reply = Reply(
                cancelReply: cancelReply ?? Image(systemName: "x.circle"),
                replyToMessage: replyToMessage ?? Image(systemName: "arrow.uturn.left")
            )
        }
    }
    
    /// 样式配置结构体 - 定义聊天界面的视觉样式
    /// 包含回复透明度等样式设置
    public struct Style {
        /// 回复消息的透明度
        public var replyOpacity: Double
        
        /// 初始化样式配置
        /// - Parameter replyOpacity: 回复消息的透明度，默认为0.8
        public init(replyOpacity: Double = 0.8) {
            self.replyOpacity = replyOpacity
        }
    }
}
