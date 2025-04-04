//
//  ParraAuthStateManager.swift
//  Parra
//
//  Created by Mick MacCallum on 4/15/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

private let logger = Logger()

@Observable
public class ParraAuthStateManager {
    // MARK: - Lifecycle

    @MainActor
    public init() {
        self.current = .undetermined
    }

    @MainActor
    init(
        current: ParraAuthState
    ) {
        self.current = current
    }

    // MARK: - Public

    @MainActor public private(set) var current: ParraAuthState

    @MainActor
    public func triggerAuthRefresh() {
        Parra.default.parraInternal.authService.performAuthStateRefresh()
    }

    // MARK: - Internal

    @MainActor static let shared = ParraAuthStateManager(
        current: .undetermined
    )

    @MainActor
    func performInitialAuthCheck(
        using authService: AuthService,
        appInfo: ParraAppInfo
    ) async throws -> AuthService.InitialAuthCheckResult {
        logger.debug("performing initial auth check")

        beginObservingAuth()

        // Obtain the auth state. This will also trigger an async refresh of any
        // user info or tokens that are necessary, which will be broadcast when
        // they are complete. The return value will be the quickest possible
        // user to obtain so that we can redraw.
        let result = try await authService.getQuickestAuthState(
            appInfo: appInfo
        )

        current = result.state

        return result
    }

    @MainActor
    func triggerAuthRefresh(
        using authService: AuthService
    ) {
        authService.performAuthStateRefresh()
    }

    // MARK: - Private

    private var authObserver: NSObjectProtocol?

    @MainActor
    private func beginObservingAuth() {
        authObserver = ParraNotificationCenter.default.addObserver(
            forName: Parra.authenticationStateDidChangeNotification,
            object: nil,
            queue: .main
        ) { [weak self] notification in
            Task { @MainActor in
                let userInfo = notification.userInfo as? [String: Any]

                self?.handleAuthChange(userInfo)
            }
        }
    }

    @MainActor
    private func handleAuthChange(_ userInfo: [String: Any]?) {
        logger.debug("Received auth state change notification")

        guard let userInfo,
              let result =
              userInfo[Parra.authenticationStateKey] as? ParraAuthState else
        {
            logger.error("Received invalid auth state change notification")

            return
        }

        Task { @MainActor in
            current = result
        }
    }
}
