import SwiftUI

/// 消息视图组件 - 用于显示单个聊天消息
struct MessageView: View {

    @Environment(\.chatTheme) var theme /// 聊天主题

    @ObservedObject var viewModel: ChatViewModel /// 聊天视图模型

    let message: Message /// 消息数据
    let positionInUserGroup: PositionInUserGroup /// 在用户组中的位置
    let positionInMessagesSection: PositionInMessagesSection /// 在消息区域中的位置
    let chatType: ChatType /// 聊天类型
    let avatarSize: CGFloat /// 头像大小
    let tapAvatarClosure: ChatView.TapAvatarClosure? /// 头像点击事件
    let messageStyler: (String) -> AttributedString /// 消息样式化器
    let shouldShowLinkPreview: (URL) -> Bool /// 是否显示链接预览
    let isDisplayingMessageMenu: Bool /// 是否正在显示消息菜单
    let showMessageTimeView: Bool /// 是否显示消息时间
    let messageLinkPreviewLimit: Int /// 消息链接预览限制
    var font: UIFont /// 字体

    @State var avatarViewSize: CGSize = .zero
    @State var statusSize: CGSize = .zero
    @State var giphyAspectRatio: CGFloat = 1
    @State var timeSize: CGSize = .zero
    @State var messageSize: CGSize = .zero

    // The size of our reaction bubbles are based on the users font size,
    // Therefore we need to capture it's rendered size in order to place it correctly
    @State var bubbleSize: CGSize = .zero

    static let widthWithMedia: CGFloat = 204
    static let horizontalScreenEdgePadding: CGFloat = 12
    static let horizontalNoAvatarPadding: CGFloat = horizontalScreenEdgePadding / 2
    static let horizontalAvatarPadding: CGFloat = 8
    static let horizontalTextPadding: CGFloat = 12
    static let statusViewSize: CGFloat = 10
    static let horizontalStatusPadding: CGFloat = horizontalScreenEdgePadding / 2
    static let horizontalBubblePadding: CGFloat = 70

    enum DateArrangement {
        case hstack, vstack, overlay
    }

    var additionalMediaInset: CGFloat {
        0
    }

    var dateArrangement: DateArrangement {
        let timeWidth = timeSize.width + 10
        let textPaddings = MessageView.horizontalTextPadding * 2
        let widthWithoutMedia =
            UIScreen.main.bounds.width
            - (message.user.isCurrentUser
                ? MessageView.horizontalNoAvatarPadding : avatarViewSize.width)
            - statusSize.width
            - MessageView.horizontalBubblePadding
            - textPaddings

        let maxWidth = widthWithoutMedia
        let styledText = message.text.styled(using: messageStyler)

        let finalWidth = styledText.width(withConstrainedWidth: maxWidth, font: font)
        let lastLineWidth = styledText.lastLineWidth(labelWidth: maxWidth, font: font)
        let numberOfLines = styledText.numberOfLines(labelWidth: maxWidth, font: font)

        if !styledText.urls.isEmpty && messageLinkPreviewLimit > 0 {
            return .vstack
        }
        if numberOfLines == 1, finalWidth + CGFloat(timeWidth) < maxWidth {
            return .hstack
        }
        if lastLineWidth + CGFloat(timeWidth) < finalWidth {
            return .overlay
        }
        return .vstack
    }

    var showAvatar: Bool {
        isDisplayingMessageMenu
            || positionInUserGroup == .single
            || (chatType == .conversation && positionInUserGroup == .last)
            || (chatType == .comments && positionInUserGroup == .first)
    }

    var topPadding: CGFloat {
        if chatType == .comments { return 0 }
        return positionInUserGroup.isTop && !positionInMessagesSection.isTop ? 8 : 4
    }

    var bottomPadding: CGFloat {
        if chatType == .conversation { return 0 }
        return positionInUserGroup.isTop ? 8 : 4
    }

    var body: some View {
        HStack(alignment: .bottom, spacing: 0) {
            if !message.user.isCurrentUser {
                avatarView
            }

            VStack(alignment: message.user.isCurrentUser ? .trailing : .leading, spacing: 2) {
                if !isDisplayingMessageMenu, let reply = message.replyMessage?.toMessage() {
                    replyBubbleView(reply)
                        .opacity(theme.style.replyOpacity)
                        .padding(message.user.isCurrentUser ? .trailing : .leading, 10)
                        .overlay(alignment: message.user.isCurrentUser ? .trailing : .leading) {
                            Capsule()
                                .foregroundColor(theme.colors.mainTint)
                                .frame(width: 2)
                        }
                }

                bubbleView(message)
            }

            if message.user.isCurrentUser, let status = message.status {
                MessageStatusView(status: status) {
                    if case let .error(draft) = status {
                        viewModel.sendMessage(draft)
                    }
                }
                .sizeGetter($statusSize)
            }
        }
        .padding(.top, topPadding)
        .padding(.bottom, bottomPadding)
        .padding(.trailing, message.user.isCurrentUser ? MessageView.horizontalNoAvatarPadding : 0)
        .padding(
            message.user.isCurrentUser ? .leading : .trailing, MessageView.horizontalBubblePadding
        )
        .frame(
            maxWidth: UIScreen.main.bounds.width,
            alignment: message.user.isCurrentUser ? .trailing : .leading)
    }

    @ViewBuilder
    func bubbleView(_ message: Message) -> some View {
        VStack(
            alignment: message.user.isCurrentUser ? .leading : .trailing,
            spacing: -bubbleSize.height / 3
        ) {
            if !isDisplayingMessageMenu && !message.reactions.isEmpty {
                reactionsView(message)
                    .zIndex(1)
            }

            VStack(alignment: .leading, spacing: 0) {
                if !message.text.isEmpty {
                    textWithTimeView(message)
                        .font(Font(font))
                }
            }
            .bubbleBackground(message, theme: theme)
            .zIndex(0)
        }
        .applyIf(isDisplayingMessageMenu) {
            $0.frameGetter($viewModel.messageFrame)
        }
    }

    @ViewBuilder
    func replyBubbleView(_ message: Message) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(message.user.name)
                .fontWeight(.semibold)
                .padding(.horizontal, MessageView.horizontalTextPadding)

            if !message.text.isEmpty {
                MessageTextView(
                    text: message.text, messageStyler: messageStyler,
                    userType: message.user.type, shouldShowLinkPreview: shouldShowLinkPreview,
                    messageLinkPreviewLimit: messageLinkPreviewLimit
                )
                .padding(.horizontal, MessageView.horizontalTextPadding)
            }
        }
        .font(.caption2)
        .padding(.vertical, 8)
        .frame(
            width: nil
        )
        .bubbleBackground(message, theme: theme, isReply: true)
    }

    @ViewBuilder
    var avatarView: some View {
        Group {
            if showAvatar {
                if let url = message.user.avatarURL {
                    AvatarImageView(url: url, avatarSize: avatarSize, avatarCacheKey: message.user.avatarCacheKey)
                        .contentShape(Circle())
                        .onTapGesture {
                            tapAvatarClosure?(message.user, message.id)
                        }
                } else {
                    AvatarNameView(name: message.user.name, avatarSize: avatarSize)
                        .contentShape(Circle())
                        .onTapGesture {
                            tapAvatarClosure?(message.user, message.id)
                        }
                }

            } else {
                Color.clear.viewSize(avatarSize)
            }
        }
        .padding(.leading, MessageView.horizontalScreenEdgePadding)
        .padding(.trailing, MessageView.horizontalAvatarPadding)
        .sizeGetter($avatarViewSize)
    }

    @ViewBuilder
    func attachmentsView(_ message: Message) -> some View {
        EmptyView()
    }

    @ViewBuilder
    func giphyView(_ giphyMediaId: String) -> some View {
        EmptyView()
    }

    @ViewBuilder
    func textWithTimeView(_ message: Message) -> some View {
        let messageView = MessageTextView(
            text: message.text, messageStyler: messageStyler,
            userType: message.user.type, shouldShowLinkPreview: shouldShowLinkPreview,
            messageLinkPreviewLimit: messageLinkPreviewLimit
        )
        .fixedSize(horizontal: false, vertical: true)
        .padding(.horizontal, MessageView.horizontalTextPadding)

        let timeView = messageTimeView()
            .padding(.horizontal, 12)

        Group {
            switch dateArrangement {
            case .hstack:
                HStack(alignment: .lastTextBaseline, spacing: 12) {
                    messageView
                    timeView
                }
                .padding(.vertical, 8)
            case .vstack:
                VStack(alignment: .trailing, spacing: 4) {
                    messageView
                    timeView
                }
                .padding(.vertical, 8)
            case .overlay:
                messageView
                    .padding(.vertical, 8)
                    .overlay(alignment: .bottomTrailing) {
                        timeView
                            .padding(.vertical, 8)
                    }
            }
        }
    }

    func messageTimeView(needsCapsule: Bool = false) -> some View {
        Group {
            if showMessageTimeView {
                if needsCapsule {
                    MessageTimeWithCapsuleView(
                        text: message.time, isCurrentUser: message.user.isCurrentUser,
                        chatTheme: theme)
                } else {
                    MessageTimeView(
                        text: message.time, userType: message.user.type, chatTheme: theme)
                }
            }
        }
        .sizeGetter($timeSize)
    }
}

extension View {

    @ViewBuilder
    func bubbleBackground(_ message: Message, theme: ChatTheme, isReply: Bool = false) -> some View
    {
        let radius: CGFloat = 20
        self
            .foregroundColor(theme.colors.messageText(message.user.type))
            .background {
                if isReply || !message.text.isEmpty {
                    RoundedRectangle(cornerRadius: radius)
                        .foregroundColor(theme.colors.messageBG(message.user.type))
                        .opacity(isReply ? theme.style.replyOpacity : 1)
                }
            }
            .cornerRadius(radius)
    }
}

#if DEBUG
    struct MessageView_Preview: PreviewProvider {
        static let stan = User(id: "stan", name: "Stan", avatarURL: nil, isCurrentUser: false)
        static let john = User(id: "john", name: "John", avatarURL: nil, isCurrentUser: true)

        static private var extraShortText = "Sss"
        static private var extraShortTextWithNewline = "H\nJ"
        static private var shortText = "Hi, buddy!"
        static private var longText =
            "Hello hello hello hello hello hello hello hello hello hello hello hello hello\n hello hello hello hello d d d d d d d d"

        static private var replyedMessage = Message(
            id: UUID().uuidString,
            user: stan,
            status: .read,
            text: longText,
            reactions: [
                Reaction(
                    user: john, createdAt: Date.now.addingTimeInterval(-70), type: .emoji("🔥"),
                    status: .sent),
                Reaction(
                    user: stan, createdAt: Date.now.addingTimeInterval(-60), type: .emoji("🥳"),
                    status: .sent),
                Reaction(
                    user: stan, createdAt: Date.now.addingTimeInterval(-50), type: .emoji("🤠"),
                    status: .sent),
                Reaction(
                    user: stan, createdAt: Date.now.addingTimeInterval(-40), type: .emoji("🧠"),
                    status: .sent),
                Reaction(
                    user: stan, createdAt: Date.now.addingTimeInterval(-30), type: .emoji("🥳"),
                    status: .sent),
                Reaction(
                    user: stan, createdAt: Date.now.addingTimeInterval(-20), type: .emoji("🤯"),
                    status: .sent),
                Reaction(
                    user: john, createdAt: Date.now.addingTimeInterval(-10), type: .emoji("🥰"),
                    status: .sending),
            ]
        )

        static private var message = Message(
            id: UUID().uuidString,
            user: stan,
            status: .read,
            text: shortText,
            replyMessage: replyedMessage.toReplyMessage()
        )

        static private var shortMessage = Message(
            id: UUID().uuidString,
            user: stan,
            status: .read,
            text: extraShortText
        )

        static private var extrShortMessage = Message(
            id: UUID().uuidString,
            user: stan,
            status: .read,
            text: extraShortTextWithNewline
        )
        
        static var previews: some View {
            ZStack {
                Color.yellow.ignoresSafeArea()
                
                VStack {
                    MessageView(
                        viewModel: ChatViewModel(),
                        message: extrShortMessage,
                        positionInUserGroup: .single,
                        positionInMessagesSection: .single,
                        chatType: .conversation,
                        avatarSize: 32,
                        tapAvatarClosure: nil,
                        messageStyler: AttributedString.init,
                        shouldShowLinkPreview: { _ in true },
                        isDisplayingMessageMenu: false,
                        showMessageTimeView: true,
                        messageLinkPreviewLimit: 8,
                        font: UIFontMetrics.default.scaledFont(for: UIFont.systemFont(ofSize: 15))
                    )
                    
                    MessageView(
                        viewModel: ChatViewModel(),
                        message: replyedMessage,
                        positionInUserGroup: .single,
                        positionInMessagesSection: .single,
                        chatType: .conversation,
                        avatarSize: 32,
                        tapAvatarClosure: nil,
                        messageStyler: AttributedString.init,
                        shouldShowLinkPreview: { _ in true },
                        isDisplayingMessageMenu: false,
                        showMessageTimeView: true,
                        messageLinkPreviewLimit: 8,
                        font: UIFontMetrics.default.scaledFont(for: UIFont.systemFont(ofSize: 15))
                    )
                }
                
            }
        }
    }
#endif