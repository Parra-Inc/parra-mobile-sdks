//
//  ParraAppAuthInfo+ParraFixtures.swift
//  Parra
//
//  Created by Mick MacCallum on 5/29/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

extension ParraAppAuthInfo: ParraFixture {
    public static func validStates() -> [ParraAppAuthInfo] {
        return [
            ParraAppAuthInfo(
                database: ParraAppInfoDatabaseConfig(
                    password: .validStates()[0],
                    username: nil,
                    email: .init(
                        required: true,
                        requireVerification: false,
                        allowSignup: true
                    ),
                    phoneNumber: nil,
                    passkeys: ParraAppInfoPasskeysConfig(),
                    anonymousAuth: ParraAppInfoAnonymousAuthConfig()
                ),
                passwordless: ParraAuthInfoPasswordlessConfig(
                    sms: ParraAuthInfoPasswordlessSmsConfig(
                        otpLength: 6
                    )
                ),
                sso: ParraAuthSsoConfig(
                    apple: ParraAuthInfoSsoAppleConfig(
                        scopes: [.fullName, .email]
                    )
                )
            )
        ]
    }

    public static func invalidStates() -> [ParraAppAuthInfo] {
        return []
    }
}
