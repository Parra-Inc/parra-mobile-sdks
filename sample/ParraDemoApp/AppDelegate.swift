//
//  AppDelegate.swift
//  Parra Demo
//
//  Bootstrapped with ❤️ by Parra on 06/11/2025.
//  Copyright © 2025 Parra Inc.. All rights reserved.
//

import UIKit
import Parra

class AppDelegate: ParraAppDelegate<ParraSceneDelegate> {
    override func application(
        _ app: UIApplication,
        open url: URL,
        options: [UIApplication.OpenURLOptionsKey : Any] = [:]
    ) -> Bool {
        return AppNavigationState.shared.handleOpenedUrl(url)
    }

    override nonisolated func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        openSettingsFor notification: UNNotification?
    ) {
        if let urlString = notification?.request.content.userInfo["url"] as? String,
           let url = URL(string: urlString) {

            AppNavigationState.shared.handleOpenedUrl(url)
        }
    }
}
