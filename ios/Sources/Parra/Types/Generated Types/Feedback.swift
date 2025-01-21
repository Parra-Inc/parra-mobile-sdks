//
//  Feedback.swift
//  Parra
//
//  Created by Mick MacCallum on 3/29/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import Foundation

struct FeedbackFormResponse: Codable, Equatable, Hashable, Identifiable {
    // MARK: - Lifecycle

    public init(
        id: String,
        createdAt: String,
        updatedAt: String,
        deletedAt: String?,
        title: String,
        description: String?,
        data: ParraFeedbackFormData
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

    public let id: String
    public let createdAt: String
    public let updatedAt: String
    public let deletedAt: String?
    public let title: String
    public let description: String?
    public let data: ParraFeedbackFormData

    // MARK: - Internal

    enum CodingKeys: String, CodingKey {
        case id
        case createdAt
        case updatedAt
        case deletedAt
        case title
        case description
        case data
    }
}

/// User facing
public struct ParraFeedbackForm: Codable, Equatable, Identifiable {
    // MARK: - Lifecycle

    init(from response: ParraFeedbackFormResponse) {
        self.id = response.id
        self.data = response.data
    }

    init(from stub: ParraFeedbackFormDataStub) {
        self.id = stub.id
        self.data = stub.data
    }

    // MARK: - Public

    public let id: String
    public let data: ParraFeedbackFormData
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
        data: ParraFeedbackFormData
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
    let data: ParraFeedbackFormData
}

public struct ParraFeedbackFormData: Codable, Equatable, Hashable {
    // MARK: - Lifecycle

    init(
        title: String,
        description: String?,
        fields: [ParraFeedbackFormField]
    ) {
        self.title = title
        self.description = description
        self.fields = .init(fields)
    }

    // MARK: - Public

    public let title: String
    public let description: String?
    public let fields: PartiallyDecodableArray<ParraFeedbackFormField>
}

public struct ParraFeedbackFormDataStub: Codable, Equatable, Hashable, Identifiable {
    // MARK: - Lifecycle

    public init(
        id: String,
        createdAt: String,
        updatedAt: String,
        deletedAt: String?,
        data: ParraFeedbackFormData
    ) {
        self.id = id
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.deletedAt = deletedAt
        self.data = data
    }

    // MARK: - Public

    public let id: String
    public let createdAt: String
    public let updatedAt: String
    public let deletedAt: String?
    public let data: ParraFeedbackFormData

    // MARK: - Internal

    enum CodingKeys: String, CodingKey {
        case id
        case createdAt
        case updatedAt
        case deletedAt
        case data
    }
}

public enum ParraFeedbackFormFieldType: String, Codable {
    case input
    case text
    case select
}

public struct ParraFeedbackFormField: Codable, Equatable, Hashable, Identifiable {
    // MARK: - Lifecycle

    public init(
        name: String,
        title: String?,
        helperText: String?,
        type: ParraFeedbackFormFieldType,
        required: Bool?,
        hidden: Bool?,
        data: ParraFeedbackFormFieldData
    ) {
        self.name = name
        self.title = title
        self.helperText = helperText
        self.type = type
        self.required = required
        self.hidden = hidden
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
            ParraFeedbackFormFieldType.self,
            forKey: .type
        )
        self.required = try container.decodeIfPresent(Bool.self, forKey: .required)
        self.hidden = try container
            .decodeIfPresent(Bool.self, forKey: .hidden)
        switch type {
        case .input:
            self.data = try .feedbackFormInputFieldData(
                container.decode(
                    ParraFeedbackFormInputFieldData.self,
                    forKey: .data
                )
            )
        case .text:
            self.data = try .feedbackFormTextFieldData(
                container.decode(ParraFeedbackFormTextFieldData.self, forKey: .data)
            )
        case .select:
            self.data = try .feedbackFormSelectFieldData(
                container.decode(
                    ParraFeedbackFormSelectFieldData.self,
                    forKey: .data
                )
            )
        }
    }

    // MARK: - Public

    public let name: String
    public let title: String?
    public let helperText: String?
    public let type: ParraFeedbackFormFieldType
    public let required: Bool?
    public let hidden: Bool?
    public let data: ParraFeedbackFormFieldData

    public var id: String {
        return name
    }

    // MARK: - Internal

    enum CodingKeys: String, CodingKey {
        case name
        case title
        case helperText
        case type
        case required
        case hidden
        case data
    }
}

public enum ParraFeedbackFormFieldData: Codable, Equatable, Hashable {
    case feedbackFormTextFieldData(ParraFeedbackFormTextFieldData)
    case feedbackFormSelectFieldData(ParraFeedbackFormSelectFieldData)
    case feedbackFormInputFieldData(ParraFeedbackFormInputFieldData)
}

public protocol ParraFeedbackFormFieldDataType {}

public struct ParraFeedbackFormInputFieldData: Codable, Equatable, Hashable,
    ParraFeedbackFormFieldDataType
{
    // MARK: - Lifecycle

    public init(
        placeholder: String?
    ) {
        self.placeholder = placeholder
    }

    // MARK: - Public

    public let placeholder: String?
}

public struct ParraFeedbackFormTextFieldData: Codable, Equatable, Hashable,
    ParraFeedbackFormFieldDataType
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

    public let placeholder: String?
    public let lines: Int?
    public let minCharacters: Int?
    public let maxCharacters: Int?
    public let maxHeight: Int?

    // MARK: - Internal

    enum CodingKeys: String, CodingKey {
        case placeholder
        case lines
        case minCharacters
        case maxCharacters
        case maxHeight
    }
}

public struct ParraFeedbackFormSelectFieldData: Codable, Equatable, Hashable,
    ParraFeedbackFormFieldDataType
{
    // MARK: - Lifecycle

    public init(
        placeholder: String?,
        options: [ParraFeedbackFormSelectFieldOption]
    ) {
        self.placeholder = placeholder
        self.options = options
    }

    // MARK: - Public

    /// If provided, the title for an empty option.
    public let placeholder: String?
    public let options: [ParraFeedbackFormSelectFieldOption]
}

public struct ParraFeedbackFormSelectFieldOption: Codable, Equatable, Hashable,
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

    public let title: String
    public let value: String
    public let isOther: Bool?

    public var id: String {
        value
    }

    // MARK: - Internal

    enum CodingKeys: String, CodingKey {
        case title
        case value
        case isOther
    }
}

struct FeedbackFormStub: Codable, Equatable, Hashable, Identifiable {
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

    public let id: String
    public let createdAt: String
    public let updatedAt: String
    public let deletedAt: String?
    public let title: String
    public let description: String?

    // MARK: - Internal

    enum CodingKeys: String, CodingKey {
        case id
        case createdAt
        case updatedAt
        case deletedAt
        case title
        case description
    }
}

struct FeedbackFormCollectionResponse: Codable, Equatable, Hashable {
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

    public let page: Int
    public let pageCount: Int
    public let pageSize: Int
    public let totalCount: Int
    public let data: [FeedbackFormStub]

    // MARK: - Internal

    enum CodingKeys: String, CodingKey {
        case page
        case pageCount
        case pageSize
        case totalCount
        case data
    }
}

struct FeedbackMetrics: Codable, Equatable, Hashable {
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

    public let userCount: Int
    public let answerCount: Int
    public let questionCount: Int
    public let questionsCreatedThisMonth: Int

    // MARK: - Internal

    enum CodingKeys: String, CodingKey {
        case userCount
        case answerCount
        case questionCount
        case questionsCreatedThisMonth
    }
}

public struct ParraAnswerData: Codable, Equatable, Hashable {
    public init(
    ) {}
}

public struct ParraAnswer: Codable, Equatable, Hashable, Identifiable {
    // MARK: - Lifecycle

    public init(
        id: String,
        createdAt: String,
        updatedAt: String,
        deletedAt: String?,
        questionId: String,
        userId: String,
        tenantId: String,
        data: ParraAnswerData
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

    public let id: String
    public let createdAt: String
    public let updatedAt: String
    public let deletedAt: String?
    public let questionId: String
    public let userId: String
    public let tenantId: String
    public let data: ParraAnswerData

    // MARK: - Internal

    enum CodingKeys: String, CodingKey {
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

struct AnswerQuestionBody: Codable, Equatable, Hashable {
    // MARK: - Lifecycle

    public init(
        data: ParraAnswerData
    ) {
        self.data = data
    }

    // MARK: - Public

    public let data: ParraAnswerData
}

public enum ParraCardItemData: Codable, Equatable, Hashable {
    case question(ParraQuestion)
}

public enum ParraCardItemDisplayType: String, Codable {
    case inline
    case popup
    case drawer
}

public enum ParraCardItemType: String, Codable {
    case question
}

public struct ParraCardItem: Codable, Equatable, Hashable {
    // MARK: - Lifecycle

    public init(
        id: String,
        campaignId: String,
        campaignActionId: String,
        questionId: String?,
        type: ParraCardItemType,
        displayType: ParraCardItemDisplayType?,
        version: String,
        data: ParraCardItemData
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
        self.type = try container.decode(ParraCardItemType.self, forKey: .type)
        self.displayType = try container.decode(
            ParraCardItemDisplayType.self,
            forKey: .displayType
        )
        self.version = try container.decode(String.self, forKey: .version)
        switch type {
        case .question:
            self.data = try .question(container.decode(
                ParraQuestion.self,
                forKey: .data
            ))
        }
    }

    // MARK: - Public

    public let id: String
    public let campaignId: String
    public let campaignActionId: String
    public let questionId: String?
    public let type: ParraCardItemType
    public let displayType: ParraCardItemDisplayType?
    public let version: String
    public let data: ParraCardItemData

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

    // MARK: - Internal

    enum CodingKeys: String, CodingKey {
        case id
        case campaignId
        case campaignActionId
        case questionId
        case type
        case displayType
        case version
        case data
    }
}

struct CardsResponse: Codable, Equatable, Hashable {
    // MARK: - Lifecycle

    init(
        items: [ParraCardItem]
    ) {
        self.items = .init(items)
    }

    // MARK: - Public

    public let items: PartiallyDecodableArray<ParraCardItem>
}

public enum ParraQuestionKind: String, Codable, Equatable {
    case radio
    case checkbox
    case rating
    case star
    case boolean
    case image
    case textShort = "short-text"
    case textLong = "long-text"
}

public struct ParraImageAssetThumbnail: Codable, Equatable, Hashable {
    // MARK: - Lifecycle

    public init(
        q: String,
        size: CGSize
    ) {
        self.q = q
        self._size = _ParraSize(cgSize: size)
    }

    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(
            keyedBy: CodingKeys.self
        )

        self.q = try container.decode(
            String.self,
            forKey: .q
        )

        self._size = try container.decode(
            _ParraSize.self,
            forKey: .size
        )
    }

    // MARK: - Public

    public let q: String

    public var size: CGSize {
        return _size.toCGSize
    }

    public func encode(to encoder: any Encoder) throws {
        var container = encoder.container(
            keyedBy: CodingKeys.self
        )

        try container.encode(q, forKey: .q)
        try container.encode(_size, forKey: .size)
    }

    // MARK: - Internal

    enum CodingKeys: String, CodingKey {
        case q
        case size
    }

    // MARK: - Private

    private let _size: _ParraSize
}

public enum ParraImageAssetThumbnailSize {
    case xs
    case sm
    case md
    case lg
    case xl
    case xxl

    // MARK: - Public

    public static func recommended(for size: CGSize) -> Self {
        let maxDimension = max(size.height, size.width)

        if maxDimension < 64 {
            return .xs
        }

        if maxDimension < 128 {
            return .sm
        }

        if maxDimension < 256 {
            return .md
        }

        if maxDimension < 512 {
            return .lg
        }

        if maxDimension < 1_024 {
            return .xl
        }

        return .xxl
    }
}

public struct ParraImageAssetThumbnails: Codable, Equatable, Hashable {
    /// Min dimension is 64px
    public let xs: ParraImageAssetThumbnail

    /// Min dimension is 128px
    public let sm: ParraImageAssetThumbnail

    /// Min dimension is 256px
    public let md: ParraImageAssetThumbnail

    /// Min dimension is 512px
    public let lg: ParraImageAssetThumbnail

    /// Min dimension is 1024px
    public let xl: ParraImageAssetThumbnail

    /// Min dimension is 2048px
    public let xxl: ParraImageAssetThumbnail

    public func thumbnail(
        for size: ParraImageAssetThumbnailSize
    ) -> ParraImageAssetThumbnail {
        switch size {
        case .xs:
            return xs
        case .sm:
            return sm
        case .md:
            return md
        case .lg:
            return lg
        case .xl:
            return xl
        case .xxl:
            return xxl
        }
    }
}

public struct ParraImageAsset: Codable, Equatable, Hashable, Identifiable {
    // MARK: - Lifecycle

    public init(
        id: String,
        size: CGSize,
        url: URL,
        blurHash: String? = nil,
        thumbnails: ParraImageAssetThumbnails? = nil
    ) {
        self.id = id
        self._size = _ParraSize(cgSize: size)
        self.url = url
        self.blurHash = blurHash
        self.thumbnails = thumbnails
    }

    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(
            keyedBy: CodingKeys.self
        )

        self.id = try container.decode(
            String.self,
            forKey: .id
        )

        self._size = try container.decode(
            _ParraSize.self,
            forKey: .size
        )

        self.url = try container.decode(
            URL.self,
            forKey: .url
        )

        self.blurHash = try container.decodeIfPresent(
            String.self,
            forKey: .blurHash
        )

        self.thumbnails = try container.decodeIfPresent(
            ParraImageAssetThumbnails.self,
            forKey: .thumbnails
        )
    }

    // MARK: - Public

    public let id: String
    public let url: URL
    public let blurHash: String?
    public let thumbnails: ParraImageAssetThumbnails?

    public var size: CGSize {
        return _size.toCGSize
    }

    public func thumbnailUrl(
        for size: ParraImageAssetThumbnailSize
    ) -> (URL, CGSize)? {
        guard let thumbnails else {
            return nil
        }

        let thumb = thumbnails.thumbnail(for: size)

        guard var components = URLComponents(
            url: url,
            resolvingAgainstBaseURL: true
        ) else {
            return nil
        }

        let newParams = thumb.q
            .components(separatedBy: "&")
            .compactMap { param -> URLQueryItem? in
                let parts = param.components(separatedBy: "=")

                guard parts.count == 2 else {
                    return nil
                }

                return URLQueryItem(
                    name: parts[0],
                    value: parts[1]
                )
            }

        if let existingItems = components.queryItems {
            components.queryItems = existingItems + newParams
        } else {
            components.queryItems = newParams
        }

        guard let url = components.url else {
            return nil
        }

        return (url, thumb.size)
    }

    public func encode(to encoder: any Encoder) throws {
        var container = encoder.container(
            keyedBy: CodingKeys.self
        )

        try container.encode(id, forKey: .id)
        try container.encode(url, forKey: .url)
        try container.encode(_size, forKey: .size)
        try container.encodeIfPresent(blurHash, forKey: .blurHash)
        try container.encodeIfPresent(thumbnails, forKey: .thumbnails)
    }

    // MARK: - Internal

    enum CodingKeys: String, CodingKey {
        case id
        case size
        case url
        case blurHash
        case thumbnails
    }

    let _size: _ParraSize
}

public struct ParraCheckboxQuestionOption: Codable, Equatable, Hashable,
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

    public let title: String
    public let value: String
    public let isOther: Bool?
    public let id: String

    // MARK: - Internal

    enum CodingKeys: String, CodingKey {
        case title
        case value
        case isOther
        case id
    }
}

public struct ParraCheckboxQuestionBody: Codable, Equatable, Hashable {
    // MARK: - Lifecycle

    public init(
        options: [ParraCheckboxQuestionOption]
    ) {
        self.options = options
    }

    // MARK: - Public

    public let options: [ParraCheckboxQuestionOption]
}

public struct ParraImageQuestionOption: Codable, Equatable, Hashable, Identifiable {
    // MARK: - Lifecycle

    public init(
        title: String?,
        value: String,
        id: String,
        asset: ParraImageAsset
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
        let imageSize = try container.decodeIfPresent(
            _ParraSize.self,
            forKey: .imageAssetSize
        )

        if let imageId,
           let imageUrlString,
           let imageSize,
           let imageUrl = URL(string: imageUrlString)
        {
            self.asset = ParraImageAsset(
                id: imageId,
                size: imageSize.toCGSize,
                url: imageUrl
            )
        } else {
            throw ParraError
                .jsonError("Failed to decode asset for image question option")
        }
    }

    // MARK: - Public

    public let title: String?
    public let value: String
    public let id: String
    public let asset: ParraImageAsset

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(title, forKey: .title)
        try container.encode(value, forKey: .value)
        try container.encode(id, forKey: .id)
        try container.encode(asset.id, forKey: .imageAssetId)
        try container.encode(asset.url, forKey: .imageAssetUrl)
    }

    // MARK: - Internal

    enum CodingKeys: String, CodingKey {
        case imageAssetId
        case title
        case value
        case id
        case imageAssetUrl
        case imageAssetSize
    }
}

public struct ParraImageQuestionBody: Codable, Equatable, Hashable {
    // MARK: - Lifecycle

    public init(
        options: [ParraImageQuestionOption]
    ) {
        self.options = options
    }

    // MARK: - Public

    public let options: [ParraImageQuestionOption]
}

public struct ParraChoiceQuestionOption: Codable, Equatable, Hashable, Identifiable {
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

    public let title: String
    public let value: String
    public let isOther: Bool?
    public let id: String

    // MARK: - Internal

    enum CodingKeys: String, CodingKey {
        case title
        case value
        case isOther
        case id
    }
}

public struct ParraChoiceQuestionBody: Codable, Equatable, Hashable {
    // MARK: - Lifecycle

    public init(
        options: [ParraChoiceQuestionOption]
    ) {
        self.options = options
    }

    // MARK: - Public

    public let options: [ParraChoiceQuestionOption]
}

public struct ParraShortTextQuestionBody: Codable, Equatable, Hashable {
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

    public let placeholder: String?
    public let minLength: Int
    public let maxLength: Int

    // MARK: - Internal

    enum CodingKeys: String, CodingKey {
        case placeholder
        case minLength
        case maxLength
    }
}

public struct ParraLongTextQuestionBody: Codable, Equatable, Hashable {
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

    public let placeholder: String?
    public let minLength: Int
    public let maxLength: Int

    // MARK: - Internal

    enum CodingKeys: String, CodingKey {
        case placeholder
        case minLength
        case maxLength
    }
}

public struct ParraBooleanQuestionOption: Codable, Equatable, Hashable,
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

public struct ParraBooleanQuestionBody: Codable, Equatable, Hashable {
    // MARK: - Lifecycle

    public init(
        options: [ParraBooleanQuestionOption]
    ) {
        self.options = options
    }

    // MARK: - Public

    public let options: [ParraBooleanQuestionOption]
}

public struct ParraStarQuestionBody: Codable, Equatable, Hashable {
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

public struct ParraRatingQuestionOption: Codable, Equatable, Hashable, Identifiable {
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

public struct ParraRatingQuestionBody: Codable, Equatable, Hashable {
    // MARK: - Lifecycle

    public init(
        options: [ParraRatingQuestionOption],
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

    public let options: [ParraRatingQuestionOption]
    public let leadingLabel: String?
    public let centerLabel: String?
    public let trailingLabel: String?

    // MARK: - Internal

    enum CodingKeys: String, CodingKey {
        case options
        case leadingLabel
        case centerLabel
        case trailingLabel
    }
}

public enum ParraQuestionData: Codable, Equatable, Hashable {
    case choiceQuestionBody(ParraChoiceQuestionBody)
    case checkboxQuestionBody(ParraCheckboxQuestionBody)
    case imageQuestionBody(ParraImageQuestionBody)
    case ratingQuestionBody(ParraRatingQuestionBody)
    case starQuestionBody(ParraStarQuestionBody)
    case shortTextQuestionBody(ParraShortTextQuestionBody)
    case longTextQuestionBody(ParraLongTextQuestionBody)
    case booleanQuestionBody(ParraBooleanQuestionBody)
}

public struct ParraQuestion: Codable, Equatable, Hashable, Identifiable {
    // MARK: - Lifecycle

    public init(
        id: String,
        createdAt: String,
        updatedAt: String,
        deletedAt: String?,
        tenantId: String,
        title: String,
        subtitle: String?,
        kind: ParraQuestionKind,
        data: ParraQuestionData,
        active: Bool?,
        expiresAt: String?,
        answerQuota: Int?,
        answer: ParraAnswer?
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
            ParraAnswer.self,
            forKey: .answer
        )
        self.kind = try container.decode(ParraQuestionKind.self, forKey: .kind)

        switch kind {
        case .checkbox:
            self.data = try .checkboxQuestionBody(container.decode(
                ParraCheckboxQuestionBody.self,
                forKey: .data
            ))
        case .image:
            self.data = try .imageQuestionBody(container.decode(
                ParraImageQuestionBody.self,
                forKey: .data
            ))
        case .radio:
            self.data = try .choiceQuestionBody(container.decode(
                ParraChoiceQuestionBody.self,
                forKey: .data
            ))
        case .star:
            self.data = try .starQuestionBody(container.decode(
                ParraStarQuestionBody.self,
                forKey: .data
            ))
        case .rating:
            self.data = try .ratingQuestionBody(container.decode(
                ParraRatingQuestionBody.self,
                forKey: .data
            ))
        case .textShort:
            self.data = try .shortTextQuestionBody(container.decode(
                ParraShortTextQuestionBody.self,
                forKey: .data
            ))
        case .textLong:
            self.data = try .longTextQuestionBody(container.decode(
                ParraLongTextQuestionBody.self,
                forKey: .data
            ))
        case .boolean:
            self.data = try .booleanQuestionBody(container.decode(
                ParraBooleanQuestionBody.self,
                forKey: .data
            ))
        }
    }

    // MARK: - Public

    public let id: String
    public let createdAt: String
    public let updatedAt: String
    public let deletedAt: String?
    public let tenantId: String
    public let title: String
    public let subtitle: String?
    public let kind: ParraQuestionKind
    public let data: ParraQuestionData
    public let active: Bool?
    public let expiresAt: String?
    public let answerQuota: Int?
    public let answer: ParraAnswer?

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

    // MARK: - Internal

    enum CodingKeys: String, CodingKey {
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
}

struct QuestionCollectionResponse: Codable, Equatable, Hashable {
    // MARK: - Lifecycle

    public init(
        page: Int,
        pageCount: Int,
        pageSize: Int,
        totalCount: Int,
        data: [ParraQuestion]
    ) {
        self.page = page
        self.pageCount = pageCount
        self.pageSize = pageSize
        self.totalCount = totalCount
        self.data = .init(data)
    }

    // MARK: - Public

    public let page: Int
    public let pageCount: Int
    public let pageSize: Int
    public let totalCount: Int
    public let data: PartiallyDecodableArray<ParraQuestion>

    // MARK: - Internal

    enum CodingKeys: String, CodingKey {
        case page
        case pageCount
        case pageSize
        case totalCount
        case data
    }
}
