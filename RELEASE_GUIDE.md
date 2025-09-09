# EQChatSDK 发布指南

本指南将详细介绍如何将EQChatSDK发布到GitHub和CocoaPods。

## 📋 发布前准备

### 1. 确认环境要求

- ✅ Git已安装并配置
- ✅ CocoaPods已安装 (`gem install cocoapods`)
- ✅ GitHub账号已创建
- ✅ 代码已提交到本地Git仓库

### 2. 检查项目状态

```bash
# 检查Git状态
git status

# 检查分支
git branch

# 检查远程仓库
git remote -v
```

## 🚀 发布步骤

### 第一步：创建GitHub仓库

1. 访问 [GitHub](https://github.com)
2. 点击右上角的 "+" 按钮，选择 "New repository"
3. 填写仓库信息：
   - **Repository name**: `EQChatSDK`
   - **Description**: `一个功能强大的iOS聊天UI组件库`
   - **Visibility**: Public（公开仓库才能发布到CocoaPods）
   - **不要**勾选 "Add a README file"（我们已经有了）
   - **不要**勾选 "Add .gitignore"（我们已经有了）
   - **不要**选择 "Choose a license"（我们已经有了）

4. 点击 "Create repository"

### 第二步：推送代码到GitHub

```bash
# 推送代码到GitHub
git push -u origin main
```

如果遇到认证问题，可能需要：

```bash
# 使用Personal Access Token
git remote set-url origin https://YOUR_USERNAME:YOUR_TOKEN@github.com/eatwhales/EQChatSDK.git

# 或者使用SSH（推荐）
git remote set-url origin git@github.com:eatwhales/EQChatSDK.git
```

### 第三步：创建第一个Release

#### 方式一：使用脚本（推荐）

```bash
# 创建1.0.0版本
./release.sh 1.0.0
```

#### 方式二：手动创建

1. 在GitHub仓库页面点击 "Releases"
2. 点击 "Create a new release"
3. 填写信息：
   - **Tag version**: `1.0.0`
   - **Release title**: `EQChatSDK v1.0.0`
   - **Description**: 描述此版本的功能和改进
4. 点击 "Publish release"

### 第四步：注册CocoaPods Trunk账号

如果您还没有CocoaPods Trunk账号：

```bash
# 注册账号（替换为您的邮箱和姓名）
pod trunk register your.email@example.com 'Your Name'

# 检查邮箱验证邮件并点击验证链接

# 验证注册状态
pod trunk me
```

### 第五步：发布到CocoaPods

```bash
# 验证podspec文件
pod spec lint EQChatSDK.podspec --allow-warnings

# 发布到CocoaPods Trunk
pod trunk push EQChatSDK.podspec --allow-warnings
```

## 🔧 版本更新流程

### 1. 更新版本号

需要同时更新以下文件中的版本号：

- `EQChatSDK.podspec` 中的 `s.version`
- `Package.swift` 中的版本信息（如果有）

### 2. 提交更改

```bash
# 添加更改
git add .

# 提交更改
git commit -m "Bump version to x.x.x"

# 推送到GitHub
git push origin main
```

### 3. 创建新的Release

```bash
# 使用脚本创建新版本
./release.sh x.x.x
```

### 4. 更新CocoaPods

```bash
# 发布新版本到CocoaPods
pod trunk push EQChatSDK.podspec --allow-warnings
```

## 📊 发布后验证

### 1. 验证GitHub Release

- 访问 `https://github.com/eatwhales/EQChatSDK/releases`
- 确认新版本已正确创建
- 检查Release Notes是否完整

### 2. 验证CocoaPods发布

```bash
# 搜索您的Pod
pod search EQChatSDK

# 检查Pod信息
pod spec cat EQChatSDK
```

### 3. 测试安装

创建一个新的iOS项目进行测试：

```ruby
# Podfile
platform :ios, '14.0'
use_frameworks!

target 'TestApp' do
  pod 'EQChatSDK', '~> 1.0'
end
```

```bash
# 安装测试
pod install
```

## 🐛 常见问题解决

### Q: 推送到GitHub失败

**A**: 检查以下几点：
- GitHub仓库是否已创建
- 远程仓库URL是否正确
- 是否有推送权限
- 网络连接是否正常

### Q: CocoaPods验证失败

**A**: 常见解决方案：
```bash
# 清理CocoaPods缓存
pod cache clean --all

# 更新CocoaPods仓库
pod repo update

# 使用详细模式查看错误
pod spec lint EQChatSDK.podspec --verbose
```

### Q: 版本冲突

**A**: 确保：
- podspec中的版本号与Git tag一致
- 版本号遵循语义化版本规范（如1.0.0）
- 新版本号大于之前发布的版本

### Q: 导入SDK失败

**A**: 检查：
- 项目的iOS部署目标是否满足要求（iOS 14.0+）
- 是否正确导入了SwiftUI框架
- Xcode版本是否支持（Xcode 12.0+）

## 📈 发布最佳实践

### 1. 版本管理

- 遵循[语义化版本](https://semver.org/)规范
- 主版本号：不兼容的API修改
- 次版本号：向下兼容的功能性新增
- 修订号：向下兼容的问题修正

### 2. Release Notes

每个版本都应包含：
- 🆕 新功能
- 🐛 Bug修复
- 💥 破坏性更改
- 📝 文档更新
- ⚡ 性能改进

### 3. 测试策略

发布前确保：
- 所有单元测试通过
- 在不同iOS版本上测试
- 验证示例项目正常运行
- 检查文档的准确性

### 4. 社区支持

- 及时回复GitHub Issues
- 维护详细的文档
- 提供示例代码
- 定期更新依赖

## 📞 获取帮助

如果在发布过程中遇到问题：

- 📖 查看[CocoaPods官方指南](https://guides.cocoapods.org/making/making-a-cocoapod.html)
- 🐛 在[GitHub Issues](https://github.com/eatwhales/EQChatSDK/issues)中提问
- 💬 参考[CocoaPods社区](https://github.com/CocoaPods/CocoaPods/issues)

---

**祝您发布顺利！** 🎉