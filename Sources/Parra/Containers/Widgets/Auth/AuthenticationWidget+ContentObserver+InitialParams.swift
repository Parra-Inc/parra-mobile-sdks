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
            config: ParraAuthConfig,
            content: ParraAuthContent,
            authService: AuthService,
            alertManager: AlertManager,
            legalInfo: LegalInfo
        ) {
            self.config = config
            self.content = content
            self.authService = authService
            self.alertManager = alertManager
            self.legalInfo = legalInfo
        }

        // MARK: - Internal

        let config: ParraAuthConfig
        let content: ParraAuthContent
        let authService: AuthService
        let alertManager: AlertManager
        let legalInfo: LegalInfo
    }
}
