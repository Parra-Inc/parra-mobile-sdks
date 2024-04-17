//
//  ParraAuthState.swift
//  Parra
//
//  Created by Mick MacCallum on 4/15/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import os
import SwiftUI

private let logger = Logger()

public class ParraAuthState: ObservableObject, Equatable {
    // MARK: - Public

    @Published
    public private(set) var current: ParraAuthResult = .unauthenticated(nil)

    public static func == (
        lhs: ParraAuthState,
        rhs: ParraAuthState
    ) -> Bool {
        switch (lhs.current, rhs.current) {
        case (.authenticated(let lhsUser), .authenticated(let rhsUser)):
            return lhsUser == rhsUser
        case (.unauthenticated(let lhsError), .unauthenticated(let rhsError)):
            return lhsError?.localizedDescription == rhsError?
                .localizedDescription
        default:
            return false
        }
    }

    // MARK: - Internal

    @MainActor
    func performInitialAuthCheck(
        using authService: AuthService
    ) async {
        beginObservingAuth()

        let cachedUser = await authService.getCurrentUser()

        if let cachedUser {
            logger.debug("Found cached user")

            current = .authenticated(cachedUser)

            do {
                // Only try to refresh if auth state actually existed.
                try await authService.refreshExistingToken()
            } catch {
                printInvalidAuth(error: error)
            }
        } else {
            logger.debug("No cached user found")

            current = .unauthenticated(nil)
        }
    }

    // MARK: - Private

    private var authObserver: NSObjectProtocol?

    private func beginObservingAuth() {
        authObserver = ParraNotificationCenter.default.addObserver(
            forName: Parra.authenticationStateDidChangeNotification,
            object: nil,
            queue: .main
        ) { notification in
            self.handleAuthChange(notification: notification)
        }
    }

    private func printInvalidAuth(error: Error) {
        let printDefaultError: () -> Void = {
            logger.error(
                "Authentication handler in call to Parra.initialize failed",
                error
            )
        }

        guard let parraError = error as? ParraError else {
            printDefaultError()

            return
        }

        switch parraError {
        case .authenticationFailed(let underlying):
            let systemLogger = os.Logger(
                subsystem: "Parra",
                category: "initialization"
            )

            // Bypassing main logger here because we won't want to include the
            // normal formatting/backtrace/etc. We want to display as clear of
            // a message as is possible. Note the exclamations prevent
            // whitespace trimming from removing the padding newlines.
            systemLogger.log(
                level: .fault,
                "!\n\n\n\n\n\n\nERROR INITIALIZING PARRA!\nThe authentication provider passed to ParraApp returned an error. The user was unable to be verified.\n\nUnderlying error:\n\(underlying)\n\n\n\n\n\n\n!"
            )
        default:
            printDefaultError()
        }
    }

    private func handleAuthChange(notification: Notification) {
        guard let userInfo = notification.userInfo,
              let result =
              userInfo[Parra.authenticationStateKey] as? ParraAuthResult else
        {
            logger.error("Received invalid auth state change notification")

            return
        }

        current = result
    }
}
