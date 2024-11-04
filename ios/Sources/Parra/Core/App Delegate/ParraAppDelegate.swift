//
//  ParraAppDelegate.swift
//  Parra
//
//  Created by Mick MacCallum on 2/9/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import UIKit
import UserNotifications

// IMPORTANT: Any UIApplicationDelegate methods that are implemented here must
//            be explicitly declared open in order for end users to be able to
//            implement them.

/// A base class that conforms to UIApplicationDelegate. This should be
/// subclassed and its type should be supplied to the `appDelegateType`
/// parameter on the ``Parra/ParraApp`` initializer. In order to avoid
/// unintended behavior, be sure to invoke the super implementation of any
/// delegate methods that require the `override` keyword.
@MainActor
open class ParraAppDelegate<
    SceneDelegateClass: ParraSceneDelegate
>: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    // MARK: - Open

    open func application(
        _ app: UIApplication,
        open url: URL,
        options: [UIApplication.OpenURLOptionsKey: Any] = [:]
    ) -> Bool {
        return true
    }

    open func application(
        _ application: UIApplication,
        handleOpen url: URL
    ) -> Bool {
        return true
    }

    open func application(
        _ application: UIApplication,
        open url: URL,
        sourceApplication: String?,
        annotation: Any
    ) -> Bool {
        return true
    }

    open func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [
            UIApplication
                .LaunchOptionsKey: Any
        ]? = nil
    ) -> Bool {
        // Keep this only enabled for simulator builds, as it's not supported
        // on device and could be dangerous in production. This is a workaround
        // for typing with the physical keyboard dismissing the software
        // keyboard on simulators. Doing this makes it easier to make sure
        // layouts are tested properly with the keyboard up.
        #if targetEnvironment(simulator)
        let selector = NSSelectorFromString("setHardwareLayout:")

        typealias SetHardwareLayoutImp = @convention(c) (
            UITextInputMode,
            Selector
        ) -> Void

        for inputMode in UITextInputMode.activeInputModes {
            if inputMode.responds(to: selector) {
                guard let imp = inputMode.method(for: selector) else {
                    continue
                }

                let function = unsafeBitCast(imp, to: SetHardwareLayoutImp.self)

                function(inputMode, selector)
            }
        }
        #endif

        return true
    }

    open func application(
        _ application: UIApplication,
        didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
    ) {
        parra.registerDevicePushToken(deviceToken)
    }

    open func application(
        _ application: UIApplication,
        didFailToRegisterForRemoteNotificationsWithError error: Error
    ) {
        parra.didFailToRegisterForRemoteNotifications(with: error)
    }

    open func application(
        _ application: UIApplication,
        configurationForConnecting connectingSceneSession: UISceneSession,
        options: UIScene.ConnectionOptions
    ) -> UISceneConfiguration {
        let configuration = UISceneConfiguration(
            name: nil,
            sessionRole: connectingSceneSession.role
        )

        if connectingSceneSession.role == .windowApplication {
            configuration.delegateClass = SceneDelegateClass.self
        }

        return configuration
    }

    open func application(
        _ application: UIApplication,
        supportedInterfaceOrientationsFor window: UIWindow?
    ) -> UIInterfaceOrientationMask {
        return ParraOrientation.orientationLock
    }

    // MARK: UNUserNotificationCenterDelegate

    open nonisolated func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        openSettingsFor notification: UNNotification?
    ) {}

    open nonisolated func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        completionHandler()
    }

    @nonobjc
    open nonisolated func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse
    ) async {}

    open nonisolated func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification
    ) async -> UNNotificationPresentationOptions {
        let pushOptions = await Parra.default.parraInternal.configuration
            .pushNotificationOptions

        var presentationOptions: UNNotificationPresentationOptions = []
        if pushOptions.alerts {
            presentationOptions.insert([.list, .banner])
        }
        if pushOptions.badges {
            presentationOptions.insert(.badge)
        }
        if pushOptions.sounds {
            presentationOptions.insert(.sound)
        }

        return presentationOptions
    }

    @nonobjc
    open nonisolated func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (
            UNNotificationPresentationOptions
        ) -> Void
    ) {
        Task { @MainActor in
            let result = await self.userNotificationCenter(
                center,
                willPresent: notification
            )

            completionHandler(result)
        }
    }

    // MARK: - Public

    public internal(set) var sceneDelegateClass: ParraSceneDelegate.Type! {
        willSet {
            if sceneDelegateClass != nil {
                fatalError(
                    "ParraSceneDelegate can not be set multiple times per execution."
                )
            }
        }
    }

    // MARK: - Internal

    /// Not exposed publicly. Should only ever be set once from the
    /// ``Parra/ParraApp`` initializer as a means of passing the Parra instance
    /// for the app to the app delegate.
    let parra: Parra = .default
}
