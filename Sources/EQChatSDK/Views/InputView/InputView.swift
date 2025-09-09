import SwiftUI

/// 输入视图样式枚举
public enum InputViewStyle: Sendable {
    case message /// 消息输入模式
    case signature /// 签名输入模式
}

/// 输入视图操作枚举
public enum InputViewAction: Sendable {
    case send /// 发送消息
    case saveEdit /// 保存编辑
    case cancelEdit /// 取消编辑
}

/// 输入视图状态枚举
public enum InputViewState: Sendable {
    case empty /// 空状态
    case hasText /// 有文本内容
    case editing /// 编辑状态
    
    /// 检查当前状态是否可以发送消息
    /// 只有在有文本内容时才允许发送
    var canSend: Bool {
        switch self {
        case .hasText: return true
        default: return false
        }
    }
}

/// 可用输入类型枚举 - 定义输入视图支持的输入方式
public enum AvailableInputType: Sendable {
    case text /// 文本输入
}

/// 输入视图附件结构体 - 管理输入相关的附加信息
public struct InputViewAttachments {
    var replyMessage: ReplyMessage? /// 回复的消息
}

/// 输入视图结构体 - 聊天界面的消息输入组件
/// 提供文本输入、回复消息、发送按钮等完整的输入功能
struct InputView: View {
    
    /// 聊天主题环境变量
    @Environment(\.chatTheme) private var theme
    /// 键盘状态环境对象
    @EnvironmentObject private var keyboardState: KeyboardState
    
    /// 输入视图模型
    @ObservedObject var viewModel: InputViewModel
    /// 输入框唯一标识符
    var inputFieldId: UUID
    /// 输入视图样式
    var style: InputViewStyle
    /// 可用的输入类型列表
    var availableInputs: [AvailableInputType]
    /// 消息样式处理器
    var messageStyler: (String) -> AttributedString
    /// 本地化配置
    var localization: ChatLocalization
    
    /// 输入视图操作回调
    /// 返回处理输入视图操作的闭包
    private var onAction: (InputViewAction) -> Void {
        viewModel.inputViewAction()
    }
    
    /// 当前输入视图状态
    /// 从视图模型获取当前状态
    private var state: InputViewState {
        viewModel.state
    }
    
    /// 视图主体 - 构建完整的输入界面
    /// 包含顶部回复视图、输入框和发送按钮
    var body: some View {
        VStack {
            viewOnTop
            HStack(alignment: .bottom, spacing: 10) {
                HStack(alignment: .bottom, spacing: 0) {
                    leftView
                    middleView
                    rightView
                }
                .background {
                    RoundedRectangle(cornerRadius: 18)
                        .fill(style == .message ? theme.colors.inputBG : theme.colors.inputSignatureBG)
                }
                
                rightOutsideButton
            }
            .padding(.horizontal, MessageView.horizontalScreenEdgePadding)
            .padding(.vertical, 8)
        }
        .background(backgroundColor)
        .onDrag(towards: .bottom, ofAmount: 100...) {
            keyboardState.resignFirstResponder()
        }
    }
    
    @ViewBuilder
    var leftView: some View {
        switch style {
        case .message:
            Color.clear.frame(width: 12, height: 1)
        case .signature:
            Color.clear.frame(width: 12, height: 1)
        }
    }
    
    @ViewBuilder
    var middleView: some View {
        TextInputView(
            text: $viewModel.text,
            inputFieldId: inputFieldId,
            style: style,
            availableInputs: availableInputs,
            localization: localization
        )
        .frame(minHeight: 48)
    }
    
    @ViewBuilder
    var rightView: some View {
        Group {
            switch state {
            case .empty:
                Color.clear.frame(width: 8, height: 1)
            default:
                Color.clear.frame(width: 8, height: 1)
            }
        }
        .frame(minHeight: 48)
    }
    
    @ViewBuilder
    var editingButtons: some View {
        HStack {
            Button {
                onAction(.cancelEdit)
            } label: {
                Image(systemName: "xmark")
                    .foregroundStyle(.white)
                    .fontWeight(.bold)
                    .padding(5)
                    .background(Circle().foregroundStyle(.red))
            }
            
            Button {
                onAction(.saveEdit)
            } label: {
                Image(systemName: "checkmark")
                    .foregroundStyle(.white)
                    .fontWeight(.bold)
                    .padding(5)
                    .background(Circle().foregroundStyle(.green))
            }
        }
    }
    
    @ViewBuilder
    var rightOutsideButton: some View {
        if state == .editing {
            editingButtons
                .frame(height: 48)
        } else {
            sendButton
                .disabled(!state.canSend)
                .viewSize(48)
        }
    }
    
    @ViewBuilder
    var viewOnTop: some View {
        if let message = viewModel.attachments.replyMessage {
            VStack(spacing: 8) {
                Rectangle()
                    .foregroundColor(theme.colors.messageFriendBG)
                    .frame(height: 2)
                
                HStack {
                    theme.images.reply.replyToMessage
                    Capsule()
                        .foregroundColor(theme.colors.messageMyBG)
                        .frame(width: 2)
                    VStack(alignment: .leading) {
                        Text(localization.replyToText + " " + message.user.name)
                            .font(.caption2)
                            .foregroundColor(theme.colors.mainCaptionText)
                        if !message.text.isEmpty {
                            textView(message.text)
                                .font(.caption2)
                                .lineLimit(1)
                                .foregroundColor(theme.colors.mainText)
                        }
                    }
                    .padding(.vertical, 2)
                    
                    Spacer()
                    
                    theme.images.reply.cancelReply
                        .onTapGesture {
                            viewModel.attachments.replyMessage = nil
                        }
                }
                .padding(.horizontal, 26)
            }
            .fixedSize(horizontal: false, vertical: true)
        }
    }
    
    @ViewBuilder
    func textView(_ text: String) -> some View {
        Text(text.styled(using: messageStyler))
    }
    
    var attachButton: some View {
        Color.clear.frame(width: 24, height: 24)
            .padding(EdgeInsets(top: 12, leading: 12, bottom: 12, trailing: 6))
    }
    
    var cameraButton: some View {
        Color.clear.frame(width: 24, height: 24)
            .padding(EdgeInsets(top: 12, leading: 8, bottom: 12, trailing: 12))
    }
    
    var sendButton: some View {
        Button {
            onAction(.send)
        } label: {
            theme.images.inputView.arrowSend
                .viewSize(48)
                .circleBackground(theme.colors.sendButtonBackground)
        }
    }
    
    var backgroundColor: Color {
        theme.colors.mainBG
    }
    
    private func isMediaAvailable() -> Bool {
        return false
    }
}

@MainActor
func performBatchTableUpdates(_ tableView: UITableView, closure: ()->()) async {
    await withCheckedContinuation { continuation in
        tableView.performBatchUpdates {
            closure()
        } completion: { _ in
            continuation.resume()
        }
    }
}