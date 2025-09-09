//
//  View+StatusBar.swift
//  
//
//  Created by Alisa Mylnikova on 02.06.2023.
//
//  状态栏点击检测扩展 - 提供状态栏点击事件监听功能
//

import SwiftUI
import UIKit

/// 视图扩展 - 添加状态栏点击检测功能
public extension View {

    /// 添加状态栏点击事件监听
    /// 注意：为了正常工作，需要确保其他scrollView的scrollsToTop属性设为false
    /// - Parameter onTap: 状态栏被点击时的回调闭包
    /// - Returns: 带有状态栏点击检测功能的视图
    func onStatusBarTap(onTap: @escaping () -> ()) -> some View {
        self.overlay {
            StatusBarTabDetector(onTap: onTap)
                .offset(x: UIScreen.main.bounds.width)
        }
    }
}

/// 状态栏点击检测器 - 使用隐藏的UIScrollView检测状态栏点击
private struct StatusBarTabDetector: UIViewRepresentable {

    /// 点击回调闭包
    var onTap: () -> ()

    /// 创建UIView实例
    /// 创建一个隐藏的UIScrollView用于检测状态栏点击
    /// - Parameter context: SwiftUI上下文
    /// - Returns: 配置好的UIScrollView
    func makeUIView(context: Context) -> UIView {
        let fakeScrollView = UIScrollView()
        fakeScrollView.contentOffset = CGPoint(x: 0, y: 10)
        fakeScrollView.delegate = context.coordinator
        fakeScrollView.scrollsToTop = true
        fakeScrollView.contentSize = CGSize(width: 100, height: UIScreen.main.bounds.height * 2)
        return fakeScrollView
    }

    /// 更新UIView（空实现）
    /// - Parameters:
    ///   - uiView: 要更新的UIView
    ///   - context: SwiftUI上下文
    func updateUIView(_ uiView: UIView, context: Context) {}

    /// 创建协调器
    /// - Returns: 状态栏点击检测协调器
    func makeCoordinator() -> Coordinator {
        Coordinator(onTap: onTap)
    }

    /// 状态栏点击检测协调器 - 处理UIScrollView的代理方法
    class Coordinator: NSObject, UIScrollViewDelegate {

        /// 点击回调闭包
        var onTap: () -> ()

        /// 初始化协调器
        /// - Parameter onTap: 状态栏点击回调
        init(onTap: @escaping () -> ()) {
            self.onTap = onTap
        }

        /// UIScrollView代理方法 - 检测状态栏点击
        /// - Parameter scrollView: 触发事件的scrollView
        /// - Returns: 始终返回false，阻止实际滚动
        func scrollViewShouldScrollToTop(_ scrollView: UIScrollView) -> Bool {
            onTap()
            return false
        }
    }
}
