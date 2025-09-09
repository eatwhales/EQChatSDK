//
//  Created by Alex.M on 17.06.2022.
//  用户模型 - 定义聊天用户的基本信息和类型
//

import Foundation

/// 用户类型枚举 - 区分当前用户、其他用户和系统消息
public enum UserType: Int, Codable, Sendable {
    case current = 0    // 当前用户（发送方）
    case other          // 其他用户（接收方）
    case system         // 系统消息
}

/// 用户信息结构体 - 包含用户的基本信息和头像等数据
/// 用于标识聊天中的每个参与者
public struct User: Codable, Identifiable, Hashable, Sendable {
    /// 用户唯一标识符
    public let id: String
    /// 用户显示名称
    public let name: String
    /// 用户头像URL
    public let avatarURL: URL?
    /// 头像缓存键（用于优化头像加载）
    public let avatarCacheKey: String?
    /// 用户类型（当前用户/其他用户/系统）
    public let type: UserType
    /// 是否为当前用户的便捷属性
    public var isCurrentUser: Bool { type == .current }
    
    /// 使用布尔值初始化用户（推荐用于简单场景）
    /// - Parameters:
    ///   - id: 用户ID
    ///   - name: 用户名称
    ///   - avatarURL: 头像URL
    ///   - avatarCacheKey: 头像缓存键
    ///   - isCurrentUser: 是否为当前用户
    public init(id: String, name: String, avatarURL: URL?, avatarCacheKey: String? = nil, isCurrentUser: Bool) {
        self.id = id
        self.name = name
        self.avatarURL = avatarURL
        self.avatarCacheKey = avatarCacheKey
        self.type = isCurrentUser ? .current : .other
    }
    
    /// 使用用户类型初始化用户（推荐用于需要系统消息的场景）
    /// - Parameters:
    ///   - id: 用户ID
    ///   - name: 用户名称
    ///   - avatarURL: 头像URL
    ///   - avatarCacheKey: 头像缓存键
    ///   - type: 用户类型
    public init(id: String, name: String, avatarURL: URL?, avatarCacheKey: String? = nil, type: UserType) {
        self.id = id
        self.name = name
        self.avatarURL = avatarURL
        self.avatarCacheKey = avatarCacheKey
        self.type = type
    }
}
