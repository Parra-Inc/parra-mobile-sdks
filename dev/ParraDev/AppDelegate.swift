//
//  AppDelegate.swift
//  ParraDev
//
//  Created by Mick MacCallum on 11/1/24.
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
