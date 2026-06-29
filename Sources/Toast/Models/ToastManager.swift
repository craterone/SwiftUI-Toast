//
//  ToastManager.swift
//
//  Created by Antigravity on 6/29/26.
//

import SwiftUI

@MainActor
@Observable
public final class ToastManager {
    public static let shared = ToastManager()
    
    public var currentToast: Toast? = nil
    private var queue: [Toast] = []
    private var isProcessing = false
    
    public init() {}
    
    /// 判断队列是否为空
    public var isQueueEmpty: Bool {
        queue.isEmpty
    }
    
    /// 将一个新的 Toast 加入队列并进行展示
    public func show(_ toast: Toast) {
        queue.append(toast)
        processNext()
    }
    
    /// 强行关闭当前处于展示状态的 Toast 并自动轮转到下一个
    public func dismiss() {
        currentToast = nil
        isProcessing = false
        processNext()
    }
    
    private func processNext() {
        guard !isProcessing, !queue.isEmpty else { return }
        isProcessing = true
        currentToast = queue.removeFirst()
    }
    
    /// 当 Toast 界面消失后由修饰器自动回调，用于加载下一条 Toast
    public func handleDismiss() {
        dismiss()
    }
}
