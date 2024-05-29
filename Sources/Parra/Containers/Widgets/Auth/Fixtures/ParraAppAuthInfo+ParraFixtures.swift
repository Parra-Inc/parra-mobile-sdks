//
//  ParraAppAuthInfo+ParraFixtures.swift
//  Parra
//
//  Created by Mick MacCallum on 5/29/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

extension ParraAppAuthInfo: ParraFixture {
    static func validStates() -> [ParraAppAuthInfo] {
        return [
            ParraAppAuthInfo(
                database: AppInfoDatabaseConfig(
                    password: .validStates()[0],
                    username: nil,
                    email: nil,
                    phoneNumber: PhoneNumberConfig()
                ),
                passwordless: AuthInfoPasswordlessConfig(
                    sms: AuthInfoPasswordlessSmsConfig(
                        otpLength: 6
                    )
                )
            )
        ]
    }

    static func invalidStates() -> [ParraAppAuthInfo] {
        return []
    }
}
