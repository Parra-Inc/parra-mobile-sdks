//
//  ParraUser+Info.swift
//  Parra
//
//  Created by Mick MacCallum on 7/19/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import Foundation

public struct ParraUserEntitlement: Codable, Equatable, Hashable, Identifiable {
    public let id: String
    public let key: String
}

// MARK: - ParraUser.Info

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
            avatar: ParraImageAssetStub?,
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
            properties: [String: ParraAnyCodable],
            metadata: [String: ParraAnyCodable],
            settings: [String: ParraAnyCodable],
            entitlements: [ParraUserEntitlement],
            identities: [ParraIdentity],
            isAnonymous: Bool,
            hasPassword: Bool
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
            self.metadata = metadata
            self.entitlements = entitlements
            self.settings = settings
            self.identities = identities
            self.isAnonymous = isAnonymous
            self.hasPassword = hasPassword
        }

        public init(
            from decoder: any Decoder
        ) throws {
            let container: KeyedDecodingContainer<ParraUser.Info.CodingKeys> = try decoder
                .container(
                    keyedBy: ParraUser.Info.CodingKeys.self
                )
            self.id = try container
                .decode(String.self, forKey: .id)
            self.createdAt = try container
                .decode(Date.self, forKey: .createdAt)
            self.updatedAt = try container
                .decode(Date.self, forKey: .updatedAt)
            self.deletedAt = try container
                .decodeIfPresent(
                    Date.self,
                    forKey: .deletedAt
                )
            self.tenantId = try container
                .decode(String.self, forKey: .tenantId)
            self.name = try container
                .decodeIfPresent(
                    String.self,
                    forKey: .name
                )
            self.avatar = try container
                .decodeIfPresent(
                    ParraImageAssetStub.self,
                    forKey: .avatar
                )
            self.identity = try container
                .decodeIfPresent(
                    String.self,
                    forKey: .identity
                )
            self.username = try container
                .decodeIfPresent(
                    String.self,
                    forKey: .username
                )
            self.email = try container
                .decodeIfPresent(
                    String.self,
                    forKey: .email
                )
            self.emailVerified = try container
                .decodeIfPresent(
                    Bool.self,
                    forKey: .emailVerified
                )
            self.phoneNumber = try container
                .decodeIfPresent(
                    String.self,
                    forKey: .phoneNumber
                )
            self.phoneNumberVerified = try container
                .decodeIfPresent(
                    Bool.self,
                    forKey: .phoneNumberVerified
                )
            self.firstName = try container
                .decodeIfPresent(
                    String.self,
                    forKey: .firstName
                )
            self.lastName = try container
                .decodeIfPresent(
                    String.self,
                    forKey: .lastName
                )
            self.locale = try container
                .decodeIfPresent(
                    String.self,
                    forKey: .locale
                )
            self.signedUpAt = try container
                .decodeIfPresent(
                    Date.self,
                    forKey: .signedUpAt
                )
            self.lastUpdatedAt = try container
                .decodeIfPresent(
                    Date.self,
                    forKey: .lastUpdatedAt
                )
            self.lastSeenAt = try container
                .decodeIfPresent(
                    Date.self,
                    forKey: .lastSeenAt
                )
            self.lastLoginAt = try container
                .decodeIfPresent(
                    Date.self,
                    forKey: .lastLoginAt
                )
            self.properties = try container
                .decode(
                    [String: ParraAnyCodable].self,
                    forKey: .properties
                )
            self.metadata = try container
                .decode(
                    [String: ParraAnyCodable].self,
                    forKey: .properties
                )
            self.settings = try container
                .decode(
                    [String: ParraAnyCodable].self,
                    forKey: .settings
                )

            self.entitlements = try container
                .decodeIfPresent(
                    PartiallyDecodableArray<ParraUserEntitlement>.self,
                    forKey: .entitlements
                )?.elements ?? []

            self.identities = try container
                .decodeIfPresent(
                    [ParraIdentity].self,
                    forKey: .identities
                ) ?? []

            self.isAnonymous = try container
                .decode(
                    Bool.self,
                    forKey: .isAnonymous
                )

            self.hasPassword = try container
                .decodeIfPresent(
                    Bool.self,
                    forKey: .hasPassword
                ) ?? false
        }

        // MARK: - Public

        public let id: String
        public let createdAt: Date
        public let updatedAt: Date
        public let deletedAt: Date?
        public let tenantId: String
        public let name: String?
        public let avatar: ParraImageAssetStub?
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
        public internal(set) var properties: [String: ParraAnyCodable]
        public internal(set) var metadata: [String: ParraAnyCodable]
        public internal(set) var entitlements: [ParraUserEntitlement]

        public let identities: [ParraIdentity]
        public let isAnonymous: Bool

        /// Whether or not the user has an associated identity with a password.
        public let hasPassword: Bool

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
            var ids = [
                username, name, email, phoneNumber
            ].compactMap { $0 }

            if isAnonymous {
                ids.append("anonymous")
            }

            return ids
        }

        // MARK: - Internal

        // Settings must stay internal. We won't want to propagate user object
        // updates when they change and want devs to use the ParraUserSettings
        // object for managing these.
        var settings: [String: ParraAnyCodable]
    }
}
