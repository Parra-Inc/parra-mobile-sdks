//
//  ParraSceneDelegate.swift
//  Parra
//
//  Created by Mick MacCallum on 3/25/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import CloudKit
import SwiftUI
import UIKit

@MainActor
open class ParraSceneDelegate: NSObject, UIWindowSceneDelegate {
    // MARK: - Lifecycle

    override public init() {
        super.init()
    }

    // MARK: - Open

    open func scene(
        _ scene: UIScene,
        openURLContexts URLContexts: Set<UIOpenURLContext>
    ) {}

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

    open func windowScene(
        _ windowScene: UIWindowScene,
        performActionFor shortcutItem: UIApplicationShortcutItem
    ) async -> Bool {
        return Parra.default.parraInternal.launchShortcutManager
            .handleLaunchShortcut(shortcutItem)
    }

    @nonobjc
    open func windowScene(
        _ windowScene: UIWindowScene,
        performActionFor shortcutItem: UIApplicationShortcutItem,
        completionHandler: @escaping (Bool) -> Void
    ) {}

    open func windowScene(
        _ windowScene: UIWindowScene,
        didUpdate previousCoordinateSpace: any UICoordinateSpace,
        interfaceOrientation previousInterfaceOrientation: UIInterfaceOrientation,
        traitCollection previousTraitCollection: UITraitCollection
    ) {}

    open func windowScene(
        _ windowScene: UIWindowScene,
        userDidAcceptCloudKitShareWith cloudKitShareMetadata: CKShare.Metadata
    ) {}

    // MARK: - Internal

    /// Used to allow presentation of modals over top of the current app content
    /// regardless of the user's navigation state.
    var modalOverlayWindow: UIWindow?
}
