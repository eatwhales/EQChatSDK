//
//  Bundle+.swift
//  
//
//  Created by Alex.M on 07.07.2022.
//
//  Bundle扩展 - 提供当前Bundle的访问方法
//

import Foundation

/// Bundle令牌类 - 用于获取当前Bundle的私有辅助类
private final class BundleToken {
    /// 当前Bundle实例
    /// 根据编译环境自动选择正确的Bundle
    static let bundle: Bundle = {
#if SWIFT_PACKAGE
        return Bundle.module
#else
        return Bundle(for: BundleToken.self)
#endif
    }()

    /// 私有初始化方法，防止外部实例化
    private init() {}
}

/// Bundle扩展 - 添加便捷的当前Bundle访问方法
public extension Bundle {
    /// 获取当前Bundle
    /// - Returns: 当前模块的Bundle实例
    static var current: Bundle {
        BundleToken.bundle
    }
}
