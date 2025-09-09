//
//  NetworkMonitor.swift
//  
//
//  Created by Alisa Mylnikova on 01.09.2023.
//
//  网络监控器 - 监控网络连接状态的工具类
//

import Foundation
import Network

/// 网络监控器类 - 实时监控网络连接状态
/// 使用NWPathMonitor监控网络变化并通知UI更新
@MainActor
class NetworkMonitor: ObservableObject {
    /// 网络路径监控器
    private let networkMonitor = NWPathMonitor()
    /// 工作队列，用于处理网络状态更新
    private let workerQueue = DispatchQueue(label: "Monitor")
    /// 当前网络连接状态
    var isConnected = false

    /// 初始化网络监控器
    /// 设置网络状态变化回调并开始监控
    init() {
        networkMonitor.pathUpdateHandler = { path in
            Task {
                await MainActor.run {
                    self.isConnected = path.status == .satisfied
                    self.objectWillChange.send()
                }
            }
        }
        networkMonitor.start(queue: workerQueue)
    }
}
