//
//  Parra+GeneratedTypes.swift
//  Parra Core
//
//  Created by Michael MacCallum on 12/27/21.
//

import Foundation

public typealias AnyCodable = [String: String]

public struct CreateTenantRequestBody: Codable, Equatable, Hashable {
    public let name: String
    public let isTest: Bool
    
    public init(
        name: String,
        isTest: Bool
    ) {
        self.name = name
        self.isTest = isTest
    }

    public enum CodingKeys: String, CodingKey {
        case name
        case isTest = "is_test"
    }
}

public struct Tenant: Codable, Equatable, Hashable, Identifiable {
    public let id: String
    public let createdAt: String
    public let updatedAt: String
    public let deletedAt: String?
    public let name: String
    public let isTest: Bool
    
    public init(
        id: String,
        createdAt: String,
        updatedAt: String,
        deletedAt: String?,
        name: String,
        isTest: Bool
    ) {
        self.id = id
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.deletedAt = deletedAt
        self.name = name
        self.isTest = isTest
    }

    public enum CodingKeys: String, CodingKey {
        case id
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case deletedAt = "deleted_at"
        case name
        case isTest = "is_test"
    }
}

public struct TenantCollectionResponse: Codable, Equatable, Hashable {
    public let page: Int
    public let pageCount: Int
    public let pageSize: Int
    public let totalCount: Int
    public let data: Array<Tenant>
    
    public init(
        page: Int,
        pageCount: Int,
        pageSize: Int,
        totalCount: Int,
        data: Array<Tenant>
    ) {
        self.page = page
        self.pageCount = pageCount
        self.pageSize = pageSize
        self.totalCount = totalCount
        self.data = data
    }

    public enum CodingKeys: String, CodingKey {
        case page
        case pageCount = "page_count"
        case pageSize = "page_size"
        case totalCount = "total_count"
        case data
    }
}

public struct CreateApiKeyRequestBody: Codable, Equatable, Hashable {
    public let name: String
    public let description: String?
    
    public init(
        name: String,
        description: String?
    ) {
        self.name = name
        self.description = description
    }
}

public struct ApiKey: Codable, Equatable, Hashable, Identifiable {
    public let id: String
    public let createdAt: String
    public let updatedAt: String
    public let deletedAt: String?
    public let name: String
    public let description: String?
    public let tenantId: String
    
    public init(
        id: String,
        createdAt: String,
        updatedAt: String,
        deletedAt: String?,
        name: String,
        description: String?,
        tenantId: String
    ) {
        self.id = id
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.deletedAt = deletedAt
        self.name = name
        self.description = description
        self.tenantId = tenantId
    }

    public enum CodingKeys: String, CodingKey {
        case id
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case deletedAt = "deleted_at"
        case name
        case description
        case tenantId = "tenant_id"
    }
}

public struct ApiKeyWithSecretResponse: Codable, Equatable, Hashable, Identifiable {
    public let id: String
    public let createdAt: String
    public let updatedAt: String
    public let deletedAt: String?
    public let name: String
    public let description: String?
    public let tenantId: String
    public let secret: String
    
    public init(
        id: String,
        createdAt: String,
        updatedAt: String,
        deletedAt: String?,
        name: String,
        description: String?,
        tenantId: String,
        secret: String
    ) {
        self.id = id
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.deletedAt = deletedAt
        self.name = name
        self.description = description
        self.tenantId = tenantId
        self.secret = secret
    }

    public enum CodingKeys: String, CodingKey {
        case id
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case deletedAt = "deleted_at"
        case name
        case description
        case tenantId = "tenant_id"
        case secret
    }
}

public struct ApiKeyCollectionResponse: Codable, Equatable, Hashable {
    public let page: Int
    public let pageCount: Int
    public let pageSize: Int
    public let totalCount: Int
    public let data: Array<ApiKey>
    
    public init(
        page: Int,
        pageCount: Int,
        pageSize: Int,
        totalCount: Int,
        data: Array<ApiKey>
    ) {
        self.page = page
        self.pageCount = pageCount
        self.pageSize = pageSize
        self.totalCount = totalCount
        self.data = data
    }

    public enum CodingKeys: String, CodingKey {
        case page
        case pageCount = "page_count"
        case pageSize = "page_size"
        case totalCount = "total_count"
        case data
    }
}

public struct AnswerData: Codable, Equatable, Hashable {
    
    public init(
    ) {
    }
}

public struct Answer: Codable, Equatable, Hashable, Identifiable {
    public let id: String
    public let createdAt: String
    public let updatedAt: String
    public let deletedAt: String?
    public let questionId: String
    public let userId: String
    public let tenantId: String
    public let data: AnswerData
    
    public init(
        id: String,
        createdAt: String,
        updatedAt: String,
        deletedAt: String?,
        questionId: String,
        userId: String,
        tenantId: String,
        data: AnswerData
    ) {
        self.id = id
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.deletedAt = deletedAt
        self.questionId = questionId
        self.userId = userId
        self.tenantId = tenantId
        self.data = data
    }

    public enum CodingKeys: String, CodingKey {
        case id
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case deletedAt = "deleted_at"
        case questionId = "question_id"
        case userId = "user_id"
        case tenantId = "tenant_id"
        case data
    }
}

public struct AnswerQuestionBody: Codable, Equatable, Hashable {
    public let data: AnswerData
    
    public init(
        data: AnswerData
    ) {
        self.data = data
    }
}

public enum CardItemData: Codable, Equatable, Hashable {
    case question(Question)
}

public enum CardItemType: String, Codable {
    case question = "question"
}

public struct ParraCardItem: Codable, Equatable, Hashable {
    public let type: CardItemType
    public let version: String
    public let data: CardItemData
    
    public enum CodingKeys: String, CodingKey {
        case type
        case version
        case data
    }

    public init(
        type: CardItemType,
        version: String,
        data: CardItemData
    ) {
        self.type = type
        self.version = version
        self.data = data
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.type = try container.decode(CardItemType.self, forKey: .type)
        self.version = try container.decode(String.self, forKey: .version)
        switch type {
        case .question:
            self.data = .question(try container.decode(Question.self, forKey: .data))
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(type, forKey: .type)
        try container.encode(version, forKey: .version)
        
        switch data {
        case .question(let question):
            try container.encode(question, forKey: .data)
        }
    }
    
    public var hash: Int {
        var hasher = Hasher()

        hasher.combine(id)
        hasher.combine(type)
        hasher.combine(version)
        hasher.combine(data)

        return hasher.finalize()
    }
}

public struct CardsResponse: Codable, Equatable, Hashable {
    public let items: Array<ParraCardItem>
    
    internal init(
        items: Array<ParraCardItem>
    ) {
        self.items = items
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let unfilteredItems = try container.decode([FailableDecodable<ParraCardItem>].self, forKey: .items)

        self.items = unfilteredItems.compactMap { item in
            switch item.result {
            case .success(let base):
                return base
            case .failure(let error):
                let debugError = (error as CustomDebugStringConvertible).debugDescription
                parraLogW("CardsResponse error parsing card", [NSLocalizedDescriptionKey: debugError])
                return nil
            }
        }
    }
}

public enum QuestionType: String, Codable {
    case choice = "choice"
    case rating = "rating"
}

public enum QuestionKind: String, Codable {
    case radio = "radio"
    case checkbox = "checkbox"
    case star = "star"
    case image = "image"
}

public struct CreateChoiceQuestionOption: Codable, Equatable, Hashable {
    public let title: String
    public let value: String
    public let isOther: Bool?
    
    public init(
        title: String,
        value: String,
        isOther: Bool?
    ) {
        self.title = title
        self.value = value
        self.isOther = isOther
    }

    public enum CodingKeys: String, CodingKey {
        case title
        case value
        case isOther = "is_other"
    }
}

public struct Asset: Codable, Equatable, Hashable, Identifiable {
    public let id: String
    public let url: URL
}

public struct ChoiceQuestionOption: Codable, Equatable, Hashable, Identifiable {
    public let title: String?
    public let asset: Asset?
    public let value: String
    public let isOther: Bool?
    public let id: String
    
    public init(
        title: String?,
        asset: Asset?,
        value: String,
        isOther: Bool?,
        id: String
    ) {
        self.title = title
        self.asset = asset
        self.value = value
        self.isOther = isOther
        self.id = id
    }

    public enum CodingKeys: String, CodingKey {
        case title
        case imageAssetId = "image_asset_id"
        case imageAssetUrl = "image_asset_url"
        case value
        case isOther = "is_other"
        case id
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        self.title = try container.decodeIfPresent(String.self, forKey: .title)
        self.value = try container.decode(String.self, forKey: .value)
        self.isOther = try container.decodeIfPresent(Bool.self, forKey: .isOther)
        self.id = try container.decode(String.self, forKey: .id)

        let imageId = try container.decodeIfPresent(String.self, forKey: .imageAssetId)
        let imageUrlString = try container.decodeIfPresent(String.self, forKey: .imageAssetUrl)

        if let imageId = imageId,
            let imageUrlString = imageUrlString,
            let imageUrl = URL(string: imageUrlString) {

            self.asset = Asset(id: imageId, url: imageUrl)
        } else {
            self.asset = nil
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(title, forKey: .title)
        try container.encode(value, forKey: .value)
        try container.encode(isOther, forKey: .isOther)
        try container.encode(id, forKey: .id)
        try container.encode(asset?.id, forKey: .imageAssetId)
        try container.encode(asset?.url, forKey: .imageAssetUrl)
    }
}

public struct ChoiceQuestionBody: Codable, Equatable, Hashable {
    public let options: Array<ChoiceQuestionOption>
    
    public init(
        options: Array<ChoiceQuestionOption>
    ) {
        self.options = options
    }
}

public struct CreateChoiceQuestionBody: Codable, Equatable, Hashable {
    public let options: Array<CreateChoiceQuestionOption>
    
    public init(
        options: Array<CreateChoiceQuestionOption>
    ) {
        self.options = options
    }
}

public enum CreateQuestionData: Codable, Equatable, Hashable {
    case createChoiceQuestionBody(CreateChoiceQuestionBody)
}

public enum QuestionData: Codable, Equatable, Hashable {
    case choiceQuestionBody(ChoiceQuestionBody)
}

public struct CreateQuestionRequestBody: Codable, Equatable, Hashable {
    public let title: String
    public let subtitle: String?
    public let type: QuestionType
    public let kind: QuestionKind
    public let data: CreateQuestionData
    public let active: Bool?
    public let expiresAt: String?
    public let answerQuota: Int?
    
    public init(
        title: String,
        subtitle: String?,
        type: QuestionType,
        kind: QuestionKind,
        data: CreateQuestionData,
        active: Bool?,
        expiresAt: String?,
        answerQuota: Int?
    ) {
        self.title = title
        self.subtitle = subtitle
        self.type = type
        self.kind = kind
        self.data = data
        self.active = active
        self.expiresAt = expiresAt
        self.answerQuota = answerQuota
    }

    public enum CodingKeys: String, CodingKey {
        case title
        case subtitle
        case type
        case kind
        case data
        case active
        case expiresAt = "expires_at"
        case answerQuota = "answer_quota"
    }
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.title = try container.decode(String.self, forKey: .title)
        self.subtitle = try container.decode(String.self, forKey: .subtitle)
        self.type = try container.decode(QuestionType.self, forKey: .type)
        self.kind = try container.decode(QuestionKind.self, forKey: .kind)
        self.active = try container.decode(Bool.self, forKey: .active)
        self.expiresAt = try container.decode(String.self, forKey: .expiresAt)
        self.answerQuota = try container.decode(Int.self, forKey: .answerQuota)
        switch type {
        case .choice:
            self.data = .createChoiceQuestionBody(try container.decode(CreateChoiceQuestionBody.self, forKey: .data))
        case .rating:
            fatalError()
        }
    }
}

public struct Question: Codable, Equatable, Hashable, Identifiable {
    public let id: String
    public let createdAt: String
    public let updatedAt: String
    public let deletedAt: String?
    public let tenantId: String
    public let title: String
    public let subtitle: String?
    public let type: QuestionType
    public let kind: QuestionKind
    public let data: QuestionData
    public let active: Bool?
    public let expiresAt: String?
    public let answerQuota: Int?
    public let answer: Answer?
    
    public init(
        id: String,
        createdAt: String,
        updatedAt: String,
        deletedAt: String?,
        tenantId: String,
        title: String,
        subtitle: String?,
        type: QuestionType,
        kind: QuestionKind,
        data: QuestionData,
        active: Bool?,
        expiresAt: String?,
        answerQuota: Int?,
        answer: Answer?
    ) {
        self.id = id
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.deletedAt = deletedAt
        self.tenantId = tenantId
        self.title = title
        self.subtitle = subtitle
        self.type = type
        self.kind = kind
        self.data = data
        self.active = active
        self.expiresAt = expiresAt
        self.answerQuota = answerQuota
        self.answer = answer
    }

    public enum CodingKeys: String, CodingKey {
        case id
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case deletedAt = "deleted_at"
        case tenantId = "tenant_id"
        case title
        case subtitle
        case type
        case kind
        case data
        case active
        case expiresAt = "expires_at"
        case answerQuota = "answer_quota"
        case answer
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(String.self, forKey: .id)
        self.createdAt = try container.decode(String.self, forKey: .createdAt)
        self.updatedAt = try container.decode(String.self, forKey: .updatedAt)
        self.deletedAt = try container.decodeIfPresent(String.self, forKey: .deletedAt)
        self.tenantId = try container.decode(String.self, forKey: .tenantId)
        self.title = try container.decode(String.self, forKey: .title)
        self.subtitle = try container.decodeIfPresent(String.self, forKey: .subtitle)
        self.kind = try container.decode(QuestionKind.self, forKey: .kind)
        self.active = try container.decodeIfPresent(Bool.self, forKey: .active)
        self.expiresAt = try container.decodeIfPresent(String.self, forKey: .expiresAt)
        self.answerQuota = try container.decodeIfPresent(Int.self, forKey: .answerQuota)
        self.answer = try container.decodeIfPresent(Answer.self, forKey: .answer)

        self.type = try container.decode(QuestionType.self, forKey: .type)
        switch type {
        case .choice:
            self.data = .choiceQuestionBody(try container.decode(ChoiceQuestionBody.self, forKey: .data))
        case .rating:
            fatalError()
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(id, forKey: .id)
        try container.encode(createdAt, forKey: .createdAt)
        try container.encode(updatedAt, forKey: .updatedAt)
        try container.encode(deletedAt, forKey: .deletedAt)
        try container.encode(tenantId, forKey: .tenantId)
        try container.encode(title, forKey: .title)
        try container.encode(subtitle, forKey: .subtitle)
        try container.encode(type, forKey: .type)
        try container.encode(kind, forKey: .kind)
        try container.encode(active, forKey: .active)
        try container.encode(expiresAt, forKey: .expiresAt)
        try container.encode(answerQuota, forKey: .answerQuota)
        try container.encode(answer, forKey: .answer)
        
        switch data {
        case .choiceQuestionBody(let choiceQuestionBody):
            try container.encode(choiceQuestionBody, forKey: .data)
        }
    }
}

public struct QuestionCollectionResponse: Codable, Equatable, Hashable {
    public let page: Int
    public let pageCount: Int
    public let pageSize: Int
    public let totalCount: Int
    public let data: Array<Question>
    
    public init(
        page: Int,
        pageCount: Int,
        pageSize: Int,
        totalCount: Int,
        data: Array<Question>
    ) {
        self.page = page
        self.pageCount = pageCount
        self.pageSize = pageSize
        self.totalCount = totalCount
        self.data = data
    }

    public enum CodingKeys: String, CodingKey {
        case page
        case pageCount = "page_count"
        case pageSize = "page_size"
        case totalCount = "total_count"
        case data
    }
}

public struct NotificationRecipient: Codable, Equatable, Hashable {
    public let userId: String?
    
    public init(
        userId: String?
    ) {
        self.userId = userId
    }

    public enum CodingKeys: String, CodingKey {
        case userId = "user_id"
    }
}

public struct CreateNotificationRequestBody: Codable, Equatable, Hashable {
    public let type: String?
    public let title: String
    public let subtitle: String?
    public let body: String?
    public let imageUrl: String?
    public let data: Dictionary<String, AnyCodable>?
    public let action: Dictionary<String, AnyCodable>?
    public let deduplicationId: String?
    public let groupId: String?
    public let visible: Bool?
    public let silent: Bool?
    public let contentAvailable: Bool?
    public let expiresAt: String?
    public let recipients: Array<NotificationRecipient>
    
    public init(
        type: String?,
        title: String,
        subtitle: String?,
        body: String?,
        imageUrl: String?,
        data: Dictionary<String, AnyCodable>?,
        action: Dictionary<String, AnyCodable>?,
        deduplicationId: String?,
        groupId: String?,
        visible: Bool?,
        silent: Bool?,
        contentAvailable: Bool?,
        expiresAt: String?,
        recipients: Array<NotificationRecipient>
    ) {
        self.type = type
        self.title = title
        self.subtitle = subtitle
        self.body = body
        self.imageUrl = imageUrl
        self.data = data
        self.action = action
        self.deduplicationId = deduplicationId
        self.groupId = groupId
        self.visible = visible
        self.silent = silent
        self.contentAvailable = contentAvailable
        self.expiresAt = expiresAt
        self.recipients = recipients
    }

    public enum CodingKeys: String, CodingKey {
        case type
        case title
        case subtitle
        case body
        case imageUrl = "image_url"
        case data
        case action
        case deduplicationId = "deduplication_id"
        case groupId = "group_id"
        case visible
        case silent
        case contentAvailable = "content_available"
        case expiresAt = "expires_at"
        case recipients
    }
}

public struct NotificationResponse: Codable, Equatable, Hashable, Identifiable {
    public let type: String?
    public let title: String
    public let subtitle: String?
    public let body: String?
    public let imageUrl: String?
    public let data: Dictionary<String, AnyCodable>?
    public let action: Dictionary<String, AnyCodable>?
    public let deduplicationId: String?
    public let groupId: String?
    public let visible: Bool?
    public let silent: Bool?
    public let contentAvailable: Bool?
    public let expiresAt: String?
    public let userId: String?
    public let id: String
    public let createdAt: String
    public let updatedAt: String
    public let deletedAt: String?
    public let viewedAt: String?
    public let version: String?
    
    public init(
        type: String?,
        title: String,
        subtitle: String?,
        body: String?,
        imageUrl: String?,
        data: Dictionary<String, AnyCodable>?,
        action: Dictionary<String, AnyCodable>?,
        deduplicationId: String?,
        groupId: String?,
        visible: Bool?,
        silent: Bool?,
        contentAvailable: Bool?,
        expiresAt: String?,
        userId: String?,
        id: String,
        createdAt: String,
        updatedAt: String,
        deletedAt: String?,
        viewedAt: String?,
        version: String?
    ) {
        self.type = type
        self.title = title
        self.subtitle = subtitle
        self.body = body
        self.imageUrl = imageUrl
        self.data = data
        self.action = action
        self.deduplicationId = deduplicationId
        self.groupId = groupId
        self.visible = visible
        self.silent = silent
        self.contentAvailable = contentAvailable
        self.expiresAt = expiresAt
        self.userId = userId
        self.id = id
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.deletedAt = deletedAt
        self.viewedAt = viewedAt
        self.version = version
    }

    public enum CodingKeys: String, CodingKey {
        case type
        case title
        case subtitle
        case body
        case imageUrl = "image_url"
        case data
        case action
        case deduplicationId = "deduplication_id"
        case groupId = "group_id"
        case visible
        case silent
        case contentAvailable = "content_available"
        case expiresAt = "expires_at"
        case userId = "user_id"
        case id
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case deletedAt = "deleted_at"
        case viewedAt = "viewed_at"
        case version
    }
}

public struct NotificationCollectionResponse: Codable, Equatable, Hashable {
    public let page: Int
    public let pageCount: Int
    public let pageSize: Int
    public let totalCount: Int
    public let data: Array<NotificationResponse>
    
    public init(
        page: Int,
        pageCount: Int,
        pageSize: Int,
        totalCount: Int,
        data: Array<NotificationResponse>
    ) {
        self.page = page
        self.pageCount = pageCount
        self.pageSize = pageSize
        self.totalCount = totalCount
        self.data = data
    }

    public enum CodingKeys: String, CodingKey {
        case page
        case pageCount = "page_count"
        case pageSize = "page_size"
        case totalCount = "total_count"
        case data
    }
}

public struct ReadNotificationsRequestBody: Codable, Equatable, Hashable {
    public let notificationIds: Array<String>
    
    public init(
        notificationIds: Array<String>
    ) {
        self.notificationIds = notificationIds
    }

    public enum CodingKeys: String, CodingKey {
        case notificationIds = "notification_ids"
    }
}

public struct CreatePushTokenRequestBody: Codable, Equatable, Hashable {
    public let userId: String?
    public let apnsToken: String
    
    public init(
        userId: String?,
        apnsToken: String
    ) {
        self.userId = userId
        self.apnsToken = apnsToken
    }

    public enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case apnsToken = "apns_token"
    }
}

public struct UserResponse: Codable, Equatable, Hashable, Identifiable {
    public let id: String
    public let createdAt: String
    public let updatedAt: String
    public let deletedAt: String?
    public let name: String
    public let firstName: String?
    public let lastName: String?
    public let email: String?
    public let emailVerified: Bool?
    public let avatarUrl: String?
    public let locale: String?
    public let type: String
    
    public init(
        id: String,
        createdAt: String,
        updatedAt: String,
        deletedAt: String?,
        name: String,
        firstName: String?,
        lastName: String?,
        email: String?,
        emailVerified: Bool?,
        avatarUrl: String?,
        locale: String?,
        type: String
    ) {
        self.id = id
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.deletedAt = deletedAt
        self.name = name
        self.firstName = firstName
        self.lastName = lastName
        self.email = email
        self.emailVerified = emailVerified
        self.avatarUrl = avatarUrl
        self.locale = locale
        self.type = type
    }

    public enum CodingKeys: String, CodingKey {
        case id
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case deletedAt = "deleted_at"
        case name
        case firstName = "first_name"
        case lastName = "last_name"
        case email
        case emailVerified = "email_verified"
        case avatarUrl = "avatar_url"
        case locale
        case type
    }
}

public struct CreateIdentityRequestBody: Codable, Equatable, Hashable {
    public let provider: String
    public let providerUserId: String
    
    public init(
        provider: String,
        providerUserId: String
    ) {
        self.provider = provider
        self.providerUserId = providerUserId
    }

    public enum CodingKeys: String, CodingKey {
        case provider
        case providerUserId = "provider_user_id"
    }
}

public struct IdentityResponse: Codable, Equatable, Hashable, Identifiable {
    public let id: String
    public let createdAt: String
    public let updatedAt: String
    public let deletedAt: String?
    public let provider: String
    public let providerUserId: String
    public let userId: String
    
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

    public enum CodingKeys: String, CodingKey {
        case id
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case deletedAt = "deleted_at"
        case provider
        case providerUserId = "provider_user_id"
        case userId = "user_id"
    }
}

public struct CreateUserRequestBody: Codable, Equatable, Hashable {
    public let firstName: String?
    public let lastName: String?
    public let email: String?
    public let emailVerified: Bool?
    public let avatarUrl: String?
    public let locale: String?
    public let type: String
    public let identities: Array<CreateIdentityRequestBody>?
    
    public init(
        firstName: String?,
        lastName: String?,
        email: String?,
        emailVerified: Bool?,
        avatarUrl: String?,
        locale: String?,
        type: String,
        identities: Array<CreateIdentityRequestBody>?
    ) {
        self.firstName = firstName
        self.lastName = lastName
        self.email = email
        self.emailVerified = emailVerified
        self.avatarUrl = avatarUrl
        self.locale = locale
        self.type = type
        self.identities = identities
    }

    public enum CodingKeys: String, CodingKey {
        case firstName = "first_name"
        case lastName = "last_name"
        case email
        case emailVerified = "email_verified"
        case avatarUrl = "avatar_url"
        case locale
        case type
        case identities
    }
}

public struct UpdateUserRequestBody: Codable, Equatable, Hashable {
    public let firstName: String
    public let lastName: String
    public let email: String
    
    public init(
        firstName: String,
        lastName: String,
        email: String
    ) {
        self.firstName = firstName
        self.lastName = lastName
        self.email = email
    }

    public enum CodingKeys: String, CodingKey {
        case firstName = "first_name"
        case lastName = "last_name"
        case email
    }
}

public struct UserCollectionResponse: Codable, Equatable, Hashable {
    public let page: Int
    public let pageCount: Int
    public let pageSize: Int
    public let totalCount: Int
    public let data: Array<UserResponse>
    
    public init(
        page: Int,
        pageCount: Int,
        pageSize: Int,
        totalCount: Int,
        data: Array<UserResponse>
    ) {
        self.page = page
        self.pageCount = pageCount
        self.pageSize = pageSize
        self.totalCount = totalCount
        self.data = data
    }

    public enum CodingKeys: String, CodingKey {
        case page
        case pageCount = "page_count"
        case pageSize = "page_size"
        case totalCount = "total_count"
        case data
    }
}

public struct UserInfoResponse: Codable, Equatable, Hashable {
    public let user: UserResponse?
    
    public init(
        user: UserResponse?
    ) {
        self.user = user
    }
}


public struct ListUsersQuery: Codable, Equatable, Hashable {
    public let select: String?
    public let top: Int?
    public let skip: Int?
    public let orderBy: String?
    public let filter: String?
    public let expand: String?
    public let search: String?
    
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

    public enum CodingKeys: String, CodingKey {
        case select = "$select"
        case top = "$top"
        case skip = "$skip"
        case orderBy = "$orderBy"
        case filter = "$filter"
        case expand = "$expand"
        case search = "$search"
    }
}
