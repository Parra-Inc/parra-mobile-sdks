//
//  UserInfoResponse+Fixtures.swift
//  Parra
//
//  Created by Mick MacCallum on 4/17/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import Foundation

extension UserInfoResponse: ParraFixture {
    static let publicFacingPreview = UserInfoResponse(
        roles: ["user"],
        user: User(
            id: .uuid,
            createdAt: .now,
            updatedAt: .now,
            deletedAt: nil,
            tenantId: .uuid,
            name: "John Appleseed",
            avatar: nil,
            identity: nil,
            username: "cool-user-92",
            email: "swiftpreview@parra.io",
            emailVerified: true,
            phoneNumber: nil,
            phoneNumberVerified: false,
            firstName: "John",
            lastName: "Appleseed",
            locale: nil,
            signedUpAt: nil,
            lastUpdatedAt: nil,
            lastSeenAt: nil,
            lastLoginAt: nil,
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
                    email: "swiftpreview@parra.io",
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

    static func validStates() -> [UserInfoResponse] {
        return [
            publicFacingPreview
        ]
    }

    static func invalidStates() -> [UserInfoResponse] {
        return []
    }
}
