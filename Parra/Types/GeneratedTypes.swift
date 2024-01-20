//
//  Parra+GeneratedTypes.swift
//  Parra
//
//  Created by Michael MacCallum on 12/27/21.
//

import Foundation

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
        case isTest
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
        case createdAt
        case updatedAt
        case deletedAt
        case name
        case isTest
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
        case pageCount
        case pageSize
        case totalCount
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
        case createdAt
        case updatedAt
        case deletedAt
        case name
        case description
        case tenantId
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
        case createdAt
        case updatedAt
        case deletedAt
        case name
        case description
        case tenantId
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
        case pageCount
        case pageSize
        case totalCount
        case data
    }
}

public struct FeedbackFormResponse: Codable, Equatable, Hashable, Identifiable {
    public let id: String
    public let createdAt: String
    public let updatedAt: String
    public let deletedAt: String?
    public let title: String
    public let description: String?
    public let data: FeedbackFormData

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

    public enum CodingKeys: String, CodingKey {
        case id
        case createdAt
        case updatedAt
        case deletedAt
        case title
        case description
        case data
    }
}

public struct ParraFeedbackFormResponse: Codable, Equatable, Hashable, Identifiable {
    public let id: String
    public let createdAt: String
    public let updatedAt: String
    public let deletedAt: String?
    public let data: FeedbackFormData

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

    public enum CodingKeys: String, CodingKey {
        case id
        case createdAt
        case updatedAt
        case deletedAt
        case data
    }
}

public struct FeedbackFormData: Codable, Equatable, Hashable {
    public let title: String
    public let description: String?
    public let fields: Array<FeedbackFormField>

    public init(
        title: String,
        description: String?,
        fields: Array<FeedbackFormField>
    ) {
        self.title = title
        self.description = description
        self.fields = fields
    }
}

public enum FeedbackFormFieldType: String, Codable {
    case text = "text"
    case input = "input"
    case select = "select"
}

public struct FeedbackFormField: Codable, Equatable, Hashable, Identifiable {
    public var id: String {
        return name
    }

    public let name: String
    public let title: String?
    public let helperText: String?
    public let type: FeedbackFormFieldType
    public let required: Bool?
    public let data: FeedbackFormFieldData

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

    public enum CodingKeys: String, CodingKey {
        case name
        case title
        case helperText
        case type
        case required
        case data
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.name = try container.decode(String.self, forKey: .name)
        self.title = try container.decode(String.self, forKey: .title)
        self.helperText = try container.decodeIfPresent(String.self, forKey: .helperText)
        self.type = try container.decode(FeedbackFormFieldType.self, forKey: .type)
        self.required = try container.decode(Bool.self, forKey: .required)
        switch type {
        case .input:
            self.data = .feedbackFormInputFieldData(
                try container.decode(FeedbackFormInputFieldData.self, forKey: .data)
            )
        case .text:
            self.data = .feedbackFormTextFieldData(
                try container.decode(FeedbackFormTextFieldData.self, forKey: .data)
            )
        case .select:
            self.data = .feedbackFormSelectFieldData(
                try container.decode(FeedbackFormSelectFieldData.self, forKey: .data)
            )
        }
    }
}

public enum FeedbackFormFieldData: Codable, Equatable, Hashable {
    case feedbackFormTextFieldData(FeedbackFormTextFieldData)
    case feedbackFormSelectFieldData(FeedbackFormSelectFieldData)
    case feedbackFormInputFieldData(FeedbackFormInputFieldData)
}

public protocol FeedbackFormFieldDataType {}

public struct FeedbackFormTextFieldData: Codable, Equatable, Hashable, FeedbackFormFieldDataType {
    public let placeholder: String?
    public let lines: Int?
    public let maxLines: Int?
    public let minCharacters: Int?
    public let maxCharacters: Int?
    public let maxHeight: Int?

    public init(
        placeholder: String?,
        // TODO: Remove lines/maxLines
        lines: Int?,
        maxLines: Int?,
        minCharacters: Int?,
        maxCharacters: Int?,
        maxHeight: Int?
    ) {
        self.placeholder = placeholder
        self.lines = lines
        self.maxLines = maxLines
        self.minCharacters = minCharacters
        self.maxCharacters = maxCharacters
        self.maxHeight = maxHeight
    }

    public enum CodingKeys: String, CodingKey {
        case placeholder
        case lines
        case maxLines
        case minCharacters
        case maxCharacters
        case maxHeight
    }
}

public struct FeedbackFormInputFieldData: Codable, Equatable, Hashable, FeedbackFormFieldDataType {
    public let placeholder: String

    public init(
        placeholder: String
    ) {
        self.placeholder = placeholder
    }
}

public struct FeedbackFormSelectFieldData: Codable, Equatable, Hashable, FeedbackFormFieldDataType {
    public let placeholder: String?
    public let options: Array<FeedbackFormSelectFieldOption>

    public init(
        placeholder: String?,
        options: Array<FeedbackFormSelectFieldOption>
    ) {
        self.placeholder = placeholder
        self.options = options
    }
}

public struct FeedbackFormSelectFieldOption: Codable, Equatable, Hashable, Identifiable {
    public var id: String {
        value
    }

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
        case isOther
    }
}

public struct FeedbackFormStub: Codable, Equatable, Hashable, Identifiable {
    public let id: String
    public let createdAt: String
    public let updatedAt: String
    public let deletedAt: String?
    public let title: String
    public let description: String?

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

    public enum CodingKeys: String, CodingKey {
        case id
        case createdAt
        case updatedAt
        case deletedAt
        case title
        case description
    }
}

public struct FeedbackFormCollectionResponse: Codable, Equatable, Hashable {
    public let page: Int
    public let pageCount: Int
    public let pageSize: Int
    public let totalCount: Int
    public let data: Array<FeedbackFormStub>

    public init(
        page: Int,
        pageCount: Int,
        pageSize: Int,
        totalCount: Int,
        data: Array<FeedbackFormStub>
    ) {
        self.page = page
        self.pageCount = pageCount
        self.pageSize = pageSize
        self.totalCount = totalCount
        self.data = data
    }

    public enum CodingKeys: String, CodingKey {
        case page
        case pageCount
        case pageSize
        case totalCount
        case data
    }
}

public struct FeedbackMetrics: Codable, Equatable, Hashable {
    public let userCount: Int
    public let answerCount: Int
    public let questionCount: Int
    public let questionsCreatedThisMonth: Int

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

    public enum CodingKeys: String, CodingKey {
        case userCount
        case answerCount
        case questionCount
        case questionsCreatedThisMonth
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
        case createdAt
        case updatedAt
        case deletedAt
        case questionId
        case userId
        case tenantId
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

public enum CardItemDisplayType: String, Codable {
    case inline = "inline"
    case popup = "popup"
    case drawer = "drawer"
}

public enum CardItemType: String, Codable {
    case question = "question"
}

public struct ParraCardItem: Codable, Equatable, Hashable {
    public let id: String
    public let campaignId: String
    public let campaignActionId: String
    public let questionId: String?
    public let type: CardItemType
    public let displayType: CardItemDisplayType?
    public let version: String
    public let data: CardItemData

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
        self.campaignActionId = try container.decode(String.self, forKey: .campaignActionId)
        self.questionId = try container.decode(String.self, forKey: .questionId)
        self.type = try container.decode(CardItemType.self, forKey: .type)
        self.displayType = try container.decode(CardItemDisplayType.self, forKey: .displayType)
        self.version = try container.decode(String.self, forKey: .version)
        switch type {
        case .question:
            self.data = .question(try container.decode(Question.self, forKey: .data))
        }
    }
    
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
                Logger.warn("CardsResponse error parsing card", [NSLocalizedDescriptionKey: debugError])
                return nil
            }
        }
    }
}

public enum QuestionKind: String, Codable {
    case radio = "radio"
    case checkbox = "checkbox"
    case rating = "rating"
    case star = "star"
    case boolean = "boolean"
    case image = "image"
    case textShort = "short-text"
    case textLong = "long-text"
}

public struct Asset: Codable, Equatable, Hashable, Identifiable {
    public let id: String
    public let url: URL
}

public struct CheckboxQuestionOption: Codable, Equatable, Hashable, Identifiable {
    public let title: String
    public let value: String
    public let isOther: Bool?
    public let id: String

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

    public enum CodingKeys: String, CodingKey {
        case title
        case value
        case isOther
        case id
    }
}

public struct CheckboxQuestionBody: Codable, Equatable, Hashable {
    public let options: Array<CheckboxQuestionOption>

    public init(
        options: Array<CheckboxQuestionOption>
    ) {
        self.options = options
    }
}

public struct ImageQuestionOption: Codable, Equatable, Hashable, Identifiable {
    public let title: String?
    public let value: String
    public let id: String
    public let asset: Asset

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

    public enum CodingKeys: String, CodingKey {
        case imageAssetId
        case title
        case value
        case id
        case imageAssetUrl
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        self.title = try container.decodeIfPresent(String.self, forKey: .title)
        self.value = try container.decode(String.self, forKey: .value)
        self.id = try container.decode(String.self, forKey: .id)

        let imageId = try container.decodeIfPresent(String.self, forKey: .imageAssetId)
        let imageUrlString = try container.decodeIfPresent(String.self, forKey: .imageAssetUrl)

        if let imageId,
           let imageUrlString = imageUrlString,
           let imageUrl = URL(string: imageUrlString) {

            self.asset = Asset(id: imageId, url: imageUrl)
        } else {
            throw ParraError.jsonError("Failed to decode asset for image question option")
        }
    }

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
    public let options: Array<ImageQuestionOption>

    public init(
        options: Array<ImageQuestionOption>
    ) {
        self.options = options
    }
}

public struct ChoiceQuestionOption: Codable, Equatable, Hashable, Identifiable {
    public let title: String?
    public let value: String
    public let isOther: Bool?
    public let id: String
    
    public init(
        title: String?,
        value: String,
        isOther: Bool?,
        id: String
    ) {
        self.title = title
        self.value = value
        self.isOther = isOther
        self.id = id
    }

    public enum CodingKeys: String, CodingKey {
        case title
        case value
        case isOther
        case id
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

public struct ShortTextQuestionBody: Codable, Equatable, Hashable {
    public let placeholder: String?
    public let minLength: Int
    public let maxLength: Int

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

        self.placeholder = try container.decodeIfPresent(String.self, forKey: .placeholder)
        self.minLength = try container.decodeIfPresent(Int.self, forKey: .minLength) ?? 1
        self.maxLength = try container.decodeIfPresent(Int.self, forKey: .maxLength) ?? Int.max
    }

    public enum CodingKeys: String, CodingKey {
        case placeholder
        case minLength
        case maxLength
    }
}

public struct LongTextQuestionBody: Codable, Equatable, Hashable {
    public let placeholder: String?
    public let minLength: Int
    public let maxLength: Int

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

        self.placeholder = try container.decodeIfPresent(String.self, forKey: .placeholder)
        self.minLength = try container.decodeIfPresent(Int.self, forKey: .minLength) ?? 1
        self.maxLength = try container.decodeIfPresent(Int.self, forKey: .maxLength) ?? .max
    }

    public enum CodingKeys: String, CodingKey {
        case placeholder
        case minLength
        case maxLength
    }
}

public struct BooleanQuestionOption: Codable, Equatable, Hashable, Identifiable {
    public let title: String
    public let value: String
    public let id: String

    public init(
        title: String,
        value: String,
        id: String
    ) {
        self.title = title
        self.value = value
        self.id = id
    }
}

public struct BooleanQuestionBody: Codable, Equatable, Hashable {
    public let options: Array<BooleanQuestionOption>

    public init(
        options: Array<BooleanQuestionOption>
    ) {
        self.options = options
    }
}


public struct StarQuestionBody: Codable, Equatable, Hashable {
    public let starCount: Int
    public let leadingLabel: String?
    public let centerLabel: String?
    public let trailingLabel: String?

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
        self.leadingLabel = try container.decodeIfPresent(String.self, forKey: .leadingLabel)
        self.centerLabel = try container.decodeIfPresent(String.self, forKey: .centerLabel)
        self.trailingLabel = try container.decodeIfPresent(String.self, forKey: .trailingLabel)
    }
}

public struct RatingQuestionOption: Codable, Equatable, Hashable, Identifiable {
    public let title: String
    public let value: Int
    public let id: String

    public init(
        title: String,
        value: Int,
        id: String
    ) {
        self.title = title
        self.value = value
        self.id = id
    }
}

public struct RatingQuestionBody: Codable, Equatable, Hashable {
    public let options: Array<RatingQuestionOption>
    public let leadingLabel: String?
    public let centerLabel: String?
    public let trailingLabel: String?

    public init(
        options: Array<RatingQuestionOption>,
        leadingLabel: String?,
        centerLabel: String?,
        trailingLabel: String?
    ) {
        self.options = options
        self.leadingLabel = leadingLabel
        self.centerLabel = centerLabel
        self.trailingLabel = trailingLabel
    }

    public enum CodingKeys: String, CodingKey {
        case options
        case leadingLabel
        case centerLabel
        case trailingLabel
    }
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
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(String.self, forKey: .id)
        self.createdAt = try container.decode(String.self, forKey: .createdAt)
        self.updatedAt = try container.decode(String.self, forKey: .updatedAt)
        self.deletedAt = try container.decodeIfPresent(String.self, forKey: .deletedAt)
        self.tenantId = try container.decode(String.self, forKey: .tenantId)
        self.title = try container.decode(String.self, forKey: .title)
        self.subtitle = try container.decodeIfPresent(String.self, forKey: .subtitle)
        self.active = try container.decodeIfPresent(Bool.self, forKey: .active)
        self.expiresAt = try container.decodeIfPresent(String.self, forKey: .expiresAt)
        self.answerQuota = try container.decodeIfPresent(Int.self, forKey: .answerQuota)
        self.answer = try container.decodeIfPresent(Answer.self, forKey: .answer)
        self.kind = try container.decode(QuestionKind.self, forKey: .kind)

        switch kind {
        case .checkbox:
            self.data = .checkboxQuestionBody(try container.decode(CheckboxQuestionBody.self, forKey: .data))
        case .image:
            self.data = .imageQuestionBody(try container.decode(ImageQuestionBody.self, forKey: .data))
        case .radio:
            self.data = .choiceQuestionBody(try container.decode(ChoiceQuestionBody.self, forKey: .data))
        case .star:
            self.data = .starQuestionBody(try container.decode(StarQuestionBody.self, forKey: .data))
        case .rating:
            self.data = .ratingQuestionBody(try container.decode(RatingQuestionBody.self, forKey: .data))
        case .textShort:
            self.data = .shortTextQuestionBody(try container.decode(ShortTextQuestionBody.self, forKey: .data))
        case .textLong:
            self.data = .longTextQuestionBody(try container.decode(LongTextQuestionBody.self, forKey: .data))
        case .boolean:
            self.data = .booleanQuestionBody(try container.decode(BooleanQuestionBody.self, forKey: .data))
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
        case pageCount
        case pageSize
        case totalCount
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
        case userId
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
        case pageCount
        case pageSize
        case totalCount
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
        case notificationIds
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
        case userId
        case apnsToken
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
        case providerUserId
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
        case createdAt
        case updatedAt
        case deletedAt
        case provider
        case providerUserId
        case userId
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
        case firstName
        case lastName
        case email
        case emailVerified
        case avatarUrl
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
        case firstName
        case lastName
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
        case pageCount
        case pageSize
        case totalCount
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
