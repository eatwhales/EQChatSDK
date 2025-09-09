// swift-tools-version: 5.9
// Package.swift - Swift Package Manager配置文件
// EQChatSDK - 现代化SwiftUI聊天SDK

import PackageDescription

/// EQChatSDK包配置
/// 提供现代化的SwiftUI聊天组件，支持完全自定义和主题化
let package = Package(
    name: "EQChatSDK",
    
    // 平台支持
    platforms: [
        .iOS(.v16)  // 最低支持iOS 16.0
    ],
    
    // 产品定义
    products: [
        .library(
            name: "EQChatSDK",
            targets: ["EQChatSDK"]
        ),
    ],
    
    // 依赖项（当前无外部依赖）
    dependencies: [
        // 无外部依赖，保持SDK轻量化
    ],
    
    // 目标定义
    targets: [
        .target(
            name: "EQChatSDK",
            dependencies: [],
            path: "Sources/EQChatSDK",
            swiftSettings: [
                .enableUpcomingFeature("BareSlashRegexLiterals"),
                .enableUpcomingFeature("ConciseMagicFile"),
                .enableUpcomingFeature("ForwardTrailingClosures"),
                .enableUpcomingFeature("ImplicitOpenExistentials"),
                .enableUpcomingFeature("StrictConcurrency")
            ]
        ),
        
        // 测试目标（可选）
        .testTarget(
            name: "EQChatSDKTests",
            dependencies: ["EQChatSDK"],
            path: "Tests/EQChatSDKTests"
        ),
    ]
)