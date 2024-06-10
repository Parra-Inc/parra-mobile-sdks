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

    public enum SsoType {
        case google
        case apple
        case facebook
    }

    public enum PasswordlessType {
        case sms
        case email
    }
}
