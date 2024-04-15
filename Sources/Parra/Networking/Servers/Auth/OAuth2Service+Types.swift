//
//  OAuth2Service+Types.swift
//  Parra
//
//  Created by Mick MacCallum on 4/12/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import Foundation

extension OAuth2Service {
    struct PasswordCredential: Codable {
        let username: String
        let password: String
    }

    struct Token {
        let accessToken: String
        let tokenType: String
        let expiresIn: TimeInterval
        let refreshToken: String
    }
}
