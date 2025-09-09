import Foundation

/// 草稿消息结构体 - 表示用户正在编辑或准备发送的消息
/// 用于在消息正式发送前临时存储消息内容和相关信息
public struct DraftMessage: Sendable {
    /// 消息临时标识符（可选）
    public var id: String?
    /// 消息文本内容
    public let text: String
    /// 回复的消息（如果是回复消息）
    public let replyMessage: ReplyMessage?
    /// 消息创建时间
    public let createdAt: Date
    
    /// 初始化草稿消息
    /// - Parameters:
    ///   - id: 消息临时标识符，默认为nil
    ///   - text: 消息文本内容
    ///   - replyMessage: 回复的消息，如果不是回复则为nil
    ///   - createdAt: 消息创建时间
    public init(id: String? = nil,
                text: String,
                replyMessage: ReplyMessage?,
                createdAt: Date) {
        self.id = id
        self.text = text
        self.replyMessage = replyMessage
        self.createdAt = createdAt
    }
}