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

    public func triggerAuthRefresh() async throws {
        try await parraInternal.authService.performAuthStateRefresh()
    }

    // MARK: - Account Management

    @discardableResult
    public func deleteAccount(
        title: String = "Delete account",
        message: String =
            "This will permanently delete your account and any identifying data associated with your account. You can not undo this action.",
        primaryAction: String = "Confirm"
    ) async throws -> Bool {
        let confirmed = await confirmAction(
            title: title,
            message: message,
            primaryAction: primaryAction
        )

        guard confirmed else {
            return false
        }

        try await parraInternal.api.deleteAccount()

        // Don't perform sync steps first.
        await parraInternal.authService.logout()

        return true
    }

    public func deleteAccount(
        _ completion: ((_ success: Bool, _ error: Error?) -> Void)? = nil
    ) {
        Task {
            do {
                let result = try await deleteAccount()

                completion?(result, nil)
            } catch {
                completion?(false, error)
            }
        }
    }

    // MARK: - Logout

    /// Used to clear any cached credentials for the current user. After calling
    /// ``Parra/Parra/logout()``, the authentication provider you configured
    /// will be invoked the very next time the Parra API is accessed.
    @discardableResult
    public func logout(
        postLogoutTasks: (() async throws -> Void)? = nil
    ) async -> Bool {
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
            return false
        }

        await parraInternal.syncManager.stopSyncTimer()

        await parraInternal.syncManager.enqueueSync(
            with: .immediate,
            waitUntilSyncCompletes: true
        )

        await parraInternal.authService.logout(
            postLogoutTasks: postLogoutTasks
        )

        return true
    }

    /// Used to clear any cached credentials for the current user. After calling
    /// ``Parra/Parra/logout()``, the authentication provider you configured
    /// will be invoked the very next time the Parra API is accessed.
    public func logout(_ completion: ((_ success: Bool) -> Void)? = nil) {
        Task {
            let result = await logout()
            completion?(result)
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
