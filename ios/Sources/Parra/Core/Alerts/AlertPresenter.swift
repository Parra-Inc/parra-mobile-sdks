//
//  AlertPresenter.swift
//  Parra
//
//  Created by Mick MacCallum on 3/8/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

@MainActor
struct AlertPresenter: ViewModifier {
    // MARK: - Lifecycle

    init(
        alert: Binding<ParraAlertManager.Toast?>
    ) {
        _alert = alert
        _loadingIndicator = .constant(nil)
    }

    init(
        loadingIndicator: Binding<ParraAlertManager.LoadingIndicator?>
    ) {
        _loadingIndicator = loadingIndicator
        _alert = .constant(nil)
    }

    // MARK: - Internal

    @Binding var alert: ParraAlertManager.Toast?
    @Binding var loadingIndicator: ParraAlertManager.LoadingIndicator?

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

                        mainAlertView()
                            .animation(toastAnimation, value: alert)
                            .padding(padding)
                            .safeAreaPadding(.horizontal)
                    }
                }
                .ignoresSafeArea(.container, edges: .vertical)
            }
            .onChange(of: alert) { oldValue, newValue in
                if oldValue == nil, newValue != nil {
                    showAlert()
                } else if oldValue != nil, newValue == nil {
                    dismissAlert()
                }
            }
    }

    @ViewBuilder
    func mainAlertView() -> some View {
        if let alert {
            componentFactory.buildToastAlert(
                level: alert.level,
                content: alert.content,
                onDismiss: alert.onDismiss,
                primaryAction: alert.primaryAction
            )
            .transition(transition)
        }
    }

    // MARK: - Private

    @Environment(\.parraComponentFactory) private var componentFactory
    @Environment(\.defaultSafeAreaInsets) private var defaultSafeAreaInsets
    @Environment(\.parraTheme) private var parraTheme

    @State private var workItem: DispatchWorkItem?

    private var toastAnimation: Animation {
        let duration = alert?.animationDuration ?? 0.25

        return .spring(duration: duration)
    }

    private var alignment: Alignment {
        guard let alert else {
            return .top
        }

        return alert.location.toViewAlignment
    }

    private var transition: MoveTransition {
        guard let alert else {
            return .move(edge: .top)
        }

        return .move(edge: alert.location.isTop ? .top : .bottom)
    }

    private var padding: EdgeInsets {
        let topDefault = EdgeInsets(
            top: defaultSafeAreaInsets.top,
            leading: 0,
            bottom: 0,
            trailing: 0
        )

        guard let alert else {
            return topDefault
        }

        return alert.location.isTop ? topDefault : EdgeInsets(
            top: 0,
            leading: 0,
            bottom: defaultSafeAreaInsets.bottom + 20,
            trailing: 0
        )
    }

    private func showAlert() {
        guard let alert, alert.duration > 0 else {
            return
        }

        UIImpactFeedbackGenerator(style: .light).impactOccurred()

        workItem?.cancel()

        let task = DispatchWorkItem {
            dismissAlert()
        }

        workItem = task

        DispatchQueue.main.asyncAfter(
            // Count 1 animation duration since this task is started almost
            // exactly when the animation to show the alert starts.
            deadline: .now() + alert.duration + alert.animationDuration,
            execute: task
        )
    }

    private func dismissAlert() {
        withAnimation(toastAnimation) {
            alert = nil
        }

        workItem?.cancel()
        workItem = nil
    }
}

extension View {
    @MainActor
    func renderToast(
        toast: Binding<ParraAlertManager.Toast?>
    ) -> some View {
        modifier(
            AlertPresenter(alert: toast)
        )
    }

    @MainActor
    func renderLoadingIndicator(
        loadingIndicator: Binding<ParraAlertManager.LoadingIndicator?>
    ) -> some View {
        modifier(
            AlertPresenter(loadingIndicator: loadingIndicator)
        )
    }
}
