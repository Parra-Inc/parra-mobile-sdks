//
//  ModalScreenManager.swift
//  Parra
//
//  Created by Mick MacCallum on 3/26/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

final class ModalScreenManager {
    // MARK: - Lifecycle

    init(
        containerRenderer: ParraContainerRenderer,
        configuration: ParraConfiguration,
        notificationCenter: ParraNotificationCenter
    ) {
        self.containerRenderer = containerRenderer
        self.configuration = configuration
        self.notificationCenter = notificationCenter
    }

    // MARK: - Internal

    func presentLoadingIndicatorModal(
        content: ParraLoadingIndicatorContent,
        completion: (() -> Void)? = nil
    ) {
        Task { @MainActor in
            guard currentProgressIndicatorModal == nil else {
                return
            }

            guard
                let viewController = UIViewController
                .safeGetFirstNoTouchWindow()?.rootViewController else
            {
                return
            }

            let navigationState = NavigationState()
            let navigationPath = Binding<NavigationPath>(
                get: {
                    navigationState.navigationPath
                },
                set: { path in
                    navigationState.navigationPath = path
                }
            )

            let container: ModalLoadingIndicatorContainer = containerRenderer
                .renderContainer(
                    contentObserver: ModalLoadingIndicatorContainer
                        .ContentObserver(
                            initialParams: .init(
                                indicatorContent: content
                            )
                        ),
                    config: .init(),
                    navigationPath: navigationPath
                )

            let componentFactory = ParraComponentFactory(
                attributes: configuration.globalComponentAttributes,
                theme: ParraThemeManager.shared.current
            )

            let modalViewController = UIHostingController(
                rootView: container
                    .environment(\.parraTheme, ParraThemeManager.shared.current)
                    .environment(\.parraComponentFactory, componentFactory)
                    .environment(\.parraConfiguration, configuration)
                    .environment(
                        \.parraPreferredAppearance,
                        ParraThemeManager.shared.preferredAppearanceBinding
                    )
            )
            modalViewController.view.backgroundColor = .clear
            modalViewController.modalPresentationStyle = .overCurrentContext

            viewController
                .present(modalViewController, animated: true) {
                    completion?()
                }

            self.currentProgressIndicatorModal = modalViewController
        }
    }

    func dismissLoadingIndicatorModal(
        completion: (() -> Void)? = nil
    ) {
        Task { @MainActor in
            currentProgressIndicatorModal?.dismiss(
                animated: true
            ) {
                completion?()

                self.currentProgressIndicatorModal = nil
            }
        }
    }

    func dismissModalView(
        animated: Bool = true,
        completion: (() -> Void)? = nil
    ) {
        guard
            let viewController = UIViewController
            .safeGetFirstNoTouchWindow()?.rootViewController else
        {
            return
        }

        viewController.dismiss(
            animated: animated,
            completion: completion
        )
    }

    func presentModalView<ContainerType>(
        of type: ContainerType.Type,
        with config: ContainerType.Config,
        contentObserver: ContainerType.ContentObserver,
        detents: [UISheetPresentationController.Detent] = [.large()],
        prefersGrabberVisible: Bool = true,
        showsDismissalButton: Bool = false,
        onDismiss: ((ParraSheetDismissType) -> Void)? = nil
    ) where ContainerType: ParraContainer {
        Task { @MainActor in
            guard
                let viewController = UIViewController
                .safeGetFirstNoTouchWindow()?.rootViewController else
            {
                onDismiss?(
                    .failed(
                        "Could not establish root view controller to present modal."
                    )
                )

                return
            }

            let navigationState = NavigationState()
            let navigationPath = Binding<NavigationPath>(
                get: {
                    navigationState.navigationPath
                },
                set: { path in
                    navigationState.navigationPath = path
                }
            )

            let container: ContainerType = containerRenderer.renderContainer(
                contentObserver: contentObserver,
                config: config,
                navigationPath: navigationPath
            )

            let rootView = NavigationStack(
                path: navigationPath
            ) {
                container
                    .if(showsDismissalButton) { ctx in
                        ctx.toolbar {
                            ToolbarItem(placement: .topBarTrailing) {
                                ParraDismissButton()
                            }
                        }
                    }
            }
            .environment(\.parraTheme, ParraThemeManager.shared.current)
            .environment(
                \.parraPreferredAppearance,
                ParraThemeManager.shared.preferredAppearanceBinding
            )

            let modalViewController = UIHostingController(
                rootView: rootView
            )

            if let presentationController = modalViewController
                .presentationController as? UISheetPresentationController
            {
                presentationController
                    .prefersGrabberVisible = prefersGrabberVisible
                presentationController.detents = detents
            }

            viewController.present(modalViewController, animated: true)
        }
    }

    // MARK: - Private

    @MainActor private var currentProgressIndicatorModal: UIViewController?

    private let containerRenderer: ParraContainerRenderer
    private let configuration: ParraConfiguration
    private let notificationCenter: ParraNotificationCenter
}
