//
//  Feeds.swift
//  Parra
//
//  Created by Mick MacCallum on 9/25/24.
//

import Foundation

enum FeedItemType: String, Codable {
    case youtubeVideo = "youtube_video"
    case contentCard = "content_card"
}

struct YoutubeThumbnail: Codable, Equatable, Hashable {
    // MARK: - Lifecycle

    init(
        url: URL,
        width: Int,
        height: Int
    ) {
        self.url = url
        self.width = width
        self.height = height
    }

    // MARK: - Internal

    let url: URL
    let width: Int
    let height: Int
}

struct YoutubeThumbnails: Codable, Equatable, Hashable {
    // MARK: - Lifecycle

    init(
        default: YoutubeThumbnail,
        medium: YoutubeThumbnail,
        high: YoutubeThumbnail,
        standard: YoutubeThumbnail,
        maxres: YoutubeThumbnail
    ) {
        self.default = `default`
        self.medium = medium
        self.high = high
        self.standard = standard
        self.maxres = maxres
    }

    // MARK: - Internal

    let `default`: YoutubeThumbnail
    let medium: YoutubeThumbnail
    let high: YoutubeThumbnail
    let standard: YoutubeThumbnail
    let maxres: YoutubeThumbnail
}

enum FeedItemLiveBroadcastContent: String, Codable {
    case none
    case upcoming
    case live
}

struct FeedItemYoutubeVideoData: Codable, Equatable, Hashable {
    // MARK: - Lifecycle

    init(
        videoId: String,
        title: String,
        channelTitle: String,
        channelId: String,
        description: String?,
        thumbnails: YoutubeThumbnails,
        publishedAt: Date,
        liveBroadcastContent: FeedItemLiveBroadcastContent
    ) {
        self.videoId = videoId
        self.title = title
        self.channelTitle = channelTitle
        self.channelId = channelId
        self.description = description
        self.thumbnails = thumbnails
        self.publishedAt = publishedAt
        self.liveBroadcastContent = liveBroadcastContent
    }

    // MARK: - Internal

    enum CodingKeys: String, CodingKey {
        case videoId
        case title
        case channelTitle
        case channelId
        case description
        case thumbnails
        case publishedAt
        case liveBroadcastContent
    }

    let videoId: String
    let title: String
    let channelTitle: String
    let channelId: String
    let description: String?
    let thumbnails: YoutubeThumbnails
    let publishedAt: Date
    let liveBroadcastContent: FeedItemLiveBroadcastContent
}

struct ContentCardAction: Codable, Equatable, Hashable {
    // MARK: - Lifecycle

    init(
        url: URL
    ) {
        self.url = url
    }

    // MARK: - Internal

    let url: URL
}

struct ContentCardBackground: Codable, Equatable, Hashable {
    // MARK: - Lifecycle

    public init(
        image: ParraImageAssetStub?
    ) {
        self.image = image
    }

    // MARK: - Public

    public let image: ParraImageAssetStub?
}

struct ContentCard: Codable, Equatable, Hashable, Identifiable {
    // MARK: - Lifecycle

    init(
        id: String,
        createdAt: Date,
        updatedAt: Date,
        deletedAt: Date?,
        backgroundImage: ContentCardBackground?,
        title: String?,
        description: String?,
        action: ContentCardAction?
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

    let id: String
    let createdAt: Date
    let updatedAt: Date
    let deletedAt: Date?
    let background: ContentCardBackground?
    let title: String?
    let description: String?
    let action: ContentCardAction?
}

enum FeedItemData: Codable, Equatable, Hashable {
    case feedItemYoutubeVideoData(FeedItemYoutubeVideoData)
    case contentCard(ContentCard)
}

struct FeedItem: Codable, Equatable, Hashable, Identifiable {
    // MARK: - Lifecycle

    init(
        id: String,
        createdAt: Date,
        updatedAt: Date,
        deletedAt: Date?,
        type: FeedItemType,
        data: FeedItemData
    ) {
        self.id = id
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.deletedAt = deletedAt
        self.type = type
        self.data = data
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(String.self, forKey: .id)
        self.createdAt = try container.decode(Date.self, forKey: .createdAt)
        self.updatedAt = try container.decode(Date.self, forKey: .updatedAt)
        self.deletedAt = try container.decodeIfPresent(Date.self, forKey: .deletedAt)
        self.type = try container.decode(FeedItemType.self, forKey: .type)

        switch type {
        case .contentCard:
            self.data = try .contentCard(
                container.decode(ContentCard.self, forKey: .data)
            )
        case .youtubeVideo:
            self.data = try .feedItemYoutubeVideoData(
                container.decode(FeedItemYoutubeVideoData.self, forKey: .data)
            )
        }
    }

    // MARK: - Internal

    enum CodingKeys: String, CodingKey {
        case id
        case createdAt
        case updatedAt
        case deletedAt
        case type
        case data
    }

    let id: String
    let createdAt: Date
    let updatedAt: Date
    let deletedAt: Date?
    let type: FeedItemType
    let data: FeedItemData
}

struct FeedItemCollectionResponse: Codable, Equatable, Hashable {
    // MARK: - Lifecycle

    init(
        page: Int,
        pageCount: Int,
        pageSize: Int,
        totalCount: Int,
        data: [FeedItem]
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
    let data: PartiallyDecodableArray<FeedItem>
}
