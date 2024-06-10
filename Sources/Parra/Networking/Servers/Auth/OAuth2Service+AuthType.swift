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

        // MARK: - Internal

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
            }
        }
    }
}
