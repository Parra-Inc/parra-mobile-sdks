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
        networkManager: ParraNetworkManager,
        configuration: ParraConfiguration,
        notificationCenter: ParraNotificationCenter
    ) {
        self.containerRenderer = containerRenderer
        self.networkManager = networkManager
        self.configuration = configuration
        self.notificationCenter = notificationCenter
    }

    // MARK: - Internal

    func presentModalView<ContainerType>(
        of type: ContainerType.Type,
        with config: ContainerType.Config = .init(),
        localBuilder: ContainerType.BuilderConfig,
        contentObserver: ContainerType.ContentObserver,
        detents: [UISheetPresentationController.Detent] = [.large()],
        prefersGrabberVisible: Bool = true,
        onDismiss: ((SheetDismissType) -> Void)? = nil
    ) where ContainerType: Container {
        guard let viewController = UIViewController.topMostViewController() else {
            onDismiss?(
                .failed(
                    "Could not establish root view controller to present modal."
                )
            )

            return
        }

        Task { @MainActor in
            let container: ContainerType = containerRenderer.renderContainer(
                with: localBuilder,
                contentObserver: contentObserver,
                config: config
            )

            let themeObserver = ParraThemeObserver(
                theme: configuration.theme,
                notificationCenter: notificationCenter
            )

            let rootView = NavigationStack {
                container
                    .padding(.top, 20)
            }
            .environmentObject(themeObserver)

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

    private let containerRenderer: ContainerRenderer
    private let networkManager: ParraNetworkManager
    private let configuration: ParraConfiguration
    private let notificationCenter: ParraNotificationCenter
}
