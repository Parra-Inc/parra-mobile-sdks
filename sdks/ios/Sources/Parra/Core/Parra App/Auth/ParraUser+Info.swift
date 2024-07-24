//
//  ParraUser+Info.swift
//  Parra
//
//  Created by Mick MacCallum on 7/19/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import Foundation

// ! Important: Changing keys will result in user logouts when the persisted
//              info/credential objects are unable to be parsed on app launch.
public extension ParraUser {
    struct Info: Codable, Equatable, Hashable, Identifiable {
        // MARK: - Lifecycle

        public init(
            id: String,
            createdAt: Date,
            updatedAt: Date,
            deletedAt: Date?,
            tenantId: String,
            name: String?,
            avatar: ImageAssetStub?,
            identity: String?,
            username: String?,
            email: String?,
            emailVerified: Bool?,
            phoneNumber: String?,
            phoneNumberVerified: Bool?,
            firstName: String?,
            lastName: String?,
            locale: String?,
            signedUpAt: Date?,
            lastUpdatedAt: Date?,
            lastSeenAt: Date?,
            lastLoginAt: Date?,
            properties: [String: AnyCodable],
            identities: [Identity]?
        ) {
            self.id = id
            self.createdAt = createdAt
            self.updatedAt = updatedAt
            self.deletedAt = deletedAt
            self.tenantId = tenantId
            self.name = name
            self.avatar = avatar
            self.identity = identity
            self.username = username
            self.email = email
            self.emailVerified = emailVerified
            self.phoneNumber = phoneNumber
            self.phoneNumberVerified = phoneNumberVerified
            self.firstName = firstName
            self.lastName = lastName
            self.locale = locale
            self.signedUpAt = signedUpAt
            self.lastUpdatedAt = lastUpdatedAt
            self.lastSeenAt = lastSeenAt
            self.lastLoginAt = lastLoginAt
            self.properties = properties
            self.identities = identities
        }

        // MARK: - Public

        public let id: String
        public let createdAt: Date
        public let updatedAt: Date
        public let deletedAt: Date?
        public let tenantId: String
        public let name: String?
        public let avatar: ImageAssetStub?
        public let identity: String?
        public let username: String?
        public let email: String?
        public let emailVerified: Bool?
        public let phoneNumber: String?
        public let phoneNumberVerified: Bool?
        public let firstName: String?
        public let lastName: String?
        public let locale: String?
        public let signedUpAt: Date?
        public let lastUpdatedAt: Date?
        public let lastSeenAt: Date?
        public let lastLoginAt: Date?
        public let properties: [String: AnyCodable]
        public let identities: [Identity]?

        public var displayName: String? {
            if let name {
                return name
            }

            if let firstName {
                return firstName
            }

            if let lastName {
                return lastName
            }

            return nil
        }

        public var identityNames: [String] {
            return [
                username, name, email, phoneNumber
            ].compactMap { $0 }
        }
    }
}
