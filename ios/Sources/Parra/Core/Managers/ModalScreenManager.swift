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
        containerRenderer: ContainerRenderer,
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

            let container: ModalLoadingIndicatorContainer = containerRenderer
                .renderContainer(
                    contentObserver: ModalLoadingIndicatorContainer
                        .ContentObserver(
                            initialParams: .init(
                                indicatorContent: content
                            )
                        ),
                    config: .init()
                )

            let modalViewController = UIHostingController(
                rootView: container
                    .environment(\.parraTheme, ParraThemeManager.shared.current)
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

    func presentModalView<ContainerType>(
        of type: ContainerType.Type,
        with config: ContainerType.Config = .init(),
        contentObserver: ContainerType.ContentObserver,
        detents: [UISheetPresentationController.Detent] = [.large()],
        prefersGrabberVisible: Bool = true,
        onDismiss: ((ParraSheetDismissType) -> Void)? = nil
    ) where ContainerType: Container {
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

            let container: ContainerType = containerRenderer.renderContainer(
                contentObserver: contentObserver,
                config: config
            )

            let rootView = NavigationStack(
                path: Binding<NavigationPath>(
                    get: {
                        navigationState.navigationPath
                    },
                    set: { path in
                        navigationState.navigationPath = path
                    }
                )
            ) {
                container
                    .padding(.top, 30)
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

    private let containerRenderer: ContainerRenderer
    private let configuration: ParraConfiguration
    private let notificationCenter: ParraNotificationCenter
}
