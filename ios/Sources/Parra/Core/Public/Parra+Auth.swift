//
//  Parra+Auth.swift
//  Parra
//
//  Created by Mick MacCallum on 4/23/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import UIKit

public final class ParraAuth {
    // MARK: - Lifecycle

    init(parraInternal: ParraInternal) {
        self.parraInternal = parraInternal
    }

    // MARK: - Public

    // MARK: - Account Management

//    /// Create a new passkey and link it to the current account.
//    public func addPasskey() async throws {
//        guard case .parra = parraInternal.authService.authenticationMethod else {
//            throw ParraError.message(
//                "Parra authentication was not used. Parra can not add a passkey to this account automatically."
//            )
//        }
//
//        // TODO: This
//    }

    public func deleteAccount(
        title: String = "Delete account",
        message: String =
            "This will permanently delete your account and any identifying data associated with your account. You can not undo this action.",
        primaryAction: String = "Confirm"
    ) async throws {
        let confirmed = await confirmAction(
            title: title,
            message: message,
            primaryAction: primaryAction
        )

        guard confirmed else {
            return
        }

        guard let appInfo = parraInternal.appState.appInfo else {
            throw ParraError.message(
                "Failed to delete account. Can't retreive necessary app info."
            )
        }

        try await parraInternal.api.deleteAccount()

        // Don't perform sync steps first.
        await parraInternal.authService.logout(
            appInfo: appInfo
        )
    }

    public func deleteAccount(
        _ completion: ((Error?) -> Void)? = nil
    ) {
        Task {
            do {
                try await deleteAccount()

                completion?(nil)
            } catch {
                completion?(error)
            }
        }
    }

    // MARK: - Logout

    /// Used to clear any cached credentials for the current user. After calling
    /// ``Parra/Parra/logout()``, the authentication provider you configured
    /// will be invoked the very next time the Parra API is accessed.
    public func logout() async {
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

        let confirmed = await confirmAction()

        guard confirmed else {
            return
        }

        guard let appInfo = parraInternal.appState.appInfo else {
            return
        }

        await parraInternal.syncManager.stopSyncTimer()

        await parraInternal.syncManager.enqueueSync(
            with: .immediate,
            waitUntilSyncCompletes: true
        )

        await parraInternal.authService.logout(
            appInfo: appInfo
        )
    }

    /// Used to clear any cached credentials for the current user. After calling
    /// ``Parra/Parra/logout()``, the authentication provider you configured
    /// will be invoked the very next time the Parra API is accessed.
    public func logout(_ completion: (() -> Void)? = nil) {
        Task {
            await logout()
            completion?()
        }
    }

    // MARK: - Internal

    let parraInternal: ParraInternal

    // MARK: - Private

    private func confirmAction(
        title: String = "Logout",
        message: String = "Are you sure you want to logout?",
        primaryAction: String = "Logout"
    ) async -> Bool {
        await withCheckedContinuation { continuation in
            Task { @MainActor in
                let alertView = UIAlertController(
                    title: title,
                    message: message,
                    preferredStyle: .alert
                )
                alertView.addAction(
                    UIAlertAction(
                        title: primaryAction,
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
