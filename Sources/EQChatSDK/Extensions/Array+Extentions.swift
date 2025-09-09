//
//  Array+Extensions.swift
//  
//
//  Created by Alisa Mylnikova on 25.12.2023.
//
//  数组扩展 - 为可标识元素数组提供工具方法
//

import Foundation

/// 数组扩展 - 为包含可标识元素的数组添加实用方法
extension Array where Element: Identifiable {
    /// 检查数组中所有元素的ID是否唯一
    /// - Returns: 如果所有ID都唯一则返回true，否则返回false
    func hasUniqueIDs() -> Bool {
        var uniqueElements: [Element.ID] = []
        for el in self {
            if !uniqueElements.contains(el.id) {
                uniqueElements.append(el.id)
            } else {
                return false
            }
        }
        return true
    }
}
