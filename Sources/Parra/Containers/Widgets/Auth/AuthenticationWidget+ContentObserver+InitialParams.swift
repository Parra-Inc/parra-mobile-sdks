//
//  AuthenticationWidget+ContentObserver+InitialParams.swift
//  Parra
//
//  Created by Mick MacCallum on 4/16/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import Foundation

extension AuthenticationWidget.ContentObserver {
    struct InitialParams {
        // MARK: - Lifecycle

        init(
            config: AuthenticationWidgetConfig,
            authService: AuthService,
            alertManager: AlertManager,
            methods: [ParraAuthMethod],
            initialError: Error? = nil
        ) {
            self.config = config
            self.authService = authService
            self.alertManager = alertManager
            self.methods = methods
            self.initialError = initialError
        }

        // MARK: - Internal

        let config: AuthenticationWidgetConfig
        let authService: AuthService
        let alertManager: AlertManager
        let methods: [ParraAuthMethod]
        let initialError: Error?
    }
}
