//
//  OAuth2Service+AuthType.swift
//  Parra
//
//  Created by Mick MacCallum on 4/24/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import Foundation

extension OAuth2Service {
    enum AuthType: CustomStringConvertible {
        case usernamePassword(
            username: String,
            password: String
        )

        case passwordlessEmail(code: String)
        case passwordlessSms(code: String)

        case webauthn(code: String)
        case anonymous(refreshToken: String?)
        case guest(refreshToken: String?)

        // MARK: - Internal

        var issuerEndpoint: IssuerEndpoint {
            switch self {
            case .usernamePassword, .passwordlessSms, .passwordlessEmail,
                    .webauthn:
                return .postAuthentication
            case .anonymous:
                return .postAnonymousAuthentication
            case .guest:
                return .postGuestAuthentication
            }
        }

        var tokenType: ParraUser.Credential.Token.TokenType {
            switch self {
            case .usernamePassword, .passwordlessSms, .passwordlessEmail,
                    .webauthn:
                return .user
            case .anonymous:
                return .anonymous
            case .guest:
                return .guest
            }
        }

        var description: String {
            switch self {
            case .usernamePassword:
                return "usernamePassword"
            case .passwordlessEmail:
                return "passwordlessEmail"
            case .passwordlessSms:
                return "passwordlessSms"
            case .webauthn:
                return "webauthn"
            case .anonymous:
                return "anonymous"
            case .guest:
                return "guest"
            }
        }
    }
}
