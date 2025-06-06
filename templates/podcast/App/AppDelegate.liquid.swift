//
//  AppDelegate.swift
//  {{ app.name.raw }}
//
//  Bootstrapped with ❤️ by Parra on {{ "now" | date: "%m/%d/%Y" }}.
//  Copyright © {{ "now" | date: "%Y" }} {{ tenant.name }}. All rights reserved.
//

import UIKit
import Parra

class AppDelegate: ParraAppDelegate<SceneDelegate> {
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
        AppNavigationState.shared.handleDeepLink(.settingsTab("notification-settings"))
    }

    override nonisolated func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse
    ) async {
        await super.userNotificationCenter(center, didReceive: response)

        let userInfo = response.notification.request.content.userInfo

        if let urlString = userInfo["url"] as? String,
           let url = URL(string: urlString) {

            AppNavigationState.shared.handleOpenedUrl(url)
        }
    }
}
