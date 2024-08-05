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
    struct Token: Codable, Equatable, Hashable, Sendable {
        public enum TokenType: Codable, Equatable, Hashable, Sendable {
            case user
            case anonymous
            case guest

            internal var isAuthenticated: Bool {
                return self == .user
            }

            internal var issuerEndpoint: IssuerEndpoint {
                switch self {
                case .anonymous:
                    return .postAnonymousAuthentication
                case .guest:
                    return .postGuestAuthentication
                case .user:
                    return .postAuthentication
                }
            }
        }


        // MARK: - Lifecycle

        init(
            authToken: AuthToken,
            type: TokenType
        ) {
            self.accessToken = authToken.accessToken
            self.tokenType = authToken.tokenType
            self.expiresAt =  if let expiresIn = authToken.expiresIn {
                Date.now.addingTimeInterval(expiresIn)
            } else {
                nil
            }
            self.refreshToken = authToken.refreshToken
            self.type = type
        }

        init(
            accessToken: String,
            tokenType: String,
            expiresAt: Date,
            refreshToken: String?,
            type: TokenType
        ) {
            self.accessToken = accessToken
            self.tokenType = tokenType
            self.expiresAt = expiresAt
            self.refreshToken = refreshToken
            self.type = type
        }

        init(
            accessToken: String,
            tokenType: String,
            expiresIn: TimeInterval,
            refreshToken: String?,
            type: TokenType
        ) {
            self.accessToken = accessToken
            self.tokenType = tokenType
            self.expiresAt = Date.now.addingTimeInterval(expiresIn)
            self.refreshToken = refreshToken
            self.type = type
        }

        // MARK: - Public

        public let accessToken: String
        public let tokenType: String
        public let expiresAt: Date?
        /// Refresh token can only be nil under anonyomus auth during the first
        /// request to get a token. Subsequent requests will send this original
        /// token in their body and will not receive a new one in their
        /// responses.
        public let refreshToken: String?
        public let type: TokenType

        public var isExpired: Bool {
            guard let expiresAt else {
                return false
            }

            return Date.now > expiresAt
        }

        public var isNearlyExpired: Bool {
            guard let expiresAt else {
                return false
            }

            return Date.now > expiresAt.addingTimeInterval(-300)
        }
    }
}
