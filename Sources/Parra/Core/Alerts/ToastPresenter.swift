//
//  ToastPresenter.swift
//  Parra
//
//  Created by Mick MacCallum on 3/8/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

// TODO: Top presentation from modal views results in too much top padding.

struct ToastPresenter: ViewModifier {
    @Environment(\.defaultSafeAreaInsets) private var defaultSafeAreaInsets
    @EnvironmentObject var themeObserver: ParraThemeObserver
    @EnvironmentObject var componentFactory: ComponentFactory

    @Binding var toast: AlertManager.Alert?

    @State private var workItem: DispatchWorkItem?

    private var toastAnimation: Animation {
        let duration = toast?.animationDuration ?? 0.25

        return .spring(duration: duration)
    }

    private var alignment: Alignment {
        guard let toast else {
            return .top
        }

        return toast.location.toViewAlignment
    }

    private var transition: MoveTransition {
        guard let toast else {
            return .move(edge: .top)
        }

        return .move(edge: toast.location.isTop ? .top : .bottom)
    }

    private var padding: EdgeInsets {
        let topDefault = EdgeInsets(
            top: defaultSafeAreaInsets.top,
            leading: 0,
            bottom: 0,
            trailing: 0
        )

        guard let toast else {
            return topDefault
        }

        return toast.location.isTop ? topDefault : EdgeInsets(
            top: 0,
            leading: 0,
            bottom: defaultSafeAreaInsets.bottom + 20,
            trailing: 0
        )
    }

    func body(content: Content) -> some View {
        content
            .overlay {
                GeometryReader { proxy in
                    ZStack(alignment: alignment) {
                        Color.clear
                            .frame(
                                width: proxy.size.width,
                                height: proxy.size.height
                            )

                        mainToastView()
                            .animation(toastAnimation, value: toast)
                            .padding(padding)
                            .safeAreaPadding(.horizontal)
                    }
                }
                .ignoresSafeArea(.container, edges: .vertical)
            }
            .onChange(of: toast) { oldValue, newValue in
                if oldValue == nil, newValue != nil {
                    showToast()
                } else if oldValue != nil, newValue == nil {
                    dismissToast()
                }
            }
    }

    @ViewBuilder
    func mainToastView() -> some View {
        if let toast {
            componentFactory.buildToastAlert(
                level: toast.level,
                content: toast.content,
                onDismiss: toast.onDismiss,
                primaryAction: toast.primaryAction
            )
            .transition(transition)
        }
    }

    private func showToast() {
        guard let toast, toast.duration > 0 else {
            return
        }

        UIImpactFeedbackGenerator(style: .light).impactOccurred()

        workItem?.cancel()

        let task = DispatchWorkItem {
            dismissToast()
        }

        workItem = task

        DispatchQueue.main.asyncAfter(
            // Count 1 animation duration since this task is started almost
            // exactly when the animation to show the alert starts.
            deadline: .now() + toast.duration + toast.animationDuration,
            execute: task
        )
    }

    private func dismissToast() {
        withAnimation(toastAnimation) {
            toast = nil
        }

        workItem?.cancel()
        workItem = nil
    }
}

extension View {
    func renderToast(
        toast: Binding<AlertManager.Alert?>
    ) -> some View {
        modifier(
            ToastPresenter(toast: toast)
        )
    }
}
