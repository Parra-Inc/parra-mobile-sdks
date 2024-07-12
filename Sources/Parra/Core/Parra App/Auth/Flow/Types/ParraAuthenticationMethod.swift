//
//  ParraAuthenticationMethod.swift
//  Parra
//
//  Created by Mick MacCallum on 6/10/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import Foundation

public enum ParraAuthenticationMethod: Equatable {
    case passwordless(PasswordlessType)
    case password // implies email
    case sso(SsoType)
    case passkey

    // MARK: - Public

    public enum SsoType: CustomStringConvertible {
        case google
        case apple
        case facebook

        // MARK: - Public

        public var description: String {
            switch self {
            case .google:
                return "Google"
            case .apple:
                return "Apple"
            case .facebook:
                return "Facebook"
            }
        }
    }

    public enum PasswordlessType: CustomStringConvertible {
        case sms
        case email

        // MARK: - Public

        public var description: String {
            switch self {
            case .sms:
                return "SMS"
            case .email:
                return "email"
            }
        }
    }
}
