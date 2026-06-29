//
//  ToastModifier.swift
//
//  Created by James Sedlacek on 1/5/25.
//

import SwiftUI

//MARK: - ToastStyle Environment Support

/// Environment key that stores the style to be user by 'ToastMessageView'
private struct ToastStyleEnvironmentKey: EnvironmentKey {
    /// 'nil' means fallback to the built-in default style
    static let defaultValue: AnyToastStyle? = nil
}

extension EnvironmentValues {
    /// Current 'ToastStyle' for the view hierarchy, if one was provided with
    /// '.toastStyle(_: )''.
    var toastStyle: AnyToastStyle? {
        get { self[ToastStyleEnvironmentKey.self] }
        set { self[ToastStyleEnvironmentKey.self] = newValue }
    }
}

public extension View {
    /// Sets a custom 'ToastStyle' for the new hierarchy. Works just like .buttonStyle(_:), so you can call it high up in the view tree once:
    ///
    /// ContentView()
    ///     .toastStyle(MyToastStyle())
    ///
    /// Every 'Toast' presented below that call will automatically adopt the given style, unless an explicit style is supplied to the individual '.toast' invocation.
    
    func toastStyle<S: ToastStyle>(_ style: S) -> some View {
        environment(\.toastStyle, AnyToastStyle(style))
    }
}

@MainActor
struct ToastModifier<TrailingView: View>: ViewModifier {
    private let edge: VerticalEdge
    private let offset: CGFloat
    private let stayDuration: Double
    private let isAutoDismissed: Bool
    private let onDismiss: () -> Void
    private let trailingView: TrailingView
    @Binding private var toast: Toast?
    @Environment(\.toastStyle) private var environmentStyle
    private let explicitStyle: AnyToastStyle?
    @State private var isPresented: Bool = false

    private var yOffset: CGFloat {
        if isPresented {
            return edge == .top ? offset : -offset
        } else {
            return edge == .top ? -300 : 300
        }
    }

    init(
        toast: Binding<Toast?>,
        edge: VerticalEdge,
        offset: CGFloat = 0,
        stayDuration: Double = 2.6,
        isAutoDismissed: Bool,
        onDismiss: @escaping () -> Void,
        trailingView: TrailingView,
        style: AnyToastStyle? = nil
    ) {
        self._toast = toast
        self.edge = edge
        self.offset = offset
        self.stayDuration = stayDuration
        self.isAutoDismissed = isAutoDismissed
        self.trailingView = trailingView
        self.onDismiss = onDismiss
        self.explicitStyle = style
    }

    private func onChangeDragGesture(_ value: DragGesture.Value) {
        dismissToastAnimation()
    }

    private func presentToastAnimation() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            withAnimation(.spring()) {
                isPresented = true
            }
        }
        if isAutoDismissed {
            autoDismissToastAnimation()
        }
    }

    private func dismissToastAnimation() {
        withAnimation(.easeOut(duration: 0.8)) {
            isPresented = false
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            toast = nil
            onDismiss()
        }
    }

    private func autoDismissToastAnimation() {
        DispatchQueue.main.asyncAfter(deadline: .now() + stayDuration) {
            dismissToastAnimation()
        }
    }

    func body(content: Content) -> some View {
        content
            .onChange(of: toast) { newToast in
                if newToast != nil {
                    presentToastAnimation()
                }
            }
            .overlay(
                alignment: edge.alignment,
                content: toastView
            )
    }

    @ViewBuilder
    private func toastView() -> some View {
        if let toast {
            let chosenStyle = explicitStyle ?? environmentStyle
            
            if let style = chosenStyle {
                ToastMessageView(toast,
                                 style: style,
                                 trailingView: {trailingView})
                .offset(y: yOffset)
                .gesture(dragGesture)
            } else {
                ToastMessageView(toast, trailingView: { trailingView })
                    .offset(y: yOffset)
                    .gesture(dragGesture)
            }
        }
    }

    private var dragGesture: some Gesture {
        DragGesture(minimumDistance: .zero)
            .onChanged(onChangeDragGesture)
    }
}
