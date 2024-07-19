//
//  ParraUser+Credential+Token.swift
//  Sample
//
//  Created by Mick MacCallum on 7/19/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import Foundation

// ! Important: Changing keys will result in user logouts when the persisted
//              info/credential objects are unable to be parsed on app launch.
public extension ParraUser.Credential {
    struct Token: Codable, Equatable, Hashable {
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

        // MARK: - Public

        public let accessToken: String
        public let tokenType: String
        public let expiresAt: Date
        public let refreshToken: String

        public var isExpired: Bool {
            Date.now > expiresAt
        }

        public var isNearlyExpired: Bool {
            Date.now > expiresAt.addingTimeInterval(-300)
        }
    }
}
