//
//  SceneDelegate.swift
//  {{ app.name.raw }}
//
//  Bootstrapped with ❤️ by Parra on {{ "now" | date: "%m/%d/%Y" }}.
//  Copyright © {{ "now" | date: "%Y" }} {{ tenant.name }}. All rights reserved.
//

import SwiftUI
import Parra

class SceneDelegate: ParraSceneDelegate {
    override func scene(
        _ scene: UIScene,
        openURLContexts URLContexts: Set<UIOpenURLContext>
    ) {
        super.scene(scene, openURLContexts: URLContexts)

        if let url = URLContexts.first?.url {
            AppNavigationState.shared.handleOpenedUrl(url)
        }
    }

    override func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        super.scene(scene, willConnectTo: session, options: connectionOptions)

        if let urlContext = connectionOptions.urlContexts.first {
            AppNavigationState.shared.handleOpenedUrl(urlContext.url)
        }
    }
}
