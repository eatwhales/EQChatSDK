//
//  Reaction.swift
//  Chat
//
//  消息反应模型 - 定义用户对消息的表情反应和相关数据结构
//

import Foundation

/// 反应类型枚举 - 定义用户可以对消息添加的反应类型
/// 目前支持表情符号反应，未来可扩展贴纸等其他类型
public enum ReactionType: Codable, Equatable, Hashable, Sendable {
    case emoji(String) /// 表情符号反应
    //case sticker(Image / Giphy / Memoji) /// 贴纸反应（预留）
    //case other... /// 其他类型反应（预留）
    
    /// 转换为字符串表示
    /// 返回反应的字符串形式，主要用于显示
    var toString: String {
        switch self {
        case .emoji(let emoji):
            return emoji
        }
    }
}

/// 消息反应结构体 - 表示用户对特定消息的反应
/// 包含反应的完整信息，如反应者、反应类型、时间和状态
public struct Reaction: Codable, Identifiable, Hashable, Sendable {
    /// 反应唯一标识符
    public let id: String
    /// 添加反应的用户
    public let user: User
    /// 反应创建时间
    public let createdAt: Date
    /// 反应类型（表情、贴纸等）
    public let type: ReactionType
    /// 反应发送状态
    public var status: Status

    /// 初始化消息反应
    /// - Parameters:
    ///   - id: 反应唯一标识符，默认生成UUID
    ///   - user: 添加反应的用户
    ///   - createdAt: 反应创建时间，默认为当前时间
    ///   - type: 反应类型
    ///   - status: 反应状态，默认为发送中
    public init(id: String = UUID().uuidString, user: User, createdAt: Date = .now, type: ReactionType, status: Status = .sending) {
        self.id = id
        self.user = user
        self.createdAt = createdAt
        self.type = type
        self.status = status
    }
    
    /// 获取表情符号字符串
    /// 如果反应类型是表情符号，返回对应的表情字符串
    var emoji: String? {
        switch self.type {
        case .emoji(let emoji): return emoji
        }
    }
}

extension Reaction {
    /// 反应状态枚举 - 定义反应的发送和接收状态
    /// 用于跟踪反应从创建到确认的完整生命周期
    public enum Status: Codable, Equatable, Hashable, Sendable {
        case sending /// 正在发送中
        case sent /// 已发送
        case read /// 已读取
        case error(DraftReaction) /// 发送失败，包含草稿信息
    }
}

/// 草稿反应结构体 - 表示发送失败或待重试的反应
/// 用于在反应发送失败时保存反应信息，支持重新发送
public struct DraftReaction: Codable, Identifiable, Hashable, Sendable {
    /// 草稿反应唯一标识符
    public let id: String
    /// 目标消息标识符
    public let messageID: String
    /// 反应创建时间
    public let createdAt: Date
    /// 反应类型
    public let type: ReactionType

    /// 初始化草稿反应
    /// - Parameters:
    ///   - id: 草稿反应唯一标识符，默认生成UUID
    ///   - messageID: 目标消息的标识符
    ///   - createdAt: 反应创建时间，默认为当前时间
    ///   - type: 反应类型
    public init(id: String = UUID().uuidString, messageID: String, createdAt: Date = .now, type: ReactionType) {
        self.id = id
        self.messageID = messageID
        self.createdAt = createdAt
        self.type = type
    }
}

