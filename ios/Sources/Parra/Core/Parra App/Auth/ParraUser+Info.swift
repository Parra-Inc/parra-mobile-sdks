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
            identities: [Identity],
            isAnonymous: Bool
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
            self.isAnonymous = isAnonymous
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
        public let identities: [Identity]
        public let isAnonymous: Bool

        public init(
            from decoder: any Decoder
        ) throws {
            let container: KeyedDecodingContainer<ParraUser.Info.CodingKeys> = try decoder.container(
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
                    ImageAssetStub.self,
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
                    [String : AnyCodable].self,
                    forKey: .properties
                )
            self.identities = try container
                .decodeIfPresent(
                    [Identity].self,
                    forKey: .identities
                ) ?? []

            self.isAnonymous = try container
                .decode(
                    Bool.self,
                    forKey: .isAnonymous
                )
        }

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
    }
}
