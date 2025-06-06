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
    case creatorUpdate = "creator_update"
    case rssItem = "rss_item"
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

public struct ParraYoutubeStatistics: Codable, Equatable, Hashable {
    let viewCount: Int?
    let likeCount: Int?
    let dislikeCount: Int?
    let favoriteCount: Int?
    let commentCount: Int?
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
        liveBroadcastContent: ParraFeedItemLiveBroadcastContent?,
        paywall: ParraAppPaywallConfiguration?,
        statistics: ParraYoutubeStatistics?
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
        self.paywall = paywall
        self.statistics = statistics
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
    public let paywall: ParraAppPaywallConfiguration?
    public let statistics: ParraYoutubeStatistics?

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
        case paywall
        case statistics
    }
}

public enum ParraContentCardActionType: String, Codable, Equatable, Hashable {
    case link
    case feedbackForm = "feedback_form"
}

public struct ParraContentCardAction: Codable, Equatable, Hashable {
    // MARK: - Lifecycle

    init(
        type: ParraContentCardActionType,
        url: URL?,
        form: ParraFeedbackFormDataStub?,
        confirmationMessage: String?
    ) {
        self.type = type
        self.form = form
        self.url = url
        self.confirmationMessage = confirmationMessage
    }

    // MARK: - Public

    public let type: ParraContentCardActionType
    public let url: URL?
    public let form: ParraFeedbackFormDataStub?
    public let confirmationMessage: String?

    // MARK: - Internal

    var symbol: String {
        switch type {
        case .link:
            "link"
        case .feedbackForm:
            "paperplane"
        }
    }
}

public struct ParraContentCardBackground: Codable, Equatable, Hashable {
    // MARK: - Lifecycle

    public init(
        image: ParraImageAsset?
    ) {
        self.image = image
    }

    // MARK: - Public

    public let image: ParraImageAsset?
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
        action: ParraContentCardAction?,
        badge: String?
    ) {
        self.id = id
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.deletedAt = deletedAt
        self.background = backgroundImage
        self.title = title
        self.description = description
        self.action = action
        self.badge = badge
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
    public let badge: String?

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
        case badge
    }
}

struct UrlMediaContext {
    let rssItem: ParraAppRssItemData
    let feedItem: ParraFeedItem
}

struct UrlMedia {
    // MARK: - Lifecycle

    init(
        id: String,
        title: String,
        description: String,
        imageUrl: URL?,
        link: URL?,
        author: String?,
        enclosure: ParraRssEnclosure,
        publishedAt: Date?,
        context: UrlMediaContext
    ) {
        self.id = id
        self.title = title
        self.description = description
        self.imageUrl = imageUrl
        self.link = link
        self.author = author
        self.enclosure = enclosure
        self.publishedAt = publishedAt
        self.context = context
    }

    // MARK: - Internal

    let id: String
    let title: String
    let description: String
    let imageUrl: URL?
    let link: URL?
    let author: String?
    let enclosure: ParraRssEnclosure
    let publishedAt: Date?
    let context: UrlMediaContext

    static func from(
        rssItem: ParraAppRssItemData,
        on feedItem: ParraFeedItem
    ) -> UrlMedia? {
        guard let enclosure = rssItem.enclosures?.elements.first else {
            return nil
        }

        return UrlMedia(
            id: rssItem.id,
            title: rssItem.title,
            description: rssItem.description,
            imageUrl: rssItem.imageUrl,
            link: rssItem.link,
            author: rssItem.author,
            enclosure: enclosure,
            publishedAt: rssItem.publishedAt,
            context: UrlMediaContext(
                rssItem: rssItem,
                feedItem: feedItem
            )
        )
    }
}

public struct ParraRssEnclosure: Codable, Equatable, Hashable {
    // MARK: - Lifecycle

    public init(
        url: String,
        type: String,
        length: Double?
    ) {
        self.url = url
        self.type = type
        self.length = length
    }

    // MARK: - Public

    public let url: String
    public let type: String
    // This is the file size in bytes, not the duration of the file.
    public let length: Double?
}

public struct ParraAppRssItemData: Codable, Equatable, Hashable, Identifiable {
    // MARK: - Lifecycle

    public init(
        id: String,
        title: String,
        description: String,
        imageUrl: URL?,
        link: URL?,
        author: String?,
        enclosures: [ParraRssEnclosure]?,
        publishedAt: Date?
    ) {
        self.id = id
        self.title = title
        self.description = description
        self.imageUrl = imageUrl
        self.link = link
        self.author = author
        self.enclosures = .init(enclosures)
        self.publishedAt = publishedAt
    }

    // MARK: - Public

    public let id: String
    public let title: String
    public let description: String
    public let imageUrl: URL?
    public let link: URL?
    public let author: String?
    public let enclosures: PartiallyDecodableArray<ParraRssEnclosure>?
    public let publishedAt: Date?
}

public enum ParraFeedItemData: Codable, Equatable, Hashable {
    case feedItemYoutubeVideo(ParraFeedItemYoutubeVideoData)
    case contentCard(ParraContentCard)
    case creatorUpdate(ParraCreatorUpdateAppStub)
    case appRssItem(ParraAppRssItemData)

    // MARK: - Internal

    var name: String {
        switch self {
        case .feedItemYoutubeVideo: return "youtube-video"
        case .contentCard: return "content-card"
        case .creatorUpdate: return "creator-update"
        case .appRssItem: return "rss-item"
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
        data: ParraFeedItemData,
        reactionOptions: [ParraReactionOptionGroup]?,
        reactions: [ParraReactionSummary]?,
        comments: ParraCommentSummary?
    ) {
        self.id = id
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.deletedAt = deletedAt
        self.type = type
        self.data = data
        self.reactionOptions = .init(reactionOptions)
        self.reactions = .init(reactions)
        self.comments = comments
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(String.self, forKey: .id)
        self.createdAt = try container.decode(Date.self, forKey: .createdAt)
        self.updatedAt = try container.decode(Date.self, forKey: .updatedAt)
        self.deletedAt = try container.decodeIfPresent(Date.self, forKey: .deletedAt)
        self.type = try container.decode(ParraFeedItemType.self, forKey: .type)
        self.comments = try container
            .decodeIfPresent(ParraCommentSummary.self, forKey: .comments)

        switch type {
        case .contentCard:
            self.data = try .contentCard(
                container.decode(
                    ParraContentCard.self,
                    forKey: .data
                )
            )
        case .youtubeVideo:
            self.data = try .feedItemYoutubeVideo(
                container.decode(
                    ParraFeedItemYoutubeVideoData.self,
                    forKey: .data
                )
            )
        case .creatorUpdate:
            self.data = try .creatorUpdate(
                container.decode(
                    ParraCreatorUpdateAppStub.self,
                    forKey: .data
                )
            )
        case .rssItem:
            self.data = try .appRssItem(
                container.decode(
                    ParraAppRssItemData.self,
                    forKey: .data
                )
            )
        }

        self.reactionOptions = try container
            .decodeIfPresent(
                PartiallyDecodableArray<ParraReactionOptionGroup>.self,
                forKey: .reactionOptions
            )

        self.reactions = try container
            .decodeIfPresent(
                PartiallyDecodableArray<ParraReactionSummary>.self,
                forKey: .reactions
            )
    }

    // MARK: - Public

    public let id: String
    public let createdAt: Date
    public let updatedAt: Date
    public let deletedAt: Date?
    public let type: ParraFeedItemType
    public let data: ParraFeedItemData
    public let reactionOptions: PartiallyDecodableArray<ParraReactionOptionGroup>?
    public let reactions: PartiallyDecodableArray<ParraReactionSummary>?
    public let comments: ParraCommentSummary?

    // MARK: - Internal

    enum CodingKeys: String, CodingKey {
        case id
        case createdAt
        case updatedAt
        case deletedAt
        case type
        case data
        case reactionOptions
        case reactions
        case comments
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

public struct ParraCreatorUpdateSenderStub: Codable, Equatable, Hashable, Identifiable {
    // MARK: - Lifecycle

    init(
        id: String,
        name: String,
        avatar: ParraImageAsset?,
        verified: Bool?
    ) {
        self.id = id
        self.name = name
        self.avatar = avatar
        self.verified = verified
    }

    // MARK: - Public

    public let id: String
    public let name: String
    public let avatar: ParraImageAsset?
    public let verified: Bool?
}

public struct ParraCreatorUpdateAttachmentStub: Codable, Equatable, Hashable,
    Identifiable
{
    // MARK: - Lifecycle

    init(
        id: String,
        image: ParraImageAsset?
    ) {
        self.id = id
        self.image = image
    }

    // MARK: - Public

    public let id: String
    public let image: ParraImageAsset?
}

public struct ParraCreatorUpdateAppStub: Codable, Equatable, Hashable, Identifiable {
    // MARK: - Lifecycle

    init(
        id: String,
        createdAt: Date,
        updatedAt: Date,
        deletedAt: Date?,
        title: String?,
        body: String?,
        sender: ParraCreatorUpdateSenderStub?,
        attachments: [ParraCreatorUpdateAttachmentStub]?,
        attachmentPaywall: ParraAppPaywallConfiguration?
    ) {
        self.id = id
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.deletedAt = deletedAt
        self.title = title
        self.body = body
        self.sender = sender
        self.attachments = .init(attachments ?? [])
        self.attachmentPaywall = attachmentPaywall
    }

    // MARK: - Public

    public let id: String
    public let createdAt: Date
    public let updatedAt: Date
    public let deletedAt: Date?
    public let title: String?
    public let body: String?
    public let sender: ParraCreatorUpdateSenderStub?
    public internal(set) var attachments: PartiallyDecodableArray<
        ParraCreatorUpdateAttachmentStub
    >?
    public let attachmentPaywall: ParraAppPaywallConfiguration?

    // MARK: - Internal

    enum CodingKeys: String, CodingKey {
        case id
        case createdAt
        case updatedAt
        case deletedAt
        case title
        case body
        case sender
        case attachments
        case attachmentPaywall
    }

    func withoutAttachments() -> Self {
        var updated = self
        updated.attachments = nil

        return updated
    }
}

public struct ParraAppPaywallConfiguration: Codable, Equatable, Hashable {
    public let entitlement: ParraEntitlement
    public let context: String?
}
