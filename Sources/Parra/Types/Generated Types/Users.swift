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
        case .phoneNumber:
            self.email = nil
            self.phoneNumber = identity
            self.username = nil
            self.unknownIdentity = nil
        case .username:
            self.email = nil
            self.phoneNumber = nil
            self.username = identity
            self.unknownIdentity = nil
        case .uknownIdentity:
            self.email = nil
            self.phoneNumber = nil
            self.username = nil
            self.unknownIdentity = identity
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

public enum IdentityType: String, Codable {
    case email
    case phoneNumber = "phone_number"
    case username
    case uknownIdentity = "unknown_identity"
}

struct AuthChallengeResponse: Codable, Equatable, Hashable {
    // MARK: - Lifecycle

    init(
        exists: Bool,
        type: IdentityType,
        supportedChallenges: [ParraAuthChallenge],
        availableChallenges: [ParraAuthChallenge]?
    ) {
        self.exists = exists
        self.type = type
        self.supportedChallenges = supportedChallenges
        self.availableChallenges = availableChallenges
    }

    // MARK: - Internal

    enum CodingKeys: String, CodingKey {
        case exists
        case type
        case supportedChallenges
        case availableChallenges
    }

    let exists: Bool
    let type: IdentityType

    /// The types of challenges that are available per the `type` of identity,
    /// regardless of whether the user has completed them.
    let supportedChallenges: [ParraAuthChallenge]

    /// Challenges that are available for the current user. For example, a user
    /// who signed up with email/password but also has a verified phone number
    /// will have both password and passwordless SMS challenges available.
    let availableChallenges: [ParraAuthChallenge]?

    var currentChallenges: [ParraAuthChallenge] {
        if exists {
            return availableChallenges ?? []
        }

        return supportedChallenges
    }

    func hasAvailableChallenge(
        with type: ParraAuthChallengeType
    ) -> Bool {
        guard let availableChallenges else {
            return false
        }

        return availableChallenges.contains { $0.id == type }
    }
}

enum PasswordlessStrategy: String, Codable, Equatable, Hashable {
    case email
    case sms
}

enum PasswordlessChallengeStatus: String, Codable, Equatable, Hashable {
    case pending
    case completed
    case expired
}

public struct ParraPasswordlessChallengeResponse: Codable, Equatable, Hashable {
    let strategy: PasswordlessStrategy
    let status: PasswordlessChallengeStatus
    let expiresAt: Date
    let retryAt: Date?
}

struct PasswordlessChallengeRequestBody: Codable, Equatable, Hashable {
    let clientId: String
    let email: String?
    let phoneNumber: String?
}

struct CreateUserRequestBody: Codable, Equatable, Hashable {
    // MARK: - Lifecycle

    init(
        identity: String? = nil,
        type: IdentityType,
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
        self.type = type
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
    let type: IdentityType
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

struct WebAuthnAuthenticateChallengeRequest: Codable, Equatable, Hashable {
    let username: String?
}

struct WebAuthnRegisterChallengeRequest: Codable, Equatable, Hashable {
    let username: String
}

public struct AuthenticatorSelection: Codable, Equatable, Hashable {
    // MARK: - Lifecycle

    public init(
        authenticatorAttachment: String,
        requireResidentKey: Bool,
        residentKey: String,
        userVerification: String
    ) {
        self.authenticatorAttachment = authenticatorAttachment
        self.requireResidentKey = requireResidentKey
        self.residentKey = residentKey
        self.userVerification = userVerification
    }

    // MARK: - Public

    public let authenticatorAttachment: String
    public let requireResidentKey: Bool
    public let residentKey: String
    public let userVerification: String
}

public struct PublicKeyCredentialDescriptor: Codable, Equatable, Hashable,
    Identifiable
{
    // MARK: - Lifecycle

    public init(
        type: String,
        id: String,
        transports: [String]?
    ) {
        self.type = type
        self.id = id
        self.transports = transports
    }

    // MARK: - Public

    public let type: String
    public let id: String
    public let transports: [String]?
}

public struct PublicKeyCredParam: Codable, Equatable, Hashable {
    // MARK: - Lifecycle

    public init(
        type: String,
        alg: Int
    ) {
        self.type = type
        self.alg = alg
    }

    // MARK: - Public

    public let type: String
    public let alg: Int
}

public struct RelyingParty: Codable, Equatable, Hashable, Identifiable {
    // MARK: - Lifecycle

    public init(
        id: String,
        name: String?
    ) {
        self.id = id
        self.name = name
    }

    // MARK: - Public

    public let id: String
    public let name: String?
}

public struct PublicKeyCredentialUser: Codable, Equatable, Hashable,
    Identifiable
{
    // MARK: - Lifecycle

    public init(
        id: String,
        name: String,
        displayName: String
    ) {
        self.id = id
        self.name = name
        self.displayName = displayName
    }

    // MARK: - Public

    public let id: String
    public let name: String
    public let displayName: String
}

public struct PublicKeyCredentialCreationOptions: Codable, Equatable, Hashable {
    // MARK: - Lifecycle

    public init(
        attestation: String?,
        attestationFormats: [String]?,
        authenticatorSelection: AuthenticatorSelection?,
        challenge: String,
        excludeCredentials: [PublicKeyCredentialDescriptor]?,
        extensions: [String: AnyCodable]?,
        pubKeyCredParams: [PublicKeyCredParam],
        rp: RelyingParty,
        user: PublicKeyCredentialUser,
        timeout: Int?,
        hints: [String]?
    ) {
        self.attestation = attestation
        self.attestationFormats = attestationFormats
        self.authenticatorSelection = authenticatorSelection
        self.challenge = challenge
        self.excludeCredentials = excludeCredentials
        self.extensions = extensions
        self.pubKeyCredParams = pubKeyCredParams
        self.rp = rp
        self.user = user
        self.timeout = timeout
        self.hints = hints
    }

    // MARK: - Public

    public let attestation: String?
    public let attestationFormats: [String]?
    public let authenticatorSelection: AuthenticatorSelection?
    public let challenge: String
    public let excludeCredentials: [PublicKeyCredentialDescriptor]?
    public let extensions: [String: AnyCodable]?
    public let pubKeyCredParams: [PublicKeyCredParam]
    public let rp: RelyingParty
    public let user: PublicKeyCredentialUser
    public let timeout: Int?
    public let hints: [String]?
}

public struct PublicKeyCredentialRequestOptions: Codable, Equatable, Hashable {
    // MARK: - Lifecycle

    public init(
        challenge: String,
        allowCredentials: [PublicKeyCredentialDescriptor]?,
        extensions: [String: AnyCodable]?,
        rpId: String?,
        timeout: Int?,
        userVerification: String?
    ) {
        self.challenge = challenge
        self.allowCredentials = allowCredentials
        self.extensions = extensions
        self.rpId = rpId
        self.timeout = timeout
        self.userVerification = userVerification
    }

    // MARK: - Public

    public let challenge: String
    public let allowCredentials: [PublicKeyCredentialDescriptor]?
    public let extensions: [String: AnyCodable]?
    public let rpId: String?
    public let timeout: Int?
    public let userVerification: String?
}

public struct AuthenticatorResponse: Codable, Equatable, Hashable {
    // MARK: - Lifecycle

    public init(
        clientDataJSON: String
    ) {
        self.clientDataJSON = clientDataJSON
    }

    // MARK: - Public

    public let clientDataJSON: String
}

public struct AuthenticatorAttestationResponse: Codable, Equatable, Hashable {
    // MARK: - Lifecycle

    public init(
        clientDataJSON: String,
        attestationObject: String
    ) {
        self.clientDataJSON = clientDataJSON
        self.attestationObject = attestationObject
    }

    // MARK: - Public

    public let clientDataJSON: String
    public let attestationObject: String
}

public struct WebauthnRegisterRequestBody: Codable, Equatable, Hashable,
    Identifiable
{
    // MARK: - Lifecycle

    public init(
        id: String,
        rawId: String,
        response: AuthenticatorAttestationResponse,
        type: String,
        user: PublicKeyCredentialUser?
    ) {
        self.id = id
        self.rawId = rawId
        self.response = response
        self.type = type
        self.user = user
    }

    // MARK: - Public

    public let id: String
    public let rawId: String
    public let response: AuthenticatorAttestationResponse
    public let type: String
    public let user: PublicKeyCredentialUser?
}

public struct WebauthnRegisterResponseBody: Codable, Equatable, Hashable {
    // MARK: - Lifecycle

    public init(
        status: String,
        message: String,
        token: String
    ) {
        self.status = status
        self.message = message
        self.token = token
    }

    // MARK: - Public

    public let status: String
    public let message: String
    public let token: String
}

public struct AuthenticatorAssertionResponse: Codable, Equatable, Hashable {
    // MARK: - Lifecycle

    public init(
        clientDataJSON: String,
        authenticatorData: String,
        signature: String,
        userHandle: String
    ) {
        self.clientDataJSON = clientDataJSON
        self.authenticatorData = authenticatorData
        self.signature = signature
        self.userHandle = userHandle
    }

    // MARK: - Public

    public let clientDataJSON: String
    public let authenticatorData: String
    public let signature: String
    public let userHandle: String
}

public struct WebauthnAuthenticateRequestBody: Codable, Equatable, Hashable,
    Identifiable
{
    // MARK: - Lifecycle

    public init(
        id: String,
        rawId: String,
        response: AuthenticatorAssertionResponse,
        type: String,
        authenticatorAttachment: String?
    ) {
        self.id = id
        self.rawId = rawId
        self.response = response
        self.type = type
        self.authenticatorAttachment = authenticatorAttachment
    }

    // MARK: - Public

    public let id: String
    public let rawId: String
    public let response: AuthenticatorAssertionResponse
    public let type: String
    public let authenticatorAttachment: String?
}

public struct WebauthnAuthenticateResponseBody: Codable, Equatable, Hashable {
    // MARK: - Lifecycle

    public init(
        status: String,
        message: String,
        token: String
    ) {
        self.status = status
        self.message = message
        self.token = token
    }

    // MARK: - Public

    public let status: String
    public let message: String
    public let token: String
}
