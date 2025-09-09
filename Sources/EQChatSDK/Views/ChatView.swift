import SwiftUI

/// 媒体选择器参数配置
public struct MediaPickerParameters {
    /// 最大选择数量
    public var selectionLimit: Int
    /// 是否显示全屏预览
    public let showFullscreenPreview: Bool
    
    public init(selectionLimit: Int = 1, showFullscreenPreview: Bool = true) {
        self.selectionLimit = selectionLimit
        self.showFullscreenPreview = showFullscreenPreview
    }
}

/// 聊天类型枚举
public enum ChatType: CaseIterable, Sendable {
    case conversation /// 对话模式 - 最新消息在底部，新消息从底部出现
    case comments /// 评论模式 - 最新消息在顶部，新消息从顶部出现
}

/// 回复模式枚举
public enum ReplyMode: CaseIterable, Sendable {
    case quote /// 引用模式 - 回复消息A时，新消息作为最新消息出现，在消息体内引用消息A
    case answer /// 回答模式 - 回复消息A时，新消息直接出现在消息A下方作为独立消息，不重复消息A内容
}

/// 主要聊天视图组件，支持自定义消息视图、输入视图和菜单操作
public struct ChatView<MessageContent: View, InputViewContent: View, MenuAction: MessageMenuAction>: View {
    
    /// 消息视图构建器闭包 - 用于构建自定义消息视图
    /// 参数: message, positionInGroup, positionInMessagesSection, positionInCommentsGroup, 
    ///       showContextMenuClosure, messageActionClosure
    public typealias MessageBuilderClosure = ((
        _ message: Message,
        _ positionInGroup: PositionInUserGroup,
        _ positionInMessagesSection: PositionInMessagesSection,
        _ positionInCommentsGroup: CommentsPosition?,
        _ showContextMenuClosure: @escaping () -> Void,
        _ messageActionClosure: @escaping (Message, DefaultMessageMenuAction) -> Void
    ) -> MessageContent)
    
    /// 输入视图构建器闭包 - 用于构建自定义输入视图
    /// 参数: text(绑定), attachments, inputViewState, inputViewStyle, inputViewActionClosure, dismissKeyboardClosure
    public typealias InputViewBuilderClosure = (
        _ text: Binding<String>,
        _ attachments: InputViewAttachments,
        _ inputViewState: InputViewState,
        _ inputViewStyle: InputViewStyle,
        _ inputViewActionClosure: @escaping (InputViewAction) -> Void,
        _ dismissKeyboardClosure: ()->()
    ) -> InputViewContent
    
    /// 消息菜单操作闭包 - 定义自定义消息菜单操作
    /// 用户和消息Id的头像点击事件闭包
    public typealias TapAvatarClosure = (User, String) -> ()
    /// 消息菜单动作闭包类型定义
    public typealias MessageMenuActionClosure = (MenuAction, @escaping (Message, DefaultMessageMenuAction) -> Void, Message) -> Void
    
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.chatTheme) private var theme
    
    // MARK: - 基本参数
    
    let type: ChatType /// 聊天类型
    let sections: [MessagesSection] /// 消息分组数据
    let ids: [String] /// 消息ID列表
    let didSendMessage: (DraftMessage) -> Void /// 发送消息回调
    var reactionDelegate: ReactionDelegate? /// 反应代理

    // MARK: - 视图构建器
    
    /// 提供自定义消息视图构建器
    var messageBuilder: MessageBuilderClosure? = nil
    
    /// provide custom input view builder
    var inputViewBuilder: InputViewBuilderClosure? = nil
    
    /// message menu customization: create enum complying to MessageMenuAction and pass a closure processing your enum cases
    var messageMenuAction: MessageMenuActionClosure?
    
    /// content to display in between the chat list view and the input view
    var betweenListAndInputViewBuilder: (()->AnyView)?
    
    /// a header for the whole chat, which will scroll together with all the messages and headers
    var mainHeaderBuilder: (()->AnyView)?
    
    /// date section header builder
    var headerBuilder: ((Date)->AnyView)?
    
    /// provide strings for the chat view, these can be localized in the Localizable.strings files
    var localization: ChatLocalization = createLocalization()
    
    // MARK: - Customization
    
    var isListAboveInputView: Bool = true
    var showDateHeaders: Bool = true
    var isScrollEnabled: Bool = true
    var avatarSize: CGFloat = 32
    var messageStyler: (String) -> AttributedString = AttributedString.init
    var shouldShowLinkPreview: (URL) -> Bool = { _ in true }
    var showMessageMenuOnLongPress: Bool = true
    var messageMenuAnimationDuration: Double = 0.3
    var showNetworkConnectionProblem: Bool = false
    var tapAvatarClosure: TapAvatarClosure?
    var mediaPickerSelectionParameters: MediaPickerParameters?
    var orientationHandler: (() -> Void) = {}
    var paginationHandler: PaginationHandler?
    var showMessageTimeView = true
    var messageLinkPreviewLimit = 8
    var messageFont = UIFontMetrics.default.scaledFont(for: UIFont.systemFont(ofSize: 15))
    var availableInputs: [AvailableInputType] = [.text]
    var listSwipeActions: ListSwipeActions = ListSwipeActions()
    var keyboardDismissMode: UIScrollView.KeyboardDismissMode = .none
    
    @StateObject private var viewModel = ChatViewModel()
    @StateObject private var inputViewModel = InputViewModel()
    @StateObject private var globalFocusState = GlobalFocusState()
    @StateObject private var networkMonitor = NetworkMonitor()
    @StateObject private var keyboardState = KeyboardState()
    
    @State private var isScrolledToBottom: Bool = true
    @State private var shouldScrollToTop: () -> () = {}

    /// Used to prevent the MainView from responding to keyboard changes while the Menu is active
    @State private var isShowingMenu = false

    @State private var tableContentHeight: CGFloat = 0
    @State private var inputViewSize = CGSize.zero
    @State private var cellFrames = [String: CGRect]()
    
    public init(messages: [Message],
                chatType: ChatType = .conversation,
                replyMode: ReplyMode = .quote,
                didSendMessage: @escaping (DraftMessage) -> Void,
                reactionDelegate: ReactionDelegate? = nil,
                messageBuilder: @escaping MessageBuilderClosure,
                inputViewBuilder: @escaping InputViewBuilderClosure,
                messageMenuAction: MessageMenuActionClosure?,
                localization: ChatLocalization) {
        self.type = chatType
        self.didSendMessage = didSendMessage
        self.reactionDelegate = reactionDelegate
        self.sections = ChatView.mapMessages(messages, chatType: chatType, replyMode: replyMode)
        self.ids = messages.map { $0.id }
        self.messageBuilder = messageBuilder
        self.inputViewBuilder = inputViewBuilder
        self.messageMenuAction = messageMenuAction
        self.localization = localization
    }
    
    public var body: some View {
        mainView
            .background(chatBackground())
            .environmentObject(keyboardState)
    }
    
    var mainView: some View {
        VStack {
            if showNetworkConnectionProblem, !networkMonitor.isConnected {
                waitingForNetwork
            }
            
            if isListAboveInputView {
                listWithButton
                if let builder = betweenListAndInputViewBuilder {
                    builder()
                }
                inputView
            } else {
                inputView
                if let builder = betweenListAndInputViewBuilder {
                    builder()
                }
                listWithButton
            }
        }
        // Used to prevent ChatView movement during Emoji Keyboard invocation
        .ignoresSafeArea(isShowingMenu ? .keyboard : [])
    }
    
    var waitingForNetwork: some View {
        VStack {
            Rectangle()
                .foregroundColor(theme.colors.mainText.opacity(0.12))
                .frame(height: 1)
            HStack {
                Spacer()
                Image("waiting", bundle: .current)
                Text(localization.waitingForNetwork)
                Spacer()
            }
            .padding(.top, 6)
            Rectangle()
                .foregroundColor(theme.colors.mainText.opacity(0.12))
                .frame(height: 1)
        }
        .padding(.top, 8)
    }
    
    @ViewBuilder
    var listWithButton: some View {
        switch type {
        case .conversation:
            ZStack(alignment: .bottomTrailing) {
                list
                
                if !isScrolledToBottom {
                    Button {
                        NotificationCenter.default.post(name: .onScrollToBottom, object: nil)
                    } label: {
                        theme.images.scrollToBottom
                            .frame(width: 40, height: 40)
                            .circleBackground(theme.colors.messageFriendBG)
                            .foregroundStyle(theme.colors.sendButtonBackground)
                            .shadow(color: .primary.opacity(0.1), radius: 2, y: 1)
                    }
                    .padding(.trailing, MessageView.horizontalScreenEdgePadding)
                    .padding(.bottom, 8)
                }
            }
            
        case .comments:
            list
        }
    }
    
    @ViewBuilder
    var list: some View {
        UIList(
            viewModel: viewModel,
            inputViewModel: inputViewModel,
            isScrolledToBottom: $isScrolledToBottom,
            shouldScrollToTop: $shouldScrollToTop,
            tableContentHeight: $tableContentHeight,
            messageBuilder: messageBuilder,
            mainHeaderBuilder: mainHeaderBuilder,
            headerBuilder: headerBuilder,
            inputView: inputView,
            type: type,
            showDateHeaders: showDateHeaders,
            isScrollEnabled: isScrollEnabled,
            avatarSize: avatarSize,
            showMessageMenuOnLongPress: showMessageMenuOnLongPress,
            tapAvatarClosure: tapAvatarClosure,
            paginationHandler: paginationHandler,
            messageStyler: messageStyler,
            shouldShowLinkPreview: shouldShowLinkPreview,
            showMessageTimeView: showMessageTimeView,
            messageLinkPreviewLimit: messageLinkPreviewLimit,
            messageFont: messageFont,
            sections: sections,
            ids: ids,
            listSwipeActions: listSwipeActions,
            keyboardDismissMode: keyboardDismissMode
        )
        .applyIf(!isScrollEnabled) {
            $0.frame(height: tableContentHeight)
        }
        .onStatusBarTap {
            shouldScrollToTop()
        }
        .transparentNonAnimatingFullScreenCover(item: $viewModel.messageMenuRow) {
            if let row = viewModel.messageMenuRow {
                messageMenu(row)
                    .onAppear(perform: showMessageMenu)
            }
            
        }
        .onPreferenceChange(MessageMenuPreferenceKey.self) { frames in
            DispatchQueue.main.async {
                self.cellFrames = frames
            }
        }
        .simultaneousGesture(
            TapGesture().onEnded {
                globalFocusState.focus = nil
            }
        )
        .onAppear {
            viewModel.didSendMessage = didSendMessage
            viewModel.inputViewModel = inputViewModel
            viewModel.globalFocusState = globalFocusState

            inputViewModel.didSendMessage = { value in
                Task { @MainActor in
                    didSendMessage(value)
                }
                if type == .conversation {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        NotificationCenter.default.post(name: .onScrollToBottom, object: nil)
                    }
                }
            }
        }
    }

    var inputView: some View {
        Group {
            if let inputViewBuilder = inputViewBuilder {
                inputViewBuilder($inputViewModel.text, inputViewModel.attachments, inputViewModel.state, .message, inputViewModel.inputViewAction()) {
                    globalFocusState.focus = nil
                }
            } else {
                InputView(
                    viewModel: inputViewModel,
                    inputFieldId: viewModel.inputFieldId,
                    style: .message,
                    availableInputs: availableInputs,
                    messageStyler: messageStyler,
                    localization: localization
                )
            }
        }
        .sizeGetter($inputViewSize)
        .environmentObject(globalFocusState)
        .onAppear(perform: inputViewModel.onStart)
        .onDisappear(perform: inputViewModel.onStop)
    }
    
    func messageMenu(_ row: MessageRow) -> some View {
        let cellFrame = cellFrames[row.id] ?? .zero

        return MessageMenu(
            viewModel: viewModel,
            isShowingMenu: $isShowingMenu,
            message: row.message,
            cellFrame: cellFrame,
            alignment: menuAlignment(row.message, chatType: type),
            positionInUserGroup: row.positionInUserGroup,
            leadingPadding: avatarSize + MessageView.horizontalAvatarPadding * 2,
            trailingPadding: MessageView.statusViewSize + MessageView.horizontalStatusPadding,
            font: messageFont,
            animationDuration: messageMenuAnimationDuration,
            onAction: menuActionClosure(row.message),
            reactionHandler: MessageMenu.ReactionConfig(
                delegate: reactionDelegate,
                didReact: reactionClosure(row.message)
            )
        ) {
            ChatMessageView(
                viewModel: viewModel, messageBuilder: messageBuilder, row: row, chatType: type,
                avatarSize: avatarSize, tapAvatarClosure: nil, messageStyler: messageStyler,
                shouldShowLinkPreview: shouldShowLinkPreview,
                isDisplayingMessageMenu: true, showMessageTimeView: showMessageTimeView,
                messageLinkPreviewLimit: messageLinkPreviewLimit, messageFont: messageFont
            )
            .onTapGesture {
                hideMessageMenu()
            }
        }
    }
    
    /// Determines the message menu alignment based on ChatType and message sender.
    private func menuAlignment(_ message: Message, chatType: ChatType) -> MessageMenuAlignment {
        switch chatType {
        case .conversation:
            return message.user.isCurrentUser ? .right : .left
        case .comments:
            return .left
        }
    }
    
    /// Our default reactionCallback flow if the user supports Reactions by implementing the didReactToMessage closure
    private func reactionClosure(_ message: Message) -> (ReactionType?) -> () {
        return { reactionType in
            Task {
                // Run the callback on the main thread
                await MainActor.run {
                    // Hide the menu
                    hideMessageMenu()
                    // Send the draft reaction
                    guard let reactionDelegate, let reactionType else { return }
                    reactionDelegate.didReact(to: message, reaction: DraftReaction(messageID: message.id, type: reactionType))
                }
            }
        }
    }
    
    /// Our default Menu Action closure
    func menuActionClosure(_ message: Message) -> (MenuAction) -> () {
        if let messageMenuAction {
            return { action in
                hideMessageMenu()
                messageMenuAction(action, viewModel.messageMenuAction(), message)
            }
        } else if MenuAction.self == DefaultMessageMenuAction.self {
            return { action in
                hideMessageMenu()
                viewModel.messageMenuActionInternal(message: message, action: action as! DefaultMessageMenuAction)
            }
        }
        return { _ in }
    }

    func showMessageMenu() {
        isShowingMenu = true
    }
    
    func hideMessageMenu() {
        viewModel.messageMenuRow = nil
        viewModel.messageFrame = .zero
        isShowingMenu = false
    }
    
    private func chatBackground() -> some View {
        Group {
            
            if let background = theme.images.background {
                
                switch (isLandscape(), colorScheme) {
                case (true, .dark):
                    background.landscapeBackgroundDark
                        .resizable()
                        .ignoresSafeArea(background.safeAreaRegions, edges: background.safeAreaEdges)
                case (true, .light):
                    background.landscapeBackgroundLight
                        .resizable()
                        .ignoresSafeArea(background.safeAreaRegions, edges: background.safeAreaEdges)
                case (false, .dark):
                    background.portraitBackgroundDark
                        .resizable()
                        .ignoresSafeArea(background.safeAreaRegions, edges: background.safeAreaEdges)
                case (false, .light):
                    background.portraitBackgroundLight
                        .resizable()
                        .ignoresSafeArea(background.safeAreaRegions, edges: background.safeAreaEdges)
                }
            } else {
                theme.colors.mainBG
            }
        }
    }
    
    private func isLandscape() -> Bool {
        return UIDevice.current.orientation.isLandscape
    }
    
    private static func createLocalization() -> ChatLocalization {
        return ChatLocalization(
            inputPlaceholder: String(localized: "Type a message..."),
            signatureText: String(localized: "Add signature..."),
            cancelButtonText: String(localized: "Cancel"),
            recentToggleText: String(localized: "Recents"),
            waitingForNetwork: String(localized: "Waiting for network"),
            replyToText: String(localized: "Reply to")
        )
    }
}

public extension ChatView {
    
    func betweenListAndInputViewBuilder<V: View>(_ builder: @escaping ()->V) -> ChatView {
        var view = self
        view.betweenListAndInputViewBuilder = {
            AnyView(builder())
        }
        return view
    }
    
    func mainHeaderBuilder<V: View>(_ builder: @escaping ()->V) -> ChatView {
        var view = self
        view.mainHeaderBuilder = {
            AnyView(builder())
        }
        return view
    }
    
    func headerBuilder<V: View>(_ builder: @escaping (Date)->V) -> ChatView {
        var view = self
        view.headerBuilder = { date in
            AnyView(builder(date))
        }
        return view
    }
    
    func isListAboveInputView(_ isAbove: Bool) -> ChatView {
        var view = self
        view.isListAboveInputView = isAbove
        return view
    }
    
    func showDateHeaders(_ showDateHeaders: Bool) -> ChatView {
        var view = self
        view.showDateHeaders = showDateHeaders
        return view
    }
    
    func isScrollEnabled(_ isScrollEnabled: Bool) -> ChatView {
        var view = self
        view.isScrollEnabled = isScrollEnabled
        return view
    }
    
    func showMessageMenuOnLongPress(_ show: Bool) -> ChatView {
        var view = self
        view.showMessageMenuOnLongPress = show
        return view
    }
    
    /// Sets the keyboard dismiss mode for the chat list
    /// - Parameter mode: The keyboard dismiss mode (.interactive, .onDrag, or .none)
    /// - Default is .none
    func keyboardDismissMode(_ mode: UIScrollView.KeyboardDismissMode) -> ChatView {
        var view = self
        view.keyboardDismissMode = mode
        return view
    }
    
    func showNetworkConnectionProblem(_ show: Bool) -> ChatView {
        var view = self
        view.showNetworkConnectionProblem = show
        return view
    }
    
    func assetsPickerLimit(assetsPickerLimit: Int) -> ChatView {
        var view = self
        view.mediaPickerSelectionParameters = MediaPickerParameters()
        view.mediaPickerSelectionParameters?.selectionLimit = assetsPickerLimit
        return view
    }
    
    func setMediaPickerSelectionParameters(_ params: MediaPickerParameters) -> ChatView {
        var view = self
        view.mediaPickerSelectionParameters = params
        return view
    }

    /// when user scrolls up to `pageSize`-th meassage, call the handler function, so user can load more messages
    /// NOTE: doesn't work well with `isScrollEnabled` false
    func enableLoadMore(pageSize: Int, _ handler: @escaping ChatPaginationClosure) -> ChatView {
        var view = self
        view.paginationHandler = PaginationHandler(handleClosure: handler, pageSize: pageSize)
        return view
    }
    
    @available(*, deprecated)
    func chatNavigation(title: String, status: String? = nil, cover: URL? = nil) -> some View {
        var view = self
//        view.chatTitle = title
        return view.modifier(ChatNavigationModifier(title: title, status: status, cover: cover))
    }
    
    // makes sense only for built-in message view
    
    func avatarSize(avatarSize: CGFloat) -> ChatView {
        var view = self
        view.avatarSize = avatarSize
        return view
    }
    
    func tapAvatarClosure(_ closure: @escaping TapAvatarClosure) -> ChatView {
        var view = self
        view.tapAvatarClosure = closure
        return view
    }
    
    func messageUseMarkdown(_ messageUseMarkdown: Bool) -> ChatView {
        return messageUseStyler(String.markdownStyler)
    }

    func messageUseStyler(_ styler: @escaping (String) -> AttributedString) -> ChatView {
        var view = self
        view.messageStyler = styler
        return view
    }
    
    func shouldShowLinkPreview(_ shouldShowLinkPreview: @escaping (URL) -> Bool) -> ChatView {
        var view = self
        view.shouldShowLinkPreview = shouldShowLinkPreview
        return view
    }

    func showMessageTimeView(_ isShow: Bool) -> ChatView {
        var view = self
        view.showMessageTimeView = isShow
        return view
    }

    func messageLinkPreviewLimit(_ limit: Int) -> ChatView {
        var view = self
        view.messageLinkPreviewLimit = limit
        return view
    }
    
    func linkPreviewsDisabled() -> ChatView {
        return messageLinkPreviewLimit(0)
    }

    func setMessageFont(_ font: UIFont) -> ChatView {
        var view = self
        view.messageFont = font
        return view
    }
    
    // makes sense only for built-in input view
    
    func setAvailableInputs(_ types: [AvailableInputType]) -> ChatView {
        var view = self
        view.availableInputs = types
        return view
    }
    
    /// Sets the general duration of various message menu animations
    ///
    /// This value is more akin to 'how snappy' the message menu feels
    /// - Note: Good values are between 0.15 - 0.5 (defaults to 0.3)
    /// - Important: This value is clamped between 0.1 and 1.0
    func messageMenuAnimationDuration(_ duration:Double) -> ChatView {
        var view = self
        view.messageMenuAnimationDuration = max(0.1, min(1.0, duration))
        return view
    }
    
    /// Sets a ReactionDelegate on the ChatView for handling and configuring message reactions
    func messageReactionDelegate(_ configuration: ReactionDelegate) -> ChatView {
        var view = self
        view.reactionDelegate = configuration
        return view
    }
    
    /// Constructs, and applies, a ReactionDelegate for you based on the provided closures
    func onMessageReaction(
        didReactTo: @escaping (Message, DraftReaction) -> Void,
        canReactTo: ((Message) -> Bool)? = nil,
        availableReactionsFor: ((Message) -> [ReactionType]?)? = nil,
        allowEmojiSearchFor: ((Message) -> Bool)? = nil,
        shouldShowOverviewFor: ((Message) -> Bool)? = nil
    ) -> ChatView {
        var view = self
        view.reactionDelegate = DefaultReactionConfiguration(
            didReact: didReactTo,
            canReact: canReactTo,
            reactions: availableReactionsFor,
            allowEmojiSearch: allowEmojiSearchFor,
            shouldShowOverview: shouldShowOverviewFor
        )
        return view
    }
}

#Preview {
    let romeo = User(id: "romeo", name: "Romeo Montague", avatarURL: nil, isCurrentUser: true)
    let juliet = User(id: "juliet", name: "Juliet Capulet", avatarURL: nil, isCurrentUser: false)

    let monday = try! Date.iso8601Date.parse("2025-05-12")
    let tuesday = try! Date.iso8601Date.parse("2025-05-13")

    ChatView(messages: [
        Message(
            id: "26tb", user: romeo, status: .read, createdAt: monday,
            text: "And I’ll still stay, to have thee still forget"),
        Message(
            id: "zee6", user: romeo, status: .read, createdAt: monday,
            text: "Forgetting any other home but this"),

        Message(
            id: "oWUN", user: juliet, status: .read, createdAt: monday,
            text: "’Tis almost morning. I would have thee gone"),
        Message(
            id: "P261", user: juliet, status: .read, createdAt: monday,
            text: "And yet no farther than a wanton’s bird"),
        Message(
            id: "46hu", user: juliet, status: .read, createdAt: monday,
            text: "That lets it hop a little from his hand"),
        Message(
            id: "Gjbm", user: juliet, status: .read, createdAt: monday,
            text: "Like a poor prisoner in his twisted gyves"),
        Message(
            id: "IhRQ", user: juliet, status: .read, createdAt: monday,
            text: "And with a silken thread plucks it back again"),
        Message(
            id: "kwWd", user: juliet, status: .read, createdAt: monday,
            text: "So loving-jealous of his liberty"),

        Message(
            id: "9481", user: romeo, status: .read, createdAt: tuesday,
            text: "I would I were thy bird"),

        Message(
            id: "dzmY", user: juliet, status: .sent, createdAt: tuesday, text: "Sweet, so would I"),
        Message(
            id: "r5HH", user: juliet, status: .sent, createdAt: tuesday,
            text: "Yet I should kill thee with much cherishing"),
        Message(
            id: "quy1", user: juliet, status: .sent, createdAt: tuesday,
            text: "Good night, good night. Parting is such sweet sorrow"),
        Message(
            id: "Mwh6", user: juliet, status: .sent, createdAt: tuesday,
            text: "That I shall say 'Good night' till it be morrow"),
    ]) { draft in }
}