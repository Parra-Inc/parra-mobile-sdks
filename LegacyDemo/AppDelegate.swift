//
//  AppDelegate.swift
//  Parra Feedback SDK Demo
//
//  Created by Michael MacCallum on 11/22/21.
//

import Parra
import UIKit

private let logger = Logger(category: "UIApplicationDelegate methods")

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [
            UIApplication
                .LaunchOptionsKey: Any
        ]?
    ) -> Bool {
        logger.info("Application finished launching")

        guard NSClassFromString("XCTestCase") == nil else {
            return true
        }

        let myAppAccessToken = "9B5CDA6B-7538-4A2A-9611-7308D56DFFA1"

        // Find this at https://dashboard.parra.io/settings
        let myParraTenantId = "4caab3fe-d0e7-4bc3-9d0a-4b36f32bd1b7"
        // Find this at https://dashboard.parra.io/applications
        let myParraApplicationId = "e9869122-fc90-4266-9da7-e5146d70deab"

        logger.debug("Initializing Parra")

        let theme = ParraTheme(uiColor: .systemBlue)

        Parra.initialize(
            options: [
                .logger(options: .default),
                .pushNotifications,
                .theme(theme)
            ],
            authProvider: .default(
                tenantId: myParraTenantId,
                applicationId: myParraApplicationId
            ) {
                logger.info("Parra authentication provider invoked")

                var request = URLRequest(
                    // Replace this with your Parra access token generation endpoint
                    url: URL(
                        string: "http://localhost:8080/v1/parra/auth/token"
                    )!
                )

                request.httpMethod = "POST"
                // Replace this with your app's way of authenticating users
                request.setValue(
                    "Bearer \(myAppAccessToken)",
                    forHTTPHeaderField: "Authorization"
                )

                let (data, _) = try await URLSession.shared.data(for: request)
                let response = try JSONDecoder().decode(
                    [String: String].self,
                    from: data
                )

                return response["access_token"]!
            }
        )

        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(
        _ application: UIApplication,
        configurationForConnecting connectingSceneSession: UISceneSession,
        options: UIScene.ConnectionOptions
    ) -> UISceneConfiguration {
        return UISceneConfiguration(
            name: "Default Configuration",
            sessionRole: connectingSceneSession.role
        )
    }

    func application(
        _ application: UIApplication,
        didDiscardSceneSessions sceneSessions: Set<UISceneSession>
    ) {}

    // MARK: Push Notifications

    func application(
        _ application: UIApplication,
        didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
    ) {
        logger.info("Successfully registered for push notifications")

        Parra.registerDevicePushToken(deviceToken)
    }

    func application(
        _ application: UIApplication,
        didFailToRegisterForRemoteNotificationsWithError error: Error
    ) {
        logger.warn("Failed to register for push notifications")

        Parra.didFailToRegisterForRemoteNotifications(with: error)
    }
}
