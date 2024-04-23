//
//  Parra+Auth.swift
//  Parra
//
//  Created by Mick MacCallum on 4/23/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import UIKit

public extension Parra {
    // MARK: - Authentication

    /// Used to clear any cached credentials for the current user. After calling
    /// ``Parra/Parra/logout()``, the authentication provider you configured
    /// will be invoked the very next time the Parra API is accessed.
    @MainActor
    func logout() async {
        // immediately kick off a sync that we don't wait for. Then present the
        // user the opportunity to confirm/cancel. If they confirm logout,
        // enqueue another sync and wait for it to complete before logging out.
        // We want to make best effort to upload sessions/other data before
        // logging out and invalidating the token while minimizing the time it
        // takes to logout.

        await parraInternal.syncManager.enqueueSync(
            with: .immediate,
            waitUntilSyncCompletes: false
        )

        let confirmed = await confirmLogout()

        guard confirmed else {
            return
        }

        parraInternal.syncManager.stopSyncTimer()

        await parraInternal.syncManager.enqueueSync(
            with: .immediate,
            waitUntilSyncCompletes: true
        )

        await parraInternal.authService.logout()
    }

    /// Used to clear any cached credentials for the current user. After calling
    /// ``Parra/Parra/logout()``, the authentication provider you configured
    /// will be invoked the very next time the Parra API is accessed.
    func logout(_ completion: (() -> Void)? = nil) {
        Task {
            await logout()
            completion?()
        }
    }

    func confirmLogout() async -> Bool {
        await withCheckedContinuation { continuation in
            Task { @MainActor in
                let alertView = UIAlertController(
                    title: "Logout",
                    message: "Are you sure you want to logout?",
                    preferredStyle: .alert
                )
                alertView.addAction(
                    UIAlertAction(
                        title: "Logout",
                        style: .destructive,
                        handler: { _ in
                            continuation.resume(returning: true)
                        }
                    )
                )
                alertView.addAction(
                    UIAlertAction(
                        title: "Cancel",
                        style: .cancel,
                        handler: { _ in
                            continuation.resume(returning: false)
                        }
                    )
                )

                let root = UIViewController.topMostViewController()

                root?.present(alertView, animated: true)
            }
        }
    }
}
