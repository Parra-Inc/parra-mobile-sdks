//
//  Users.swift
//  Parra
//
//  Created by Michael MacCallum on 03/29/24.
//

import Foundation

public struct CreateIdentityRequestBody: Codable, Equatable, Hashable {
    // MARK: - Lifecycle

    public init(
        provider: String,
        providerUserId: String
    ) {
        self.provider = provider
        self.providerUserId = providerUserId
    }

    // MARK: - Public

    public enum CodingKeys: String, CodingKey {
        case provider
        case providerUserId
    }

    public let provider: String
    public let providerUserId: String
}

public struct IdentityResponse: Codable, Equatable, Hashable, Identifiable {
    // MARK: - Lifecycle

    public init(
        id: String,
        createdAt: String,
        updatedAt: String,
        deletedAt: String?,
        provider: String,
        providerUserId: String,
        userId: String
    ) {
        self.id = id
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.deletedAt = deletedAt
        self.provider = provider
        self.providerUserId = providerUserId
        self.userId = userId
    }

    // MARK: - Public

    public enum CodingKeys: String, CodingKey {
        case id
        case createdAt
        case updatedAt
        case deletedAt
        case provider
        case providerUserId
        case userId
    }

    public let id: String
    public let createdAt: String
    public let updatedAt: String
    public let deletedAt: String?
    public let provider: String
    public let providerUserId: String
    public let userId: String
}

public struct UpdateUserRequestBody: Codable, Equatable, Hashable {
    // MARK: - Lifecycle

    public init(
        firstName: String,
        lastName: String,
        email: String
    ) {
        self.firstName = firstName
        self.lastName = lastName
        self.email = email
    }

    // MARK: - Public

    public enum CodingKeys: String, CodingKey {
        case firstName
        case lastName
        case email
    }

    public let firstName: String
    public let lastName: String
    public let email: String
}

struct AuthChallengesRequestBody: Codable, Equatable, Hashable {
    // MARK: - Lifecycle

    init(
        email: String? = nil,
        phoneNumber: String? = nil,
        username: String? = nil,
        unknownIdentity: String? = nil
    ) {
        self.email = email
        self.phoneNumber = phoneNumber
        self.username = username
        self.unknownIdentity = unknownIdentity
    }

    init(identity: String, identityType: IdentityType?) {
        guard let identityType else {
            self.unknownIdentity = identity
            self.email = nil
            self.phoneNumber = nil
            self.username = nil

            return
        }

        switch identityType {
        case .email:
            self.email = identity
            self.phoneNumber = nil
            self.username = nil
            self.unknownIdentity = nil
        case .phone:
            self.email = nil
            self.phoneNumber = identity
            self.username = nil
            self.unknownIdentity = nil
        case .username:
            self.email = nil
            self.phoneNumber = nil
            self.username = identity
            self.unknownIdentity = nil
        }
    }

    // MARK: - Internal

    enum CodingKeys: String, CodingKey {
        case email
        case phoneNumber
        case username
        case unknownIdentity
    }

    let email: String?
    let phoneNumber: String?
    let username: String?
    let unknownIdentity: String?

    var payload: [String: String] {
        var payload: [String: String] = [:]

        if let email {
            payload["email"] = email
        }

        if let phoneNumber {
            payload["phone_number"] = phoneNumber
        }

        if let username {
            payload["username"] = username
        }

        if let unknownIdentity {
            payload["unknown_identity"] = unknownIdentity
        }

        return payload
    }
}

public enum ParraAuthChallengeType: String, Codable, Equatable, Hashable {
    case password
    case passwordlessSms = "passwordless_sms"
    case passwordlessEmail = "passwordless_email"
    case verificationSms = "verification_sms"
    case verificationEmail = "verification_email"
    case passkeys

    // MARK: - Internal

    var isPasswordless: Bool {
        switch self {
        case .passwordlessSms, .passwordlessEmail:
            return true
        default:
            return false
        }
    }

    var isVerification: Bool {
        switch self {
        case .verificationSms, .verificationEmail:
            return true
        default:
            return false
        }
    }
}

public struct ParraAuthChallenge: Codable, Equatable, Hashable {
    // MARK: - Lifecycle

    init(
        id: ParraAuthChallengeType
    ) {
        self.id = id
    }

    // MARK: - Public

    public let id: ParraAuthChallengeType

    // MARK: - Internal

    enum CodingKeys: String, CodingKey {
        case id
    }
}

struct AuthChallengeResponse: Codable, Equatable, Hashable {
    // MARK: - Lifecycle

    init(
        exists: Bool,
        challenges: [ParraAuthChallenge]
    ) {
        self.exists = exists
        self.challenges = challenges
    }

    // MARK: - Internal

    enum CodingKeys: String, CodingKey {
        case exists
        case challenges
    }

    let exists: Bool
    let challenges: [ParraAuthChallenge]
}

struct CreateUserRequestBody: Codable, Equatable, Hashable {
    // MARK: - Lifecycle

    init(
        identity: String? = nil,
        name: String? = nil,
        properties: [String: String]? = nil,
        username: String? = nil,
        email: String? = nil,
        emailVerified: Bool? = nil,
        password: String? = nil,
        phoneNumber: String? = nil,
        phoneNumberVerified: Bool? = nil,
        firstName: String? = nil,
        lastName: String? = nil,
        locale: String? = nil
    ) {
        self.identity = identity
        self.name = name
        self.password = password
        self.properties = properties
        self.username = username
        self.email = email
        self.emailVerified = emailVerified
        self.phoneNumber = phoneNumber
        self.phoneNumberVerified = phoneNumberVerified
        self.firstName = firstName
        self.lastName = lastName
        self.locale = locale
    }

    // MARK: - Internal

    let identity: String?
    let name: String?
    let properties: [String: String]?
    let username: String?
    let email: String?
    let emailVerified: Bool?
    let password: String?
    let phoneNumber: String?
    let phoneNumberVerified: Bool?
    let firstName: String?
    let lastName: String?
    let locale: String?
}

public struct UserInfoResponse: Codable, Equatable, Hashable {
    // MARK: - Lifecycle

    public init(
        roles: [String],
        user: User?
    ) {
        self.roles = roles
        self.user = user
    }

    // MARK: - Public

    public enum CodingKeys: String, CodingKey {
        case roles
        case user
    }

    public let roles: [String]
    public let user: User?
}

public struct ListUsersQuery: Codable, Equatable, Hashable {
    // MARK: - Lifecycle

    public init(
        select: String?,
        top: Int?,
        skip: Int?,
        orderBy: String?,
        filter: String?,
        expand: String?,
        search: String?
    ) {
        self.select = select
        self.top = top
        self.skip = skip
        self.orderBy = orderBy
        self.filter = filter
        self.expand = expand
        self.search = search
    }

    // MARK: - Public

    public enum CodingKeys: String, CodingKey {
        case select = "$select"
        case top = "$top"
        case skip = "$skip"
        case orderBy = "$orderBy"
        case filter = "$filter"
        case expand = "$expand"
        case search = "$search"
    }

    public let select: String?
    public let top: Int?
    public let skip: Int?
    public let orderBy: String?
    public let filter: String?
    public let expand: String?
    public let search: String?
}
