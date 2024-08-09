//
//  ParraAuthState.swift
//  Parra
//
//  Created by Mick MacCallum on 4/15/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

private let logger = Logger()

@Observable
public class ParraAuthStateManager: CustomStringConvertible {
    // MARK: - Lifecycle

    internal static let `default` = ParraAuthStateManager(
        current: .undetermined
    )

    public init() {
        self.current = .undetermined
    }

    init(
        current: ParraAuthState
    ) {
        self.current = current
    }

    // MARK: - Public

    public private(set) var current: ParraAuthState

    public var description: String {
        return "ParraAuthState: \(current.description)"
    }

    // MARK: - Internal

    @MainActor
    func performInitialAuthCheck(
        using authService: AuthService,
        appInfo: ParraAppInfo
    ) async {
        logger.debug("performing initial auth check")

        beginObservingAuth()

        // Obtain the auth state. This will also trigger an async refresh of any
        // user info or tokens that are necessary, which will be broadcast when
        // they are complete. The return value will be the quickest possible
        // user to obtain so that we can redraw.
        current = await authService.getQuickestAuthState(
            appInfo: appInfo
        )
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

    private func handleAuthChange(notification: Notification) {
        logger.debug("Received auth state change notification")

        guard let userInfo = notification.userInfo,
              let result =
              userInfo[Parra.authenticationStateKey] as? ParraAuthState else
        {
            logger.error("Received invalid auth state change notification")

            return
        }

        current = result
    }
}