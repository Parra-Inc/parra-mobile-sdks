//
//  OAuth2Service+ResponseTypes.swift
//  Parra
//
//  Created by Mick MacCallum on 4/12/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import Foundation

extension OAuth2Service {
    struct TokenResponse: Codable {
        let accessToken: String
        let scope: String?
        let tokenType: String
        let expiresIn: TimeInterval
        let refreshToken: String
    }

    struct RefreshResponse: Codable {
        let accessToken: String
        let expiresIn: TimeInterval
        let scope: String
        let tokenType: String
    }
}
