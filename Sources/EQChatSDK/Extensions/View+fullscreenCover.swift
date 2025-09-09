import SwiftUI

/// 视图扩展 - 添加透明无动画全屏覆盖功能
extension View {

    /// 显示透明无动画的全屏覆盖视图
    /// - Parameters:
    ///   - item: 绑定的可选项，当不为nil时显示覆盖视图
    ///   - content: 覆盖视图的内容构建器
    /// - Returns: 带有全屏覆盖功能的视图
    func transparentNonAnimatingFullScreenCover<Item, Content>(item: Binding<Item?>, @ViewBuilder content: @escaping () -> Content) -> some View where Item : Equatable, Item : Identifiable, Content : View {
        modifier(TransparentNonAnimatableFullScreenModifier(item: item, fullScreenContent: content))
    }
}

private struct TransparentNonAnimatableFullScreenModifier<Item, FullScreenContent>: ViewModifier where Item : Equatable, Item : Identifiable, FullScreenContent : View {

    @Binding var item: Item?
    let fullScreenContent: () -> (FullScreenContent)

    func body(content: Content) -> some View {
        content
            .onChange(of: item) { _ in
                UIView.setAnimationsEnabled(false)
            }
            .fullScreenCover(item: $item) { _ in
                ZStack {
                    fullScreenContent()
                }
                .background(FullScreenCoverBackgroundRemovalView())
                .onAppear {
                    if !UIView.areAnimationsEnabled {
                        UIView.setAnimationsEnabled(true)
                    }
                }
                .onDisappear {
                    if !UIView.areAnimationsEnabled {
                        UIView.setAnimationsEnabled(true)
                    }
                }
            }
    }

}

private struct FullScreenCoverBackgroundRemovalView: UIViewRepresentable {

    private class BackgroundRemovalView: UIView {
        override func didMoveToWindow() {
            super.didMoveToWindow()
            superview?.superview?.backgroundColor = .clear
        }
    }

    func makeUIView(context: Context) -> UIView {
        return BackgroundRemovalView()
    }

    func updateUIView(_ uiView: UIView, context: Context) {}

}
