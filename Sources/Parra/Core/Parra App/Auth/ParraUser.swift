//
//  ParraUser.swift
//  Parra
//
//  Created by Mick MacCallum on 4/15/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

public struct ParraUser: Equatable, Codable {
    // MARK: - Public

    public struct Info: Equatable, Codable {
        // TODO: this
    }

    // MARK: - Internal

    enum Credential: Codable, Equatable {
        case basic(String)
        case oauth2(OAuth2Service.Token)

        // MARK: - Internal

        var accessToken: String {
            switch self {
            case .basic(let token):
                return token
            case .oauth2(let token):
                return token.accessToken
            }
        }
    }

    let credential: Credential
    let info: Info
}
