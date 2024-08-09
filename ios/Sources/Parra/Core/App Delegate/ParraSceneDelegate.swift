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
open class ParraSceneDelegate: NSObject, ObservableObject, UIWindowSceneDelegate {
    // MARK: - Lifecycle

    override public init() {
        super.init()
    }

    // MARK: - Open

    open func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        guard let windowScene = scene as? UIWindowScene else {
            return
        }

        modalOverlayWindow = {
            let overlay = UIViewController()
            overlay.view.backgroundColor = .clear

            let overlayWindow = NoTouchEventWindow(
                windowScene: windowScene
            )
            overlayWindow.rootViewController = overlay
            overlayWindow.isHidden = false

            return overlayWindow
        }()
    }

    // MARK: - Internal

    /// Used to allow presentation of modals over top of the current app content
    /// regardless of the user's navigation state.
    var modalOverlayWindow: UIWindow?
}
