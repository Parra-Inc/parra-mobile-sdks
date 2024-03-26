//
//  ParraSceneDelegate.swift
//  Parra
//
//  Created by Mick MacCallum on 3/25/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI
import UIKit

@MainActor
open class ParraSceneDelegate: NSObject, UIWindowSceneDelegate {
    // MARK: - Open

    open func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        guard let windowScene = scene as? UIWindowScene else {
            return
        }

        let modalOverlayViewController = UIViewController()
        modalOverlayViewController.view.backgroundColor = .clear

        let modalOverlayWindow = NoTouchEventWindow(
            windowScene: windowScene
        )
        modalOverlayWindow.rootViewController = modalOverlayViewController
        modalOverlayWindow.isHidden = false

        self.modalOverlayWindow = modalOverlayWindow
    }

    // MARK: - Internal

    /// Used to allow presentation of modals over top of the current app content
    /// regardless of the user's navigation state.
    var modalOverlayWindow: UIWindow?

    func presentModalView(
        @ViewBuilder with content: @escaping () -> some View,
        onDismiss: ((SheetDismissType) -> Void)? = nil
    ) {
        guard let rootViewController = modalOverlayWindow?.rootViewController else {
            onDismiss?(
                .failed(
                    "Could not establish root view controller to present modal."
                )
            )

            return
        }

        let modalViewController = UIHostingController(
            rootView:
            EmptyView()
                .frame(
                    maxWidth: .infinity,
                    maxHeight: .infinity
                )
                .presentSheet(
                    isPresented: .constant(true),
                    content: content,
                    onDismiss: onDismiss
                )
        )

        rootViewController.present(modalViewController, animated: true)
    }
}
