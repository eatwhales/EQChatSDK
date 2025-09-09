//
//  Message.swift
//  Chat
//
//  Created by Alisa Mylnikova on 20.04.2022.
//  聊天消息模型 - 定义聊天消息的核心数据结构
//

import SwiftUI

/// 聊天消息结构体 - 表示单个聊天消息的完整信息
/// 包含消息内容、发送者、状态、附件等所有相关数据
public struct Message: Identifiable, Hashable, Sendable {

    /// 消息状态枚举 - 表示消息的发送和接收状态
    public enum Status: Equatable, Hashable, Sendable {
        case sending        // 发送中
        case sent           // 已发送
        case read           // 已读
        case error(DraftMessage)  // 发送失败

        public func hash(into hasher: inout Hasher) {
            switch self {
            case .sending:
                return hasher.combine("sending")
            case .sent:
                return hasher.combine("sent")
            case .read:
                return hasher.combine("read")
            case .error:
                return hasher.combine("error")
            }
        }

        public static func == (lhs: Message.Status, rhs: Message.Status) -> Bool {
            switch (lhs, rhs) {
            case (.sending, .sending):
                return true
            case (.sent, .sent):
                return true
            case (.read, .read):
                return true
            case ( .error(_), .error(_)):
                return true
            default:
                return false
            }
        }
    }

    /// 消息唯一标识符
    public var id: String
    /// 消息发送者信息
    public var user: User
    /// 消息状态（发送中、已发送、已读等）
    public var status: Status?
    /// 消息创建时间
    public var createdAt: Date

    /// 消息文本内容
    public var text: String
    /// 消息反应列表（点赞、表情等）
    public var reactions: [Reaction]
    /// 回复的消息（如果是回复消息）
    public var replyMessage: ReplyMessage?

    /// 触发重绘的UUID（用于强制更新UI）
    public var triggerRedraw: UUID?

    public init(id: String,
                user: User,
                status: Status? = nil,
                createdAt: Date = Date(),
                text: String = "",
                reactions: [Reaction] = [],
                replyMessage: ReplyMessage? = nil) {

        self.id = id
        self.user = user
        self.status = status
        self.createdAt = createdAt
        self.text = text
        self.reactions = reactions
        self.replyMessage = replyMessage
    }

    /// 从草稿消息创建正式消息
    /// - Parameters:
    ///   - id: 消息ID
    ///   - user: 发送者
    ///   - status: 消息状态
    ///   - draft: 草稿消息
    /// - Returns: 创建的消息对象
    public static func makeMessage(
        id: String,
        user: User,
        status: Status? = nil,
        draft: DraftMessage) async -> Message {
            
            return Message(
                id: id,
                user: user,
                status: status,
                createdAt: draft.createdAt,
                text: draft.text,
                replyMessage: draft.replyMessage
            )
        }
}

// MARK: - Message 扩展
extension Message {
    /// 格式化的时间字符串
    var time: String {
        DateFormatter.timeFormatter.string(from: createdAt)
    }
}

extension Message: Equatable {
    public static func == (lhs: Message, rhs: Message) -> Bool {
        lhs.id == rhs.id &&
        lhs.user == rhs.user &&
        lhs.status == rhs.status &&
        lhs.createdAt == rhs.createdAt &&
        lhs.text == rhs.text &&
        lhs.reactions == rhs.reactions &&
        lhs.replyMessage == rhs.replyMessage
    }
}

/// 回复消息结构体 - 表示被回复的消息信息
/// 包含原消息的基本信息，用于在回复时显示引用内容
public struct ReplyMessage: Codable, Identifiable, Hashable, Sendable {
    public static func == (lhs: ReplyMessage, rhs: ReplyMessage) -> Bool {
        lhs.id == rhs.id &&
        lhs.user == rhs.user &&
        lhs.createdAt == rhs.createdAt &&
        lhs.text == rhs.text
    }

    /// 原消息ID
    public var id: String
    /// 原消息发送者
    public var user: User
    /// 原消息创建时间
    public var createdAt: Date

    /// 原消息文本内容
    public var text: String

    public init(id: String,
                user: User,
                createdAt: Date,
                text: String = "") {

        self.id = id
        self.user = user
        self.createdAt = createdAt
        self.text = text
    }

    /// 将回复消息转换为完整消息对象
    /// - Returns: 转换后的消息对象
    func toMessage() -> Message {
        Message(id: id, user: user, createdAt: createdAt, text: text)
    }
}

// MARK: - Message 公共扩展
public extension Message {
    /// 将消息转换为回复消息对象
    /// - Returns: 回复消息对象
    func toReplyMessage() -> ReplyMessage {
        ReplyMessage(id: id, user: user, createdAt: createdAt, text: text)
    }
}