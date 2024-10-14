//
//  ParraUser+Credential.swift
//  Sample
//
//  Created by Mick MacCallum on 7/19/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import Foundation

// ! Important: Changing keys will result in user logouts when the persisted
//              info/credential objects are unable to be parsed on app launch.
public extension ParraUser {
    enum Credential: Codable, Equatable, Hashable, Sendable {
        case basic(String)
        case oauth2(Token)

        // MARK: - Public

        public var accessToken: String {
            switch self {
            case .basic(let token):
                return token
            case .oauth2(let token):
                return token.accessToken
            }
        }
    }
}
