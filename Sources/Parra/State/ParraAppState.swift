//
//  ParraAppState.swift
//  Parra
//
//  Created by Mick MacCallum on 2/12/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import os
import SwiftUI

private let logger = Logger()

public class ParraAppState: ObservableObject, Equatable {
    // MARK: - Lifecycle

    init(
        tenantId: String,
        applicationId: String
    ) {
        self.tenantId = tenantId
        self.applicationId = applicationId
        self.pushToken = nil
    }

    // MARK: - Public

    public private(set) var user: ParraUser?

    /// A push notification token that is being temporarily cached. Caching
    /// should only occur for short periods until the SDK is prepared to upload
    /// it. Caching it longer term can lead to invalid tokens being held onto
    /// for too long.
    public private(set) var pushToken: Data?

    public static func == (
        lhs: ParraAppState,
        rhs: ParraAppState
    ) -> Bool {
        return lhs.applicationId == rhs.applicationId
            && lhs.tenantId == rhs.tenantId
            && lhs.pushToken == rhs.pushToken
    }

    // MARK: - Internal

    private(set) var tenantId: String
    private(set) var applicationId: String

    func performInitialAuthCheck(
        using authService: AuthService
    ) async {
        let cachedCredential = await authService.loadPersistedCredential()

        do {
            //            try await authService.refreshAuthentication()

        } catch {
            printInvalidAuth(error: error)
        }
    }

    // MARK: - Private

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
}
