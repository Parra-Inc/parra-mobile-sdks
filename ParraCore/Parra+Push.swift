//
//  Parra+Push.swift
//  ParraCore
//
//  Created by Mick MacCallum on 6/24/23.
//  Copyright © 2023 Parra, Inc. All rights reserved.
//

import Foundation

public extension Parra {

    /// This method should be invoked from the UIApplication delegate method
    /// application(_:didRegisterForRemoteNotificationsWithDeviceToken:), passing in the Data parameter from this method.
    ///
    /// Calling this method will upload the device's push notification token to the Parra API, to enable push notifications
    /// to the device. If this method isn't being called, you may have forgotten to call
    /// application.registerForRemoteNotifications() in your app delegate's didFinishLaunchingWithOptions method, after
    /// initilizing Parra. For more information, see:
    ///  https://developer.apple.com/documentation/usernotifications/registering_your_app_with_apns
    @MainActor
    class func registerDevicePushToken(_ token: Data) {
        parraLogDebug("Registering device push token")

        let tokenString = token.map { String(format: "%02.2hhx", $0) }.joined()

        Task {
            await registerDevicePushTokenString(tokenString)
        }
    }

    internal class func registerDevicePushTokenString(_ tokenString: String) async {
        guard await ParraGlobalState.shared.isInitialized() else {
            parraLogWarn("Parra.registerDevicePushToken was called before Parra.initialize(). Make sure that you're calling Parra.initialize() before application.registerForRemoteNotifications()")

            // Still try to recover from this situation. Temporarily cache the token, which we can check for when
            // initialization does occur and proceed to upload it.
            await ParraGlobalState.shared.setTemporaryPushToken(tokenString)

            return
        }

        await uploadDevicePushToken(tokenString)
    }

    internal class func uploadDevicePushToken(_ token: String) async {
        do {
            try await Parra.API.Push.uploadPushToken(token: token)

            parraLogTrace("Device push token successfully uploaded. Clearing cache.")
            // Token shouldn't be cached when it isn't absolutely necessary to recover from errors. If a new token
            // is issued, it will replace the old one.
            await ParraGlobalState.shared.clearTemporaryPushToken()
        } catch let error {
            parraLogTrace("Device push token failed to upload. Caching token to try later.")
            // In the event that the upload failed, we'll cache the token. This will be overridden by any new token
            // on the next app launch, but in the event that we're able to retry the request later, we'll have this
            // one on hand.
            await ParraGlobalState.shared.setTemporaryPushToken(token)

            parraLogError("Error uploading push token to Parra API", error)
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
    class func didFailToRegisterForRemoteNotifications(with error: Error) {
        parraLogError("Failed to register for remote notifications", error)
    }
}
