//
//  ParraAppDelegate.swift
//  Parra
//
//  Created by Mick MacCallum on 2/9/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import UIKit

// IMPORTANT: Any UIApplicationDelegate methods that are implemented here must
//            be explicitly declared open in order for end users to be able to
//            implement them.

/// A base class that conforms to UIApplicationDelegate. This should be
/// subclassed and its type should be supplied to the `appDelegateType`
/// parameter on the ``Parra/ParraApp`` initializer. In order to avoid
/// unintended behavior, be sure to invoke the super implementation of any
/// delegate methods that require the `override` keyword.
@MainActor
open class ParraAppDelegate: NSObject, ObservableObject, UIApplicationDelegate {
    // MARK: - Open

    open func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [
            UIApplication
                .LaunchOptionsKey: Any
        ]? = nil
    ) -> Bool {
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
            configuration.delegateClass = sceneDelegateClass
        }

        return configuration
    }

    open func application(
        _ application: UIApplication,
        supportedInterfaceOrientationsFor window: UIWindow?
    ) -> UIInterfaceOrientationMask {
        return ParraAppDelegate.orientationLock
    }

    // MARK: - Public

    public internal(set) var sceneDelegateClass: ParraSceneDelegate.Type!

    // MARK: - Internal

    static var orientationLock = UIInterfaceOrientationMask.all

    /// Not exposed publicly. Should only ever be set once from the
    /// ``Parra/ParraApp`` initializer as a means of passing the Parra instance
    /// for the app to the app delegate.
    let parra: Parra = .default
}
