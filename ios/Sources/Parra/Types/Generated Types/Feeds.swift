//
//  Feeds.swift
//  Parra
//
//  Created by Mick MacCallum on 9/25/24.
//

import Foundation

public enum ParraFeedItemType: String, Codable {
    case youtubeVideo = "youtube_video"
    case contentCard = "content_card"
}

public struct ParraYoutubeThumbnail: Codable, Equatable, Hashable {
    // MARK: - Lifecycle

    init(
        url: URL,
        width: CGFloat,
        height: CGFloat
    ) {
        self.url = url
        self.width = width
        self.height = height
    }

    // MARK: - Public

    public let url: URL
    public let width: CGFloat
    public let height: CGFloat
}

public struct ParraYoutubeThumbnails: Codable, Equatable, Hashable {
    // MARK: - Lifecycle

    init(
        default: ParraYoutubeThumbnail,
        medium: ParraYoutubeThumbnail?,
        high: ParraYoutubeThumbnail?,
        standard: ParraYoutubeThumbnail?,
        maxres: ParraYoutubeThumbnail?
    ) {
        self.default = `default`
        self.medium = medium
        self.high = high
        self.standard = standard
        self.maxres = maxres
    }

    // MARK: - Public

    public let `default`: ParraYoutubeThumbnail
    public let medium: ParraYoutubeThumbnail?
    public let high: ParraYoutubeThumbnail?
    public let standard: ParraYoutubeThumbnail?
    public let maxres: ParraYoutubeThumbnail?

    public var maxAvailable: ParraYoutubeThumbnail {
        return maxres ?? standard ?? high ?? medium ?? `default`
    }
}

public enum ParraFeedItemLiveBroadcastContent: String, ParraUnknownCaseCodable {
    case none
    case upcoming
    case live
    case unknown
}

public struct ParraFeedItemYoutubeVideoData: Codable, Equatable, Hashable {
    // MARK: - Lifecycle

    init(
        videoId: String,
        url: URL,
        title: String,
        channelTitle: String,
        channelId: String,
        description: String?,
        thumbnails: ParraYoutubeThumbnails,
        publishedAt: Date,
        liveBroadcastContent: ParraFeedItemLiveBroadcastContent?
    ) {
        self.videoId = videoId
        self.url = url
        self.title = title
        self.channelTitle = channelTitle
        self.channelId = channelId
        self.description = description
        self.thumbnails = thumbnails
        self.publishedAt = publishedAt
        self.liveBroadcastContent = liveBroadcastContent
    }

    // MARK: - Public

    public let videoId: String
    public let url: URL
    public let title: String
    public let channelTitle: String
    public let channelId: String
    public let description: String?
    public let thumbnails: ParraYoutubeThumbnails
    public let publishedAt: Date
    public let liveBroadcastContent: ParraFeedItemLiveBroadcastContent?

    // MARK: - Internal

    enum CodingKeys: String, CodingKey {
        case videoId
        case url
        case title
        case channelTitle
        case channelId
        case description
        case thumbnails
        case publishedAt
        case liveBroadcastContent
    }
}

public struct ParraContentCardAction: Codable, Equatable, Hashable {
    // MARK: - Lifecycle

    init(
        url: URL
    ) {
        self.url = url
    }

    // MARK: - Public

    public let url: URL
}

public struct ParraContentCardBackground: Codable, Equatable, Hashable {
    // MARK: - Lifecycle

    public init(
        image: ParraImageAssetStub?
    ) {
        self.image = image
    }

    // MARK: - Public

    public let image: ParraImageAssetStub?
}

public struct ParraContentCard: Codable, Equatable, Hashable, Identifiable {
    // MARK: - Lifecycle

    init(
        id: String,
        createdAt: Date,
        updatedAt: Date,
        deletedAt: Date?,
        backgroundImage: ParraContentCardBackground?,
        title: String?,
        description: String?,
        action: ParraContentCardAction?
    ) {
        self.id = id
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.deletedAt = deletedAt
        self.background = backgroundImage
        self.title = title
        self.description = description
        self.action = action
    }

    // MARK: - Public

    public let id: String
    public let createdAt: Date
    public let updatedAt: Date
    public let deletedAt: Date?
    public let background: ParraContentCardBackground?
    public let title: String?
    public let description: String?
    public let action: ParraContentCardAction?

    // MARK: - Internal

    enum CodingKeys: String, CodingKey {
        case id
        case createdAt
        case updatedAt
        case deletedAt
        case background
        case title
        case description
        case action
    }
}

public enum ParraFeedItemData: Codable, Equatable, Hashable {
    case feedItemYoutubeVideoData(ParraFeedItemYoutubeVideoData)
    case contentCard(ParraContentCard)

    // MARK: - Internal

    var name: String {
        switch self {
        case .feedItemYoutubeVideoData: return "youtube-video"
        case .contentCard: return "content-card"
        }
    }
}

public struct ParraFeedItem: Codable, Equatable, Hashable, Identifiable {
    // MARK: - Lifecycle

    init(
        id: String,
        createdAt: Date,
        updatedAt: Date,
        deletedAt: Date?,
        type: ParraFeedItemType,
        data: ParraFeedItemData
    ) {
        self.id = id
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.deletedAt = deletedAt
        self.type = type
        self.data = data
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(String.self, forKey: .id)
        self.createdAt = try container.decode(Date.self, forKey: .createdAt)
        self.updatedAt = try container.decode(Date.self, forKey: .updatedAt)
        self.deletedAt = try container.decodeIfPresent(Date.self, forKey: .deletedAt)
        self.type = try container.decode(ParraFeedItemType.self, forKey: .type)

        switch type {
        case .contentCard:
            self.data = try .contentCard(
                container.decode(ParraContentCard.self, forKey: .data)
            )
        case .youtubeVideo:
            self.data = try .feedItemYoutubeVideoData(
                container.decode(ParraFeedItemYoutubeVideoData.self, forKey: .data)
            )
        }
    }

    // MARK: - Public

    public let id: String
    public let createdAt: Date
    public let updatedAt: Date
    public let deletedAt: Date?
    public let type: ParraFeedItemType
    public let data: ParraFeedItemData

    // MARK: - Internal

    enum CodingKeys: String, CodingKey {
        case id
        case createdAt
        case updatedAt
        case deletedAt
        case type
        case data
    }
}

struct FeedItemCollectionResponse: Codable, Equatable, Hashable {
    // MARK: - Lifecycle

    init(
        page: Int,
        pageCount: Int,
        pageSize: Int,
        totalCount: Int,
        data: [ParraFeedItem]
    ) {
        self.page = page
        self.pageCount = pageCount
        self.pageSize = pageSize
        self.totalCount = totalCount
        self.data = .init(data)
    }

    // MARK: - Internal

    enum CodingKeys: String, CodingKey {
        case page
        case pageCount
        case pageSize
        case totalCount
        case data
    }

    let page: Int
    let pageCount: Int
    let pageSize: Int
    let totalCount: Int
    let data: PartiallyDecodableArray<ParraFeedItem>
}
