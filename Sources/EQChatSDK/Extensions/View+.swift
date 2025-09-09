//
//  View+.swift
//
//
//  Created by Alisa Mylnikova on 09.03.2023.
//
//  视图扩展 - 提供常用的视图修饰符和工具方法
//

import SwiftUI

/// 视图扩展 - 添加常用的视图修饰符
extension View {
    /// 设置视图为指定大小的正方形
    /// - Parameter size: 正方形的边长
    /// - Returns: 修饰后的视图
    func viewSize(_ size: CGFloat) -> some View {
        self.frame(width: size, height: size)
    }
    
    /// 设置视图为指定宽度、高度为1像素的矩形
    /// - Parameter width: 矩形的宽度
    /// - Returns: 修饰后的视图
    func viewWidth(_ width: CGFloat) -> some View {
        self.frame(width: width, height: 1)
    }

    /// 为视图添加圆形背景
    /// - Parameter color: 背景颜色
    /// - Returns: 带有圆形背景的视图
    func circleBackground(_ color: Color) -> some View {
        self.background {
            Circle().fill(color)
        }
    }

    /// 条件性应用视图修饰符
    /// - Parameters:
    ///   - condition: 应用条件
    ///   - apply: 当条件为真时应用的修饰符
    /// - Returns: 根据条件修饰后的视图
    @ViewBuilder
    func applyIf<T: View>(_ condition: Bool, apply: (Self) -> T) -> some View {
        if condition {
            apply(self)
        } else {
            self
        }
    }
}

struct CustomDragGesture: ViewModifier {
    let direction:Edge
    let amount: any RangeExpression<CGFloat>
    let action: () -> Void

    func body(content: Content) -> some View {
        content
            .gesture(
                DragGesture()
                    .onEnded { val in
                        switch direction {
                        case .top:
                            if amount.contains( -val.translation.height ) { action() }
                        case .leading:
                            if amount.contains( -val.translation.width ) { action() }
                        case .bottom:
                            if amount.contains( val.translation.height ) { action() }
                        case .trailing:
                            if amount.contains( val.translation.width ) { action() }
                        }
                    }
            )
    }
}

extension View {
    /// Adds a Drag Gesture listener on the View that will perform the provided action when a drag ofAmount pixels is performed in the direction indicated
    /// - Parameters:
    ///   - edge: The edge the drag should be towards
    ///   - amount: The number of pixels the drag should traverse in order to trigger the action
    ///   - action: The action to perform when a drag gesture that fits the above criteria is performed
    /// - Returns: The modified view
    public func onDrag(towards edge: Edge, ofAmount amount: any RangeExpression<CGFloat>, perform action: @escaping () -> Void) -> some View {
        modifier(CustomDragGesture(direction: edge, amount: amount, action: action))
    }
}
