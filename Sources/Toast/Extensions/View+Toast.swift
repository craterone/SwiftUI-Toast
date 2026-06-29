//
//  View+Toast.swift
//
//  Created by James Sedlacek on 12/18/23.
//

import SwiftUI

/// Extension to add a toast to any View.
public extension View {

    /// Shows a toast with a provided configuration.
    /// - Parameters:
    ///   - toast: A binding to the toast to display.
    ///   - edge: The edge of the screen where the toast appears.
    ///   - offset: The offset distance from the edge.
    ///   - stayDuration: The duration the toast stays visible on screen before auto-dismissal.
    ///   - autoDismissable: Whether the toast should automatically dismiss.
    ///   - isLast: A closure returning true if this is the last toast.
    ///   - onDismiss: A closure to call when the toast is dismissed.
    ///   - trailingView: A closure that returns a trailing view to be displayed in the toast.
    func toast<TrailingView: View>(
        _ toast: Binding<Toast?>,
        edge: VerticalEdge = .top,
        offset: CGFloat = 0,
        stayDuration: Double = 2.6,
        autoDismissable: Bool = false,
        isLast: @escaping () -> Bool = { true },
        onDismiss: @escaping () -> Void = {},
        @ViewBuilder trailingView: @escaping () -> TrailingView = { EmptyView() }
    ) -> some View {
        modifier(
            ToastModifier(
                toast: toast,
                edge: edge,
                offset: offset,
                stayDuration: stayDuration,
                isAutoDismissed: autoDismissable,
                isLast: isLast,
                onDismiss: onDismiss,
                trailingView: trailingView()
            )
        )
    }
}

public extension View {
    /// Presents a `Toast` using the built‑in default style or any `ToastStyle`
    /// provided with `.toastStyle(_:)` higher in the view hierarchy.
    ///
    /// - Parameters:
    ///   - toast: A binding to the `Toast` to display.
    ///   - edge: The screen edge where the toast appears (`.top` or `.bottom`).
    ///   - offset: The offset distance from the edge.
    ///   - stayDuration: The duration the toast stays visible on screen before auto-dismissal.
    ///   - isAutoDismissed: Pass `true` to let the toast dismiss itself after a
    ///     delay, or `false` to keep it onscreen until the user swipes it away.
    ///   - isLast: A closure returning true if this is the last toast.
    ///   - onDismiss: A closure that’s called after the toast is dismissed
    ///     (either automatically or by the user).
    ///   - trailingView: An optional trailing view—such as a button or progress
    ///     indicator—displayed at the right edge of the toast.
    func toast<T: View>(
        _ toast: Binding<Toast?>,
        edge: VerticalEdge = .top,
        offset: CGFloat = 0,
        stayDuration: Double = 2.6,
        isAutoDismissed: Bool = true,
        isLast: @escaping () -> Bool = { true },
        onDismiss: @escaping () -> Void = {},
        @ViewBuilder trailingView: () -> T = { EmptyView() }
    ) -> some View {
        modifier(
            ToastModifier(
                toast: toast,
                edge: edge,
                offset: offset,
                stayDuration: stayDuration,
                isAutoDismissed: isAutoDismissed,
                isLast: isLast,
                onDismiss: onDismiss,
                trailingView: trailingView()
            )
        )
    }
    
    /// Presents a `Toast` with a custom `ToastStyle`, overriding both the
    /// default look and any style supplied via `.toastStyle(_:)`.
    ///
    /// - Parameters:
    ///   - toast: A binding to the `Toast` to display.
    ///   - style: The `ToastStyle` to apply to *this* toast only.
    ///   - edge: The screen edge where the toast appears (`.top` or `.bottom`).
    ///   - offset: The offset distance from the edge.
    ///   - stayDuration: The duration the toast stays visible on screen before auto-dismissal.
    ///   - isAutoDismissed: Pass `true` to let the toast dismiss itself after a
    ///     delay, or `false` to keep it onscreen until the user swipes it away.
    ///   - isLast: A closure returning true if this is the last toast.
    ///   - onDismiss: A closure that’s called after the toast is dismissed
    ///     (either automatically or by the user).
    ///   - trailingView: An optional trailing view—such as a button or progress
    ///     indicator—displayed at the right edge of the toast.
    func toast<T: View, S: ToastStyle>(
        _ toast: Binding<Toast?>,
        style: S,
        edge: VerticalEdge = .top,
        offset: CGFloat = 0,
        stayDuration: Double = 2.6,
        isAutoDismissed: Bool = true,
        isLast: @escaping () -> Bool = { true },
        onDismiss: @escaping () -> Void = {},
        @ViewBuilder trailingView: () -> T = { EmptyView() }
    ) -> some View {
        modifier(
            ToastModifier(
                toast: toast,
                edge: edge,
                offset: offset,
                stayDuration: stayDuration,
                isAutoDismissed: isAutoDismissed,
                isLast: isLast,
                onDismiss: onDismiss,
                trailingView: trailingView(),
                style: AnyToastStyle(style)
            )
        )
    }
}

public extension View {
    /// 使用 `ToastManager` 队列展示 Toast 提示。
    ///
    /// - Parameters:
    ///   - manager: 管理 Toast 队列的 `ToastManager`。
    ///   - edge: Toast 出现的屏幕边缘 (`.top` 或 `.bottom`)。
    ///   - offset: 呈现在屏幕时的物理偏移量。
    ///   - stayDuration: 自动消失前在屏幕的停留时长。
    ///   - trailingView: 右侧可附加的尾部视图。
    @MainActor
    func toast<T: View>(
        manager: ToastManager,
        edge: VerticalEdge = .top,
        offset: CGFloat = 0,
        stayDuration: Double = 2.6,
        @ViewBuilder trailingView: @escaping () -> T = { EmptyView() }
    ) -> some View {
        self.toast(
            Binding(
                get: { manager.currentToast },
                set: { manager.currentToast = $0 }
            ),
            edge: edge,
            offset: offset,
            stayDuration: stayDuration,
            isAutoDismissed: true,
            isLast: { manager.isQueueEmpty },
            onDismiss: {
                manager.handleDismiss()
            },
            trailingView: trailingView
        )
    }

    /// 使用自定义样式的 `ToastManager` 队列展示 Toast 提示。
    ///
    /// - Parameters:
    ///   - manager: 管理 Toast 队列的 `ToastManager`。
    ///   - style: 应用于当前 Toast 的自定义样式。
    ///   - edge: Toast 出现的屏幕边缘 (`.top` 或 `.bottom`)。
    ///   - offset: 呈现在屏幕时的物理偏移量。
    ///   - stayDuration: 自动消失前在屏幕的停留时长。
    ///   - trailingView: 右侧可附加的尾部视图。
    @MainActor
    func toast<T: View, S: ToastStyle>(
        manager: ToastManager,
        style: S,
        edge: VerticalEdge = .top,
        offset: CGFloat = 0,
        stayDuration: Double = 2.6,
        @ViewBuilder trailingView: @escaping () -> T = { EmptyView() }
    ) -> some View {
        self.toast(
            Binding(
                get: { manager.currentToast },
                set: { manager.currentToast = $0 }
            ),
            style: style,
            edge: edge,
            offset: offset,
            stayDuration: stayDuration,
            isAutoDismissed: true,
            isLast: { manager.isQueueEmpty },
            onDismiss: {
                manager.handleDismiss()
            },
            trailingView: trailingView
        )
    }
}
