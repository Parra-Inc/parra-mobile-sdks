//
//  Parra+Push.swift
//  Parra
//
//  Created by Mick MacCallum on 6/24/23.
//  Copyright © 2023 Parra, Inc. All rights reserved.
//

import Foundation
import UserNotifications

private let logger = Logger(category: "Push")

extension Parra {
    @MainActor
    public func requestPushPermission() async throws -> Bool {
        return try await Parra.default.push.requestPushPermission()
    }

    /// This method should be invoked from the UIApplication delegate method
    /// application(_:didRegisterForRemoteNotificationsWithDeviceToken:), passing in the Data parameter from this method.
    ///
    /// Calling this method will upload the device's push notification token to the Parra API, to enable push notifications
    /// to the device. If this method isn't being called, you may have forgotten to call
    /// application.registerForRemoteNotifications() in your app delegate's didFinishLaunchingWithOptions method, after
    /// initilizing Parra. For more information, see:
    ///  https://developer.apple.com/documentation/usernotifications/registering_your_app_with_apns
    @MainActor
    func registerDevicePushToken(
        _ token: Data
    ) {
        Task {
            logger.debug("Registering device push token")

            let tokenString = token.map {
                return String(format: "%02.2hhx", $0)
            }.joined()

            await uploadDevicePushToken(tokenString)
        }
    }

    func uploadDevicePushToken(
        _ token: String
    ) async {
        do {
            try await parraInternal.api.uploadPushToken(token: token)

            logger.trace("Device push token successfully uploaded.")
        } catch {
            logger.error("Error uploading push token to Parra API", error)
        }
    }

    /// This method should be invoked from the UIApplication delegate method
    /// application(_:didFailToRegisterForRemoteNotificationsWithError:) and pass in its error parameter to indicate to
    /// the Parra API that push notification token regsitration has failed for this device.
    ///
    /// Registration might fail if the user’s device isn’t connected to the network, if the APNs server is
    /// unreachable for any reason, or if the app doesn’t have the proper code-signing entitlement. When a failure
    /// occurs, set a flag and try to register again at a later time.
    @MainActor
    func didFailToRegisterForRemoteNotifications(
        with error: Error
    ) {
        logger.error("Failed to register for remote notifications", error)
    }
}
