#
# EQChatSDK.podspec
# 现代化SwiftUI聊天SDK - 提供完整的聊天界面组件
#

Pod::Spec.new do |spec|
  # 基本信息
  spec.name         = "EQChatSDK"
  spec.version      = "1.0.0"
  spec.summary      = "Modern SwiftUI Chat SDK for iOS"
  spec.description  = <<-DESC
                      EQChatSDK是一个基于SwiftUI的现代化聊天SDK，提供完整的聊天界面组件。
                      
                      主要功能：
                      • 实时消息发送和接收
                      • 消息状态显示（发送中、已发送、已读）
                      • 消息回复功能
                      • 表情反应支持
                      • 完全自定义的主题系统
                      • 高度可定制的消息视图
                      • MVVM架构设计
                      • 零外部依赖
                      DESC

  # 项目信息
  spec.homepage     = "https://github.com/eatwhales/EQChatSDK"
  spec.license      = { :type => "MIT", :file => "LICENSE" }
  spec.author       = { "morning" => "morning.yann@gmail.com" }
  
  # 源码信息
  spec.source       = { :git => "https://github.com/eatwhales/EQChatSDK.git", :tag => "#{spec.version}" }
  spec.source_files = "Sources/EQChatSDK/**/*.swift"
  
  # 平台支持
  spec.ios.deployment_target = "16.0"
  spec.swift_version = "5.0"
  
  # 框架依赖
  spec.frameworks = "SwiftUI", "Foundation", "UIKit", "Combine"
  
  # 编译设置
  spec.requires_arc = true
  
  # 模块设置
  spec.module_name = "EQChatSDK"
  
  # 资源文件（如果有的话）
  # spec.resources = "Sources/EQChatSDK/Resources/**/*"
  
  # 子模块（可选，用于更细粒度的模块化）
  # spec.subspec 'Core' do |core|
  #   core.source_files = 'Sources/EQChatSDK/Model/**/*.swift', 'Sources/EQChatSDK/Theme/**/*.swift'
  # end
  
  # spec.subspec 'Views' do |views|
  #   views.source_files = 'Sources/EQChatSDK/Views/**/*.swift'
  #   views.dependency 'EQChatSDK/Core'
  # end
end