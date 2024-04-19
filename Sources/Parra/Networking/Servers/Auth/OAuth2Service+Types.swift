//
//  OAuth2Service+Types.swift
//  Parra
//
//  Created by Mick MacCallum on 4/12/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import Foundation

extension OAuth2Service {
    struct PasswordCredential: Codable, Equatable {
        let username: String
        let password: String
    }

    struct Token: Codable, Equatable {
        // MARK: - Lifecycle

        init(
            accessToken: String,
            tokenType: String,
            expiresAt: Date,
            refreshToken: String
        ) {
            self.accessToken = accessToken
            self.tokenType = tokenType
            self.expiresAt = expiresAt
            self.refreshToken = refreshToken
        }

        init(
            accessToken: String,
            tokenType: String,
            expiresIn: TimeInterval,
            refreshToken: String
        ) {
            self.accessToken = accessToken
            self.tokenType = tokenType
            self.expiresAt = Date.now.addingTimeInterval(expiresIn)
            self.refreshToken = refreshToken
        }

        // MARK: - Internal

        let accessToken: String
        let tokenType: String
        let expiresAt: Date
        let refreshToken: String

        var isExpired: Bool {
            Date.now > expiresAt
        }

        var isNearlyExpired: Bool {
            Date.now > expiresAt.addingTimeInterval(-300)
        }
    }
}
