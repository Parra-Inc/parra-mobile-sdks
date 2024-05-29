//
//  AppInfo+Fixtures.swift
//  Parra
//
//  Created by Mick MacCallum on 3/19/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

extension ParraAppInfo: ParraFixture {
    static func validStates() -> [ParraAppInfo] {
        return [
            ParraAppInfo(
                versionToken: "1.0.0",
                newInstalledVersionInfo: NewInstalledVersionInfo(
                    configuration: AppReleaseConfiguration(
                        title: "My new release",
                        hasOtherReleases: false
                    ),
                    release: AppRelease.validStates()[0]
                ),
                auth: ParraAppAuthInfo(
                    database: AppInfoDatabaseConfig(
                        password: PasswordConfig(
                            iosPasswordRulesDescriptor: "required: upper, lower, digit; minlength: 8; maxlength: 128;",
                            rules: [
                                PasswordRule(
                                    regularExpression: "/^(?=.{8,128}$)/",
                                    errorMessage: "Password must be between 8 and 128 characters"
                                ),
                                PasswordRule(
                                    regularExpression: "/^(?=.*[A-Z])/",
                                    errorMessage: "Password must contain at least one uppercase letter"
                                ),
                                PasswordRule(
                                    regularExpression: "/^(?=.*[a-z])/",
                                    errorMessage: "Password must contain at least one lowercase letter"
                                ),
                                PasswordRule(
                                    regularExpression: "/^(?=.*\\\\d)/",
                                    errorMessage: "Password must contain at least one number"
                                )
                            ]
                        ),
                        username: nil,
                        email: nil,
                        phoneNumber: PhoneNumberConfig()
                    ),
                    passwordless: AuthInfoPasswordlessConfig(
                        sms: AuthInfoPasswordlessSmsConfig(
                            otpLength: 6
                        )
                    )
                ),
                legal: LegalInfo.validStates()[0]
            )
        ]
    }

    static func invalidStates() -> [ParraAppInfo] {
        return []
    }
}
