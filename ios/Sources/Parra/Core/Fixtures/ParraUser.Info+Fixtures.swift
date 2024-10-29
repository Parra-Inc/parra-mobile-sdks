//
//  ParraUser.Info+Fixtures.swift
//  Sample
//
//  Created by Mick MacCallum on 7/19/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

extension ParraUser.Info: ParraFixture {
    static let publicFacingPreview = ParraUser.Info(
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
        metadata: [:],
        settings: [:],
        identities: [
            ParraIdentity(
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
        ],
        isAnonymous: false,
        hasPassword: true
    )

    public static func validStates() -> [ParraUser.Info] {
        return [publicFacingPreview]
    }

    public static func invalidStates() -> [ParraUser.Info] {
        return []
    }
}
