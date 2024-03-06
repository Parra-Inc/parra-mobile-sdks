//
//  GeneratedTypes.swift
//  Parra
//
//  Created by Michael MacCallum on 12/27/21.
//

import Foundation

public struct CreateTenantRequestBody: Codable, Equatable, Hashable {
    // MARK: - Lifecycle

    public init(
        name: String,
        isTest: Bool
    ) {
        self.name = name
        self.isTest = isTest
    }

    // MARK: - Public

    public enum CodingKeys: String, CodingKey {
        case name
        case isTest
    }

    public let name: String
    public let isTest: Bool
}

public struct Tenant: Codable, Equatable, Hashable, Identifiable {
    // MARK: - Lifecycle

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

    // MARK: - Public

    public enum CodingKeys: String, CodingKey {
        case id
        case createdAt
        case updatedAt
        case deletedAt
        case name
        case isTest
    }

    public let id: String
    public let createdAt: String
    public let updatedAt: String
    public let deletedAt: String?
    public let name: String
    public let isTest: Bool
}

public struct TenantCollectionResponse: Codable, Equatable, Hashable {
    // MARK: - Lifecycle

    public init(
        page: Int,
        pageCount: Int,
        pageSize: Int,
        totalCount: Int,
        data: [Tenant]
    ) {
        self.page = page
        self.pageCount = pageCount
        self.pageSize = pageSize
        self.totalCount = totalCount
        self.data = data
    }

    // MARK: - Public

    public enum CodingKeys: String, CodingKey {
        case page
        case pageCount
        case pageSize
        case totalCount
        case data
    }

    public let page: Int
    public let pageCount: Int
    public let pageSize: Int
    public let totalCount: Int
    public let data: [Tenant]
}

public struct CreateApiKeyRequestBody: Codable, Equatable, Hashable {
    // MARK: - Lifecycle

    public init(
        name: String,
        description: String?
    ) {
        self.name = name
        self.description = description
    }

    // MARK: - Public

    public let name: String
    public let description: String?
}

public struct ApiKey: Codable, Equatable, Hashable, Identifiable {
    // MARK: - Lifecycle

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

    // MARK: - Public

    public enum CodingKeys: String, CodingKey {
        case id
        case createdAt
        case updatedAt
        case deletedAt
        case name
        case description
        case tenantId
    }

    public let id: String
    public let createdAt: String
    public let updatedAt: String
    public let deletedAt: String?
    public let name: String
    public let description: String?
    public let tenantId: String
}

public struct ApiKeyWithSecretResponse: Codable, Equatable, Hashable,
    Identifiable
{
    // MARK: - Lifecycle

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

    // MARK: - Public

    public enum CodingKeys: String, CodingKey {
        case id
        case createdAt
        case updatedAt
        case deletedAt
        case name
        case description
        case tenantId
        case secret
    }

    public let id: String
    public let createdAt: String
    public let updatedAt: String
    public let deletedAt: String?
    public let name: String
    public let description: String?
    public let tenantId: String
    public let secret: String
}

public struct ApiKeyCollectionResponse: Codable, Equatable, Hashable {
    // MARK: - Lifecycle

    public init(
        page: Int,
        pageCount: Int,
        pageSize: Int,
        totalCount: Int,
        data: [ApiKey]
    ) {
        self.page = page
        self.pageCount = pageCount
        self.pageSize = pageSize
        self.totalCount = totalCount
        self.data = data
    }

    // MARK: - Public

    public enum CodingKeys: String, CodingKey {
        case page
        case pageCount
        case pageSize
        case totalCount
        case data
    }

    public let page: Int
    public let pageCount: Int
    public let pageSize: Int
    public let totalCount: Int
    public let data: [ApiKey]
}

public struct FeedbackFormResponse: Codable, Equatable, Hashable, Identifiable {
    // MARK: - Lifecycle

    public init(
        id: String,
        createdAt: String,
        updatedAt: String,
        deletedAt: String?,
        title: String,
        description: String?,
        data: FeedbackFormData
    ) {
        self.id = id
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.deletedAt = deletedAt
        self.title = title
        self.description = description
        self.data = data
    }

    // MARK: - Public

    public enum CodingKeys: String, CodingKey {
        case id
        case createdAt
        case updatedAt
        case deletedAt
        case title
        case description
        case data
    }

    public let id: String
    public let createdAt: String
    public let updatedAt: String
    public let deletedAt: String?
    public let title: String
    public let description: String?
    public let data: FeedbackFormData
}

/// User facing
public struct ParraFeedbackForm: Codable, Equatable, Identifiable {
    // MARK: - Lifecycle

    init(from response: ParraFeedbackFormResponse) {
        self.id = response.id
        self.data = response.data
    }

    init(from stub: FeedbackFormDataStub) {
        self.id = stub.id
        self.data = stub.data
    }

    // MARK: - Public

    public let id: String
    public let data: FeedbackFormData
}

struct ParraFeedbackFormResponse: Codable, Equatable, Hashable,
    Identifiable
{
    // MARK: - Lifecycle

    init(
        id: String,
        createdAt: String,
        updatedAt: String,
        deletedAt: String?,
        data: FeedbackFormData
    ) {
        self.id = id
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.deletedAt = deletedAt
        self.data = data
    }

    // MARK: - Internal

    enum CodingKeys: String, CodingKey {
        case id
        case createdAt
        case updatedAt
        case deletedAt
        case data
    }

    let id: String
    let createdAt: String
    let updatedAt: String
    let deletedAt: String?
    let data: FeedbackFormData
}

public struct FeedbackFormData: Codable, Equatable, Hashable {
    // MARK: - Lifecycle

    init(
        title: String,
        description: String?,
        fields: [FeedbackFormField]
    ) {
        self.title = title
        self.description = description
        self.fields = fields
    }

    // MARK: - Public

    public let title: String
    public let description: String?
    public let fields: [FeedbackFormField]
}

public struct FeedbackFormDataStub: Codable, Equatable, Hashable, Identifiable {
    // MARK: - Lifecycle

    public init(
        id: String,
        createdAt: String,
        updatedAt: String,
        deletedAt: String?,
        data: FeedbackFormData
    ) {
        self.id = id
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.deletedAt = deletedAt
        self.data = data
    }

    // MARK: - Public

    public enum CodingKeys: String, CodingKey {
        case id
        case createdAt
        case updatedAt
        case deletedAt
        case data
    }

    public let id: String
    public let createdAt: String
    public let updatedAt: String
    public let deletedAt: String?
    public let data: FeedbackFormData
}

public enum FeedbackFormFieldType: String, Codable {
    case input
    case text
    case select
}

public struct FeedbackFormField: Codable, Equatable, Hashable, Identifiable {
    // MARK: - Lifecycle

    public init(
        name: String,
        title: String?,
        helperText: String?,
        type: FeedbackFormFieldType,
        required: Bool?,
        data: FeedbackFormFieldData
    ) {
        self.name = name
        self.title = title
        self.helperText = helperText
        self.type = type
        self.required = required
        self.data = data
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.name = try container.decode(String.self, forKey: .name)
        self.title = try container.decode(String.self, forKey: .title)
        self.helperText = try container.decodeIfPresent(
            String.self,
            forKey: .helperText
        )
        self.type = try container.decode(
            FeedbackFormFieldType.self,
            forKey: .type
        )
        self.required = try container.decode(Bool.self, forKey: .required)
        switch type {
        case .input:
            self.data = try .feedbackFormInputFieldData(
                container.decode(
                    FeedbackFormInputFieldData.self,
                    forKey: .data
                )
            )
        case .text:
            self.data = try .feedbackFormTextFieldData(
                container.decode(FeedbackFormTextFieldData.self, forKey: .data)
            )
        case .select:
            self.data = try .feedbackFormSelectFieldData(
                container.decode(
                    FeedbackFormSelectFieldData.self,
                    forKey: .data
                )
            )
        }
    }

    // MARK: - Public

    public enum CodingKeys: String, CodingKey {
        case name
        case title
        case helperText
        case type
        case required
        case data
    }

    public let name: String
    public let title: String?
    public let helperText: String?
    public let type: FeedbackFormFieldType
    public let required: Bool?
    public let data: FeedbackFormFieldData

    public var id: String {
        return name
    }
}

public enum FeedbackFormFieldData: Codable, Equatable, Hashable {
    case feedbackFormTextFieldData(FeedbackFormTextFieldData)
    case feedbackFormSelectFieldData(FeedbackFormSelectFieldData)
    case feedbackFormInputFieldData(FeedbackFormInputFieldData)
}

public protocol FeedbackFormFieldDataType {}

public struct FeedbackFormInputFieldData: Codable, Equatable, Hashable,
    FeedbackFormFieldDataType
{
    // MARK: - Lifecycle

    public init(
        placeholder: String
    ) {
        self.placeholder = placeholder
    }

    // MARK: - Public

    public let placeholder: String
}

public struct FeedbackFormTextFieldData: Codable, Equatable, Hashable,
    FeedbackFormFieldDataType
{
    // MARK: - Lifecycle

    public init(
        placeholder: String?,
        lines: Int?,
        minCharacters: Int?,
        maxCharacters: Int?,
        maxHeight: Int?
    ) {
        self.placeholder = placeholder
        self.lines = lines
        self.minCharacters = minCharacters
        self.maxCharacters = maxCharacters
        self.maxHeight = maxHeight
    }

    // MARK: - Public

    public enum CodingKeys: String, CodingKey {
        case placeholder
        case lines
        case minCharacters
        case maxCharacters
        case maxHeight
    }

    public let placeholder: String?
    public let lines: Int?
    public let minCharacters: Int?
    public let maxCharacters: Int?
    public let maxHeight: Int?
}

public struct FeedbackFormSelectFieldData: Codable, Equatable, Hashable,
    FeedbackFormFieldDataType
{
    // MARK: - Lifecycle

    public init(
        placeholder: String?,
        options: [FeedbackFormSelectFieldOption]
    ) {
        self.placeholder = placeholder
        self.options = options
    }

    // MARK: - Public

    /// If provided, the title for an empty option.
    public let placeholder: String?
    public let options: [FeedbackFormSelectFieldOption]
}

public struct FeedbackFormSelectFieldOption: Codable, Equatable, Hashable,
    Identifiable
{
    // MARK: - Lifecycle

    public init(
        title: String,
        value: String,
        isOther: Bool?
    ) {
        self.title = title
        self.value = value
        self.isOther = isOther
    }

    // MARK: - Public

    public enum CodingKeys: String, CodingKey {
        case title
        case value
        case isOther
    }

    public let title: String
    public let value: String
    public let isOther: Bool?

    public var id: String {
        value
    }
}

public struct FeedbackFormStub: Codable, Equatable, Hashable, Identifiable {
    // MARK: - Lifecycle

    public init(
        id: String,
        createdAt: String,
        updatedAt: String,
        deletedAt: String?,
        title: String,
        description: String?
    ) {
        self.id = id
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.deletedAt = deletedAt
        self.title = title
        self.description = description
    }

    // MARK: - Public

    public enum CodingKeys: String, CodingKey {
        case id
        case createdAt
        case updatedAt
        case deletedAt
        case title
        case description
    }

    public let id: String
    public let createdAt: String
    public let updatedAt: String
    public let deletedAt: String?
    public let title: String
    public let description: String?
}

public struct FeedbackFormCollectionResponse: Codable, Equatable, Hashable {
    // MARK: - Lifecycle

    public init(
        page: Int,
        pageCount: Int,
        pageSize: Int,
        totalCount: Int,
        data: [FeedbackFormStub]
    ) {
        self.page = page
        self.pageCount = pageCount
        self.pageSize = pageSize
        self.totalCount = totalCount
        self.data = data
    }

    // MARK: - Public

    public enum CodingKeys: String, CodingKey {
        case page
        case pageCount
        case pageSize
        case totalCount
        case data
    }

    public let page: Int
    public let pageCount: Int
    public let pageSize: Int
    public let totalCount: Int
    public let data: [FeedbackFormStub]
}

public struct FeedbackMetrics: Codable, Equatable, Hashable {
    // MARK: - Lifecycle

    public init(
        userCount: Int,
        answerCount: Int,
        questionCount: Int,
        questionsCreatedThisMonth: Int
    ) {
        self.userCount = userCount
        self.answerCount = answerCount
        self.questionCount = questionCount
        self.questionsCreatedThisMonth = questionsCreatedThisMonth
    }

    // MARK: - Public

    public enum CodingKeys: String, CodingKey {
        case userCount
        case answerCount
        case questionCount
        case questionsCreatedThisMonth
    }

    public let userCount: Int
    public let answerCount: Int
    public let questionCount: Int
    public let questionsCreatedThisMonth: Int
}

public struct AnswerData: Codable, Equatable, Hashable {
    public init(
    ) {}
}

public struct Answer: Codable, Equatable, Hashable, Identifiable {
    // MARK: - Lifecycle

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

    // MARK: - Public

    public enum CodingKeys: String, CodingKey {
        case id
        case createdAt
        case updatedAt
        case deletedAt
        case questionId
        case userId
        case tenantId
        case data
    }

    public let id: String
    public let createdAt: String
    public let updatedAt: String
    public let deletedAt: String?
    public let questionId: String
    public let userId: String
    public let tenantId: String
    public let data: AnswerData
}

public struct AnswerQuestionBody: Codable, Equatable, Hashable {
    // MARK: - Lifecycle

    public init(
        data: AnswerData
    ) {
        self.data = data
    }

    // MARK: - Public

    public let data: AnswerData
}

public enum CardItemData: Codable, Equatable, Hashable {
    case question(Question)
}

public enum CardItemDisplayType: String, Codable {
    case inline
    case popup
    case drawer
}

public enum CardItemType: String, Codable {
    case question
}

public struct ParraCardItem: Codable, Equatable, Hashable {
    // MARK: - Lifecycle

    public init(
        id: String,
        campaignId: String,
        campaignActionId: String,
        questionId: String?,
        type: CardItemType,
        displayType: CardItemDisplayType?,
        version: String,
        data: CardItemData
    ) {
        self.id = id
        self.campaignId = campaignId
        self.campaignActionId = campaignActionId
        self.questionId = questionId
        self.type = type
        self.displayType = displayType
        self.version = version
        self.data = data
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(String.self, forKey: .id)
        self.campaignId = try container.decode(String.self, forKey: .campaignId)
        self.campaignActionId = try container.decode(
            String.self,
            forKey: .campaignActionId
        )
        self.questionId = try container.decode(String.self, forKey: .questionId)
        self.type = try container.decode(CardItemType.self, forKey: .type)
        self.displayType = try container.decode(
            CardItemDisplayType.self,
            forKey: .displayType
        )
        self.version = try container.decode(String.self, forKey: .version)
        switch type {
        case .question:
            self.data = try .question(container.decode(
                Question.self,
                forKey: .data
            ))
        }
    }

    // MARK: - Public

    public enum CodingKeys: String, CodingKey {
        case id
        case campaignId
        case campaignActionId
        case questionId
        case type
        case displayType
        case version
        case data
    }

    public let id: String
    public let campaignId: String
    public let campaignActionId: String
    public let questionId: String?
    public let type: CardItemType
    public let displayType: CardItemDisplayType?
    public let version: String
    public let data: CardItemData

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(id, forKey: .id)
        try container.encode(campaignId, forKey: .campaignId)
        try container.encode(campaignActionId, forKey: .campaignActionId)
        try container.encodeIfPresent(questionId, forKey: .questionId)
        try container.encode(type, forKey: .type)
        try container.encode(displayType, forKey: .displayType)
        try container.encode(version, forKey: .version)

        switch data {
        case .question(let question):
            try container.encode(question, forKey: .data)
        }
    }
}

public struct CardsResponse: Codable, Equatable, Hashable {
    // MARK: - Lifecycle

    init(
        items: [ParraCardItem]
    ) {
        self.items = items
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let unfilteredItems = try container.decode(
            [FailableDecodable<ParraCardItem>].self,
            forKey: .items
        )

        self.items = unfilteredItems.compactMap { item in
            switch item.result {
            case .success(let base):
                return base
            case .failure(let error):
                let debugError = (error as CustomDebugStringConvertible)
                    .debugDescription
                Logger.warn(
                    "CardsResponse error parsing card",
                    [NSLocalizedDescriptionKey: debugError]
                )
                return nil
            }
        }
    }

    // MARK: - Public

    public let items: [ParraCardItem]
}

public enum QuestionKind: String, Codable, Equatable {
    case radio
    case checkbox
    case rating
    case star
    case boolean
    case image
    case textShort = "short-text"
    case textLong = "long-text"
}

public struct Asset: Codable, Equatable, Hashable, Identifiable {
    public let id: String
    public let url: URL
}

public struct CheckboxQuestionOption: Codable, Equatable, Hashable,
    Identifiable
{
    // MARK: - Lifecycle

    public init(
        title: String,
        value: String,
        isOther: Bool?,
        id: String
    ) {
        self.title = title
        self.value = value
        self.isOther = isOther
        self.id = id
    }

    // MARK: - Public

    public enum CodingKeys: String, CodingKey {
        case title
        case value
        case isOther
        case id
    }

    public let title: String
    public let value: String
    public let isOther: Bool?
    public let id: String
}

public struct CheckboxQuestionBody: Codable, Equatable, Hashable {
    // MARK: - Lifecycle

    public init(
        options: [CheckboxQuestionOption]
    ) {
        self.options = options
    }

    // MARK: - Public

    public let options: [CheckboxQuestionOption]
}

public struct ImageQuestionOption: Codable, Equatable, Hashable, Identifiable {
    // MARK: - Lifecycle

    public init(
        title: String?,
        value: String,
        id: String,
        asset: Asset
    ) {
        self.title = title
        self.value = value
        self.id = id
        self.asset = asset
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        self.title = try container.decodeIfPresent(String.self, forKey: .title)
        self.value = try container.decode(String.self, forKey: .value)
        self.id = try container.decode(String.self, forKey: .id)

        let imageId = try container.decodeIfPresent(
            String.self,
            forKey: .imageAssetId
        )
        let imageUrlString = try container.decodeIfPresent(
            String.self,
            forKey: .imageAssetUrl
        )

        if let imageId,
           let imageUrlString,
           let imageUrl = URL(string: imageUrlString)
        {
            self.asset = Asset(id: imageId, url: imageUrl)
        } else {
            throw ParraError
                .jsonError("Failed to decode asset for image question option")
        }
    }

    // MARK: - Public

    public enum CodingKeys: String, CodingKey {
        case imageAssetId
        case title
        case value
        case id
        case imageAssetUrl
    }

    public let title: String?
    public let value: String
    public let id: String
    public let asset: Asset

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(title, forKey: .title)
        try container.encode(value, forKey: .value)
        try container.encode(id, forKey: .id)
        try container.encode(asset.id, forKey: .imageAssetId)
        try container.encode(asset.url, forKey: .imageAssetUrl)
    }
}

public struct ImageQuestionBody: Codable, Equatable, Hashable {
    // MARK: - Lifecycle

    public init(
        options: [ImageQuestionOption]
    ) {
        self.options = options
    }

    // MARK: - Public

    public let options: [ImageQuestionOption]
}

public struct ChoiceQuestionOption: Codable, Equatable, Hashable, Identifiable {
    // MARK: - Lifecycle

    public init(
        title: String,
        value: String,
        isOther: Bool?,
        id: String
    ) {
        self.title = title
        self.value = value
        self.isOther = isOther
        self.id = id
    }

    // MARK: - Public

    public enum CodingKeys: String, CodingKey {
        case title
        case value
        case isOther
        case id
    }

    public let title: String
    public let value: String
    public let isOther: Bool?
    public let id: String
}

public struct ChoiceQuestionBody: Codable, Equatable, Hashable {
    // MARK: - Lifecycle

    public init(
        options: [ChoiceQuestionOption]
    ) {
        self.options = options
    }

    // MARK: - Public

    public let options: [ChoiceQuestionOption]
}

public struct ShortTextQuestionBody: Codable, Equatable, Hashable {
    // MARK: - Lifecycle

    public init(
        placeholder: String?,
        minLength: Int = 1,
        maxLength: Int = Int.max
    ) {
        self.placeholder = placeholder
        self.minLength = minLength
        self.maxLength = maxLength
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        self.placeholder = try container.decodeIfPresent(
            String.self,
            forKey: .placeholder
        )
        self.minLength = try container.decodeIfPresent(
            Int.self,
            forKey: .minLength
        ) ?? 1
        self.maxLength = try container.decodeIfPresent(
            Int.self,
            forKey: .maxLength
        ) ?? Int.max
    }

    // MARK: - Public

    public enum CodingKeys: String, CodingKey {
        case placeholder
        case minLength
        case maxLength
    }

    public let placeholder: String?
    public let minLength: Int
    public let maxLength: Int
}

public struct LongTextQuestionBody: Codable, Equatable, Hashable {
    // MARK: - Lifecycle

    public init(
        placeholder: String?,
        minLength: Int = 1,
        maxLength: Int = .max
    ) {
        self.placeholder = placeholder
        self.minLength = minLength
        self.maxLength = maxLength
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        self.placeholder = try container.decodeIfPresent(
            String.self,
            forKey: .placeholder
        )
        self.minLength = try container.decodeIfPresent(
            Int.self,
            forKey: .minLength
        ) ?? 1
        self.maxLength = try container.decodeIfPresent(
            Int.self,
            forKey: .maxLength
        ) ?? .max
    }

    // MARK: - Public

    public enum CodingKeys: String, CodingKey {
        case placeholder
        case minLength
        case maxLength
    }

    public let placeholder: String?
    public let minLength: Int
    public let maxLength: Int
}

public struct BooleanQuestionOption: Codable, Equatable, Hashable,
    Identifiable
{
    // MARK: - Lifecycle

    public init(
        title: String,
        value: String,
        id: String
    ) {
        self.title = title
        self.value = value
        self.id = id
    }

    // MARK: - Public

    public let title: String
    public let value: String
    public let id: String
}

public struct BooleanQuestionBody: Codable, Equatable, Hashable {
    // MARK: - Lifecycle

    public init(
        options: [BooleanQuestionOption]
    ) {
        self.options = options
    }

    // MARK: - Public

    public let options: [BooleanQuestionOption]
}

public struct StarQuestionBody: Codable, Equatable, Hashable {
    // MARK: - Lifecycle

    public init(
        starCount: Int,
        leadingLabel: String?,
        centerLabel: String?,
        trailingLabel: String?
    ) {
        self.starCount = starCount
        self.leadingLabel = leadingLabel
        self.centerLabel = centerLabel
        self.trailingLabel = trailingLabel
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        self.starCount = try container.decode(Int.self, forKey: .starCount)
        self.leadingLabel = try container.decodeIfPresent(
            String.self,
            forKey: .leadingLabel
        )
        self.centerLabel = try container.decodeIfPresent(
            String.self,
            forKey: .centerLabel
        )
        self.trailingLabel = try container.decodeIfPresent(
            String.self,
            forKey: .trailingLabel
        )
    }

    // MARK: - Public

    public let starCount: Int
    public let leadingLabel: String?
    public let centerLabel: String?
    public let trailingLabel: String?
}

public struct RatingQuestionOption: Codable, Equatable, Hashable, Identifiable {
    // MARK: - Lifecycle

    public init(
        title: String,
        value: Int,
        id: String
    ) {
        self.title = title
        self.value = value
        self.id = id
    }

    // MARK: - Public

    public let title: String
    public let value: Int
    public let id: String
}

public struct RatingQuestionBody: Codable, Equatable, Hashable {
    // MARK: - Lifecycle

    public init(
        options: [RatingQuestionOption],
        leadingLabel: String?,
        centerLabel: String?,
        trailingLabel: String?
    ) {
        self.options = options
        self.leadingLabel = leadingLabel
        self.centerLabel = centerLabel
        self.trailingLabel = trailingLabel
    }

    // MARK: - Public

    public enum CodingKeys: String, CodingKey {
        case options
        case leadingLabel
        case centerLabel
        case trailingLabel
    }

    public let options: [RatingQuestionOption]
    public let leadingLabel: String?
    public let centerLabel: String?
    public let trailingLabel: String?
}

public enum QuestionData: Codable, Equatable, Hashable {
    case choiceQuestionBody(ChoiceQuestionBody)
    case checkboxQuestionBody(CheckboxQuestionBody)
    case imageQuestionBody(ImageQuestionBody)
    case ratingQuestionBody(RatingQuestionBody)
    case starQuestionBody(StarQuestionBody)
    case shortTextQuestionBody(ShortTextQuestionBody)
    case longTextQuestionBody(LongTextQuestionBody)
    case booleanQuestionBody(BooleanQuestionBody)
}

public struct Question: Codable, Equatable, Hashable, Identifiable {
    // MARK: - Lifecycle

    public init(
        id: String,
        createdAt: String,
        updatedAt: String,
        deletedAt: String?,
        tenantId: String,
        title: String,
        subtitle: String?,
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
        self.kind = kind
        self.data = data
        self.active = active
        self.expiresAt = expiresAt
        self.answerQuota = answerQuota
        self.answer = answer
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(String.self, forKey: .id)
        self.createdAt = try container.decode(String.self, forKey: .createdAt)
        self.updatedAt = try container.decode(String.self, forKey: .updatedAt)
        self.deletedAt = try container.decodeIfPresent(
            String.self,
            forKey: .deletedAt
        )
        self.tenantId = try container.decode(String.self, forKey: .tenantId)
        self.title = try container.decode(String.self, forKey: .title)
        self.subtitle = try container.decodeIfPresent(
            String.self,
            forKey: .subtitle
        )
        self.active = try container.decodeIfPresent(Bool.self, forKey: .active)
        self.expiresAt = try container.decodeIfPresent(
            String.self,
            forKey: .expiresAt
        )
        self.answerQuota = try container.decodeIfPresent(
            Int.self,
            forKey: .answerQuota
        )
        self.answer = try container.decodeIfPresent(
            Answer.self,
            forKey: .answer
        )
        self.kind = try container.decode(QuestionKind.self, forKey: .kind)

        switch kind {
        case .checkbox:
            self.data = try .checkboxQuestionBody(container.decode(
                CheckboxQuestionBody.self,
                forKey: .data
            ))
        case .image:
            self.data = try .imageQuestionBody(container.decode(
                ImageQuestionBody.self,
                forKey: .data
            ))
        case .radio:
            self.data = try .choiceQuestionBody(container.decode(
                ChoiceQuestionBody.self,
                forKey: .data
            ))
        case .star:
            self.data = try .starQuestionBody(container.decode(
                StarQuestionBody.self,
                forKey: .data
            ))
        case .rating:
            self.data = try .ratingQuestionBody(container.decode(
                RatingQuestionBody.self,
                forKey: .data
            ))
        case .textShort:
            self.data = try .shortTextQuestionBody(container.decode(
                ShortTextQuestionBody.self,
                forKey: .data
            ))
        case .textLong:
            self.data = try .longTextQuestionBody(container.decode(
                LongTextQuestionBody.self,
                forKey: .data
            ))
        case .boolean:
            self.data = try .booleanQuestionBody(container.decode(
                BooleanQuestionBody.self,
                forKey: .data
            ))
        }
    }

    // MARK: - Public

    public enum CodingKeys: String, CodingKey {
        case id
        case createdAt
        case updatedAt
        case deletedAt
        case tenantId
        case title
        case subtitle
        case type
        case kind
        case data
        case active
        case expiresAt
        case answerQuota
        case answer
    }

    public let id: String
    public let createdAt: String
    public let updatedAt: String
    public let deletedAt: String?
    public let tenantId: String
    public let title: String
    public let subtitle: String?
    public let kind: QuestionKind
    public let data: QuestionData
    public let active: Bool?
    public let expiresAt: String?
    public let answerQuota: Int?
    public let answer: Answer?

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(id, forKey: .id)
        try container.encode(createdAt, forKey: .createdAt)
        try container.encode(updatedAt, forKey: .updatedAt)
        try container.encode(deletedAt, forKey: .deletedAt)
        try container.encode(tenantId, forKey: .tenantId)
        try container.encode(title, forKey: .title)
        try container.encode(subtitle, forKey: .subtitle)
        try container.encode(kind, forKey: .kind)
        try container.encode(active, forKey: .active)
        try container.encode(expiresAt, forKey: .expiresAt)
        try container.encode(answerQuota, forKey: .answerQuota)
        try container.encode(answer, forKey: .answer)

        switch data {
        case .checkboxQuestionBody(let checkboxQuestionBody):
            try container.encode(checkboxQuestionBody, forKey: .data)
        case .imageQuestionBody(let imageQuestionBody):
            try container.encode(imageQuestionBody, forKey: .data)
        case .choiceQuestionBody(let choiceQuestionBody):
            try container.encode(choiceQuestionBody, forKey: .data)
        case .starQuestionBody(let starQuestionBody):
            try container.encode(starQuestionBody, forKey: .data)
        case .ratingQuestionBody(let ratingQuestionBody):
            try container.encode(ratingQuestionBody, forKey: .data)
        case .shortTextQuestionBody(let shortTextBody):
            try container.encode(shortTextBody, forKey: .data)
        case .longTextQuestionBody(let longTextBody):
            try container.encode(longTextBody, forKey: .data)
        case .booleanQuestionBody(let booleanBody):
            try container.encode(booleanBody, forKey: .data)
        }
    }
}

public struct QuestionCollectionResponse: Codable, Equatable, Hashable {
    // MARK: - Lifecycle

    public init(
        page: Int,
        pageCount: Int,
        pageSize: Int,
        totalCount: Int,
        data: [Question]
    ) {
        self.page = page
        self.pageCount = pageCount
        self.pageSize = pageSize
        self.totalCount = totalCount
        self.data = data
    }

    // MARK: - Public

    public enum CodingKeys: String, CodingKey {
        case page
        case pageCount
        case pageSize
        case totalCount
        case data
    }

    public let page: Int
    public let pageCount: Int
    public let pageSize: Int
    public let totalCount: Int
    public let data: [Question]
}

public struct NotificationRecipient: Codable, Equatable, Hashable {
    // MARK: - Lifecycle

    public init(
        userId: String?
    ) {
        self.userId = userId
    }

    // MARK: - Public

    public enum CodingKeys: String, CodingKey {
        case userId
    }

    public let userId: String?
}

public struct CreateNotificationRequestBody: Codable, Equatable, Hashable {
    // MARK: - Lifecycle

    public init(
        type: String?,
        title: String,
        subtitle: String?,
        body: String?,
        imageUrl: String?,
        data: [String: AnyCodable]?,
        action: [String: AnyCodable]?,
        deduplicationId: String?,
        groupId: String?,
        visible: Bool?,
        silent: Bool?,
        contentAvailable: Bool?,
        expiresAt: String?,
        recipients: [NotificationRecipient]
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

    // MARK: - Public

    public enum CodingKeys: String, CodingKey {
        case type
        case title
        case subtitle
        case body
        case imageUrl
        case data
        case action
        case deduplicationId
        case groupId
        case visible
        case silent
        case contentAvailable
        case expiresAt
        case recipients
    }

    public let type: String?
    public let title: String
    public let subtitle: String?
    public let body: String?
    public let imageUrl: String?
    public let data: [String: AnyCodable]?
    public let action: [String: AnyCodable]?
    public let deduplicationId: String?
    public let groupId: String?
    public let visible: Bool?
    public let silent: Bool?
    public let contentAvailable: Bool?
    public let expiresAt: String?
    public let recipients: [NotificationRecipient]
}

public struct NotificationResponse: Codable, Equatable, Hashable, Identifiable {
    // MARK: - Lifecycle

    public init(
        type: String?,
        title: String,
        subtitle: String?,
        body: String?,
        imageUrl: String?,
        data: [String: AnyCodable]?,
        action: [String: AnyCodable]?,
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

    // MARK: - Public

    public enum CodingKeys: String, CodingKey {
        case type
        case title
        case subtitle
        case body
        case imageUrl
        case data
        case action
        case deduplicationId
        case groupId
        case visible
        case silent
        case contentAvailable
        case expiresAt
        case userId
        case id
        case createdAt
        case updatedAt
        case deletedAt
        case viewedAt
        case version
    }

    public let type: String?
    public let title: String
    public let subtitle: String?
    public let body: String?
    public let imageUrl: String?
    public let data: [String: AnyCodable]?
    public let action: [String: AnyCodable]?
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
}

public struct NotificationCollectionResponse: Codable, Equatable, Hashable {
    // MARK: - Lifecycle

    public init(
        page: Int,
        pageCount: Int,
        pageSize: Int,
        totalCount: Int,
        data: [NotificationResponse]
    ) {
        self.page = page
        self.pageCount = pageCount
        self.pageSize = pageSize
        self.totalCount = totalCount
        self.data = data
    }

    // MARK: - Public

    public enum CodingKeys: String, CodingKey {
        case page
        case pageCount
        case pageSize
        case totalCount
        case data
    }

    public let page: Int
    public let pageCount: Int
    public let pageSize: Int
    public let totalCount: Int
    public let data: [NotificationResponse]
}

public struct ReadNotificationsRequestBody: Codable, Equatable, Hashable {
    // MARK: - Lifecycle

    public init(
        notificationIds: [String]
    ) {
        self.notificationIds = notificationIds
    }

    // MARK: - Public

    public enum CodingKeys: String, CodingKey {
        case notificationIds
    }

    public let notificationIds: [String]
}

public enum TicketType: String, Codable, Equatable {
    case bug
    case feature
    case improvement
}

public enum TicketStatus: String, Codable, Equatable {
    case open
    case planning
    case inProgress = "in_progress"
    case done
    case live
    case closed
    case archived
}

public enum TicketDisplayStatus: String, Codable, Equatable {
    case pending
    case upcoming
    case inProgress = "in_progress"
    case live
    case rejected
}

public struct UserTicket: Codable, Equatable, Hashable, Identifiable {
    // MARK: - Lifecycle

    public init(
        id: String,
        createdAt: String,
        updatedAt: String,
        deletedAt: String?,
        title: String,
        type: TicketType,
        description: String?,
        status: TicketStatus,
        displayStatus: TicketDisplayStatus,
        displayStatusBadgeTitle: String,
        voteCount: Int,
        votingEnabled: Bool,
        voted: Bool
    ) {
        self.id = id
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.deletedAt = deletedAt
        self.title = title
        self.type = type
        self.description = description
        self.status = status
        self.displayStatus = displayStatus
        self.displayStatusBadgeTitle = displayStatusBadgeTitle
        self.voteCount = voteCount
        self.votingEnabled = votingEnabled
        self.voted = voted
    }

    // MARK: - Public

    public enum CodingKeys: String, CodingKey {
        case id
        case createdAt
        case updatedAt
        case deletedAt
        case title
        case type
        case description
        case status
        case displayStatus
        case displayStatusBadgeTitle
        case voteCount
        case votingEnabled
        case voted
    }

    public let id: String
    public let createdAt: String
    public let updatedAt: String
    public let deletedAt: String?
    public let title: String
    public let type: TicketType
    public let description: String?
    public let status: TicketStatus
    public let displayStatus: TicketDisplayStatus
    public let displayStatusBadgeTitle: String
    public let voteCount: Int
    public let votingEnabled: Bool
    public let voted: Bool
}

public struct CollectionResponse: Codable, Equatable, Hashable {
    // MARK: - Lifecycle

    public init(
        page: Int,
        pageCount: Int,
        pageSize: Int,
        totalCount: Int
    ) {
        self.page = page
        self.pageCount = pageCount
        self.pageSize = pageSize
        self.totalCount = totalCount
    }

    // MARK: - Public

    public enum CodingKeys: String, CodingKey {
        case page
        case pageCount
        case pageSize
        case totalCount
    }

    public let page: Int
    public let pageCount: Int
    public let pageSize: Int
    public let totalCount: Int
}

public struct UserTicketCollectionResponse: Codable, Equatable, Hashable {
    // MARK: - Lifecycle

    public init(
        page: Int,
        pageCount: Int,
        pageSize: Int,
        totalCount: Int,
        data: [UserTicket]
    ) {
        self.page = page
        self.pageCount = pageCount
        self.pageSize = pageSize
        self.totalCount = totalCount
        self.data = data
    }

    // MARK: - Public

    public enum CodingKeys: String, CodingKey {
        case page
        case pageCount
        case pageSize
        case totalCount
        case data
    }

    public let page: Int
    public let pageCount: Int
    public let pageSize: Int
    public let totalCount: Int
    public let data: [UserTicket]
}

public struct AppRoadmapConfiguration: Codable, Equatable, Hashable {
    // MARK: - Lifecycle

    public init(
        form: FeedbackFormDataStub?
    ) {
        self.form = form
    }

    // MARK: - Public

    public let form: FeedbackFormDataStub?
}

public struct CreatePushTokenRequestBody: Codable, Equatable, Hashable {
    // MARK: - Lifecycle

    public init(
        userId: String?,
        apnsToken: String
    ) {
        self.userId = userId
        self.apnsToken = apnsToken
    }

    // MARK: - Public

    public enum CodingKeys: String, CodingKey {
        case userId
        case apnsToken
    }

    public let userId: String?
    public let apnsToken: String
}

public struct UserResponse: Codable, Equatable, Hashable, Identifiable {
    // MARK: - Lifecycle

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

    // MARK: - Public

    public enum CodingKeys: String, CodingKey {
        case id
        case createdAt
        case updatedAt
        case deletedAt
        case name
        case firstName
        case lastName
        case email
        case emailVerified
        case avatarUrl
        case locale
        case type
    }

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
}

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

public struct CreateUserRequestBody: Codable, Equatable, Hashable {
    // MARK: - Lifecycle

    public init(
        firstName: String?,
        lastName: String?,
        email: String?,
        emailVerified: Bool?,
        avatarUrl: String?,
        locale: String?,
        type: String,
        identities: [CreateIdentityRequestBody]?
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

    // MARK: - Public

    public enum CodingKeys: String, CodingKey {
        case firstName
        case lastName
        case email
        case emailVerified
        case avatarUrl
        case locale
        case type
        case identities
    }

    public let firstName: String?
    public let lastName: String?
    public let email: String?
    public let emailVerified: Bool?
    public let avatarUrl: String?
    public let locale: String?
    public let type: String
    public let identities: [CreateIdentityRequestBody]?
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

public struct UserCollectionResponse: Codable, Equatable, Hashable {
    // MARK: - Lifecycle

    public init(
        page: Int,
        pageCount: Int,
        pageSize: Int,
        totalCount: Int,
        data: [UserResponse]
    ) {
        self.page = page
        self.pageCount = pageCount
        self.pageSize = pageSize
        self.totalCount = totalCount
        self.data = data
    }

    // MARK: - Public

    public enum CodingKeys: String, CodingKey {
        case page
        case pageCount
        case pageSize
        case totalCount
        case data
    }

    public let page: Int
    public let pageCount: Int
    public let pageSize: Int
    public let totalCount: Int
    public let data: [UserResponse]
}

public struct UserInfoResponse: Codable, Equatable, Hashable {
    // MARK: - Lifecycle

    public init(
        user: UserResponse?
    ) {
        self.user = user
    }

    // MARK: - Public

    public let user: UserResponse?
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
