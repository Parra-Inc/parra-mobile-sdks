//
//  UserInfoResponse+Fixtures.swift
//  Parra
//
//  Created by Mick MacCallum on 4/17/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import Foundation

extension UserInfoResponse: ParraFixture {
    static func validStates() -> [UserInfoResponse] {
        return [
            UserInfoResponse(
                roles: ["user"],
                user: User(
                    id: .uuid,
                    createdAt: .now,
                    updatedAt: .now,
                    deletedAt: nil,
                    tenantId: .uuid,
                    name: "Mick MacCallum",
                    avatar: nil,
                    identity: nil,
                    email: "mickm@hey.com",
                    emailVerified: true,
                    phoneNumber: nil,
                    phoneNumberVerified: false,
                    firstName: "Mick",
                    lastName: "MacCallum",
                    locale: nil,
                    signedUpAt: nil,
                    lastUpdatedAt: nil,
                    lastSeenAt: nil,
                    properties: [:],
                    identities: [
                        Identity(
                            id: .uuid,
                            createdAt: .now,
                            updatedAt: .now,
                            deletedAt: nil,
                            type: .email,
                            provider: nil,
                            providerUserId: nil,
                            email: "mickm@hey.com",
                            emailVerified: true,
                            phoneNumber: nil,
                            phoneNumberVerified: false,
                            username: nil,
                            externalId: "",
                            hasPassword: true
                        )
                    ]
                )
            )
        ]
    }

    static func invalidStates() -> [UserInfoResponse] {
        return []
    }
}
