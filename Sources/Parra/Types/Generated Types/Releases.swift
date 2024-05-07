//
//  Releases.swift
//  Parra
//
//  Created by Mick MacCallum on 3/29/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import Foundation

public struct Size: Codable, Equatable, Hashable {
    // MARK: - Lifecycle

    public init(
        width: Int,
        height: Int
    ) {
        self.width = width
        self.height = height
    }

    // MARK: - Public

    public let width: Int
    public let height: Int
}

public enum TicketType: String, Codable, Equatable, CaseIterable {
    case bug
    case feature
    case improvement
}

public enum TicketStatus: String, Codable, Equatable, CaseIterable {
    case open
    case planning
    case inProgress = "in_progress"
    case done
    case live
    case closed
    case archived
}

public enum TicketDisplayStatus: String, Codable, Equatable, CaseIterable {
    case pending
    case inProgress = "in_progress"
    case live
    case rejected
}

public struct UserTicket: Codable, Equatable, Hashable, Identifiable {
    // MARK: - Lifecycle

    public init(
        id: String,
        ticketNumber: String,
        createdAt: Date,
        updatedAt: Date,
        deletedAt: Date?,
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
        self.ticketNumber = ticketNumber
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
        case ticketNumber
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
    public let ticketNumber: String
    public let createdAt: Date
    public let updatedAt: Date
    public let deletedAt: Date?
    public let title: String
    public let type: TicketType
    public let description: String?
    public let status: TicketStatus
    public let displayStatus: TicketDisplayStatus
    public let displayStatusBadgeTitle: String
    public internal(set) var voteCount: Int
    /// Whether voting is enabled on an individual ticket. Behavior is to hide
    /// the vote button and vote count if this is set. Could be set per ticket
    /// or globally in dashboard config but will resolve to per ticket field
    /// being set.
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

public struct RoadmapConfigurationTab: Codable, Equatable, Hashable,
    Identifiable
{
    // MARK: - Lifecycle

    public init(
        id: String,
        title: String,
        key: String,
        description: String?
    ) {
        self.id = id
        self.title = title
        self.key = key
        self.description = description
    }

    // MARK: - Public

    public let id: String
    public let title: String

    // The filter param to use to fetch tickets for this tab from the paginate
    // endpoint.
    public let key: String
    public let description: String?
}

public struct AppRoadmapConfiguration: Codable, Equatable, Hashable {
    // MARK: - Lifecycle

    public init(
        form: FeedbackFormDataStub?,
        tabs: [RoadmapConfigurationTab]
    ) {
        self.form = form
        self.tabs = tabs
    }

    // MARK: - Public

    public let form: FeedbackFormDataStub?
    public let tabs: [RoadmapConfigurationTab]
}

public enum TicketPriority: String, Codable, CaseIterable {
    case low
    case medium
    case high
    case urgent
}

public enum TicketIconType: String, Codable {
    case emoji
}

public struct TicketIcon: Codable, Equatable, Hashable {
    // MARK: - Lifecycle

    public init(
        type: TicketIconType,
        value: String
    ) {
        self.type = type
        self.value = value
    }

    // MARK: - Public

    public let type: TicketIconType
    public let value: String
}

public struct TicketStub: Codable, Equatable, Hashable, Identifiable {
    // MARK: - Lifecycle

    public init(
        id: String,
        createdAt: Date,
        updatedAt: Date,
        deletedAt: Date?,
        title: String,
        shortTitle: String?,
        type: TicketType,
        status: TicketStatus,
        priority: TicketPriority?,
        description: String?,
        votingEnabled: Bool,
        isPublic: Bool,
        userNoteId: String?,
        estimatedStartDate: Date?,
        estimatedCompletionDate: Date?,
        icon: TicketIcon?,
        ticketNumber: String,
        tenantId: String,
        voteCount: Int,
        releasedAt: String?
    ) {
        self.id = id
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.deletedAt = deletedAt
        self.title = title
        self.shortTitle = shortTitle
        self.type = type
        self.status = status
        self.priority = priority
        self.description = description
        self.votingEnabled = votingEnabled
        self.isPublic = isPublic
        self.userNoteId = userNoteId
        self.estimatedStartDate = estimatedStartDate
        self.estimatedCompletionDate = estimatedCompletionDate
        self.icon = icon
        self.ticketNumber = ticketNumber
        self.tenantId = tenantId
        self.voteCount = voteCount
        self.releasedAt = releasedAt
    }

    // MARK: - Public

    public enum CodingKeys: String, CodingKey {
        case id
        case createdAt
        case updatedAt
        case deletedAt
        case title
        case shortTitle
        case type
        case status
        case priority
        case description
        case votingEnabled
        case isPublic
        case userNoteId
        case estimatedStartDate
        case estimatedCompletionDate
        case icon
        case ticketNumber
        case tenantId
        case voteCount
        case releasedAt
    }

    public let id: String
    public let createdAt: Date
    public let updatedAt: Date
    public let deletedAt: Date?
    public let title: String
    public let shortTitle: String?
    public let type: TicketType
    public let status: TicketStatus
    public let priority: TicketPriority?
    public let description: String?
    public let votingEnabled: Bool
    public let isPublic: Bool
    public let userNoteId: String?
    public let estimatedStartDate: Date?
    public let estimatedCompletionDate: Date?
    public let icon: TicketIcon?
    public let ticketNumber: String
    public let tenantId: String
    public let voteCount: Int
    public let releasedAt: String?
}

public struct Ticket: Codable, Equatable, Hashable, Identifiable {
    // MARK: - Lifecycle

    public init(
        id: String,
        createdAt: Date,
        updatedAt: Date,
        deletedAt: Date?,
        title: String,
        shortTitle: String?,
        type: TicketType,
        status: TicketStatus,
        priority: TicketPriority?,
        description: String?,
        votingEnabled: Bool,
        isPublic: Bool,
        userNoteId: String?,
        estimatedStartDate: Date?,
        estimatedCompletionDate: Date?,
        ticketNumber: String,
        tenantId: String,
        voteCount: Int,
        releasedAt: String?,
        release: ReleaseStub
    ) {
        self.id = id
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.deletedAt = deletedAt
        self.title = title
        self.shortTitle = shortTitle
        self.type = type
        self.status = status
        self.priority = priority
        self.description = description
        self.votingEnabled = votingEnabled
        self.isPublic = isPublic
        self.userNoteId = userNoteId
        self.estimatedStartDate = estimatedStartDate
        self.estimatedCompletionDate = estimatedCompletionDate
        self.ticketNumber = ticketNumber
        self.tenantId = tenantId
        self.voteCount = voteCount
        self.releasedAt = releasedAt
        self.release = release
    }

    // MARK: - Public

    public enum CodingKeys: String, CodingKey {
        case id
        case createdAt
        case updatedAt
        case deletedAt
        case title
        case shortTitle
        case type
        case status
        case priority
        case description
        case votingEnabled
        case isPublic
        case userNoteId
        case estimatedStartDate
        case estimatedCompletionDate
        case ticketNumber
        case tenantId
        case voteCount
        case releasedAt
        case release
    }

    public let id: String
    public let createdAt: Date
    public let updatedAt: Date
    public let deletedAt: Date?
    public let title: String
    public let shortTitle: String?
    public let type: TicketType
    public let status: TicketStatus
    public let priority: TicketPriority?
    public let description: String?
    public let votingEnabled: Bool
    public let isPublic: Bool
    public let userNoteId: String?
    public let estimatedStartDate: Date?
    public let estimatedCompletionDate: Date?
    public let ticketNumber: String
    public let tenantId: String
    public let voteCount: Int
    public let releasedAt: String?
    public let release: ReleaseStub
}

public struct AppReleaseItem: Codable, Equatable, Hashable, Identifiable {
    // MARK: - Lifecycle

    public init(
        id: String,
        createdAt: Date,
        updatedAt: Date,
        deletedAt: Date?,
        releaseId: String,
        ticketId: String,
        ticket: TicketStub
    ) {
        self.id = id
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.deletedAt = deletedAt
        self.releaseId = releaseId
        self.ticketId = ticketId
        self.ticket = ticket
    }

    // MARK: - Public

    public enum CodingKeys: String, CodingKey {
        case id
        case createdAt
        case updatedAt
        case deletedAt
        case releaseId
        case ticketId
        case ticket
    }

    public let id: String
    public let createdAt: Date
    public let updatedAt: Date
    public let deletedAt: Date?
    public let releaseId: String
    public let ticketId: String
    public let ticket: TicketStub
}

public struct AppReleaseSection: Codable, Identifiable, Equatable, Hashable {
    // MARK: - Lifecycle

    public init(
        id: String,
        title: String,
        items: [AppReleaseItem]
    ) {
        self.id = id
        self.title = title
        self.items = items
    }

    // MARK: - Public

    public let id: String
    public let title: String
    public let items: [AppReleaseItem]
}

public struct AppRelease: Codable, Equatable, Hashable, Identifiable {
    // MARK: - Lifecycle

    public init(
        id: String,
        createdAt: Date,
        updatedAt: Date,
        deletedAt: Date?,
        name: String,
        version: String,
        description: String?,
        type: ReleaseType,
        tenantId: String,
        releaseNumber: Int,
        status: ReleaseStatus,
        sections: [AppReleaseSection],
        header: ReleaseHeader?
    ) {
        self.id = id
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.deletedAt = deletedAt
        self.name = name
        self.version = version
        self.description = description
        self.type = type
        self.tenantId = tenantId
        self.releaseNumber = releaseNumber
        self.status = status
        self.sections = sections
        self.header = header
    }

    // MARK: - Public

    public enum CodingKeys: String, CodingKey {
        case id
        case createdAt
        case updatedAt
        case deletedAt
        case name
        case version
        case description
        case type
        case tenantId
        case releaseNumber
        case status
        case sections
        case header
    }

    public let id: String
    public let createdAt: Date
    public let updatedAt: Date
    public let deletedAt: Date?
    public let name: String
    public let version: String
    public let description: String?
    public let type: ReleaseType
    public let tenantId: String
    public let releaseNumber: Int
    public let status: ReleaseStatus
    public let sections: [AppReleaseSection]
    public let header: ReleaseHeader?
}

public struct ReleaseHeader: Codable, Equatable, Hashable, Identifiable {
    // MARK: - Lifecycle

    public init(
        id: String,
        size: Size,
        url: String
    ) {
        self.id = id
        self.size = size
        self.url = url
    }

    // MARK: - Public

    public let id: String
    public let size: Size
    public let url: String
}

public enum ReleaseStatus: String, Codable, CaseIterable {
    case pending
    case scheduled
    case released
}

public enum ReleaseType: String, Codable, CaseIterable {
    case major
    case minor
    case patch
    case launch
}

public struct ReleaseStub: Codable, Equatable, Hashable, Identifiable {
    // MARK: - Lifecycle

    public init(
        id: String,
        createdAt: Date,
        updatedAt: Date,
        deletedAt: Date?,
        name: String,
        version: String,
        description: String?,
        type: ReleaseType,
        tenantId: String,
        releaseNumber: Int,
        status: ReleaseStatus
    ) {
        self.id = id
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.deletedAt = deletedAt
        self.name = name
        self.version = version
        self.description = description
        self.type = type
        self.tenantId = tenantId
        self.releaseNumber = releaseNumber
        self.status = status
    }

    // MARK: - Public

    public enum CodingKeys: String, CodingKey {
        case id
        case createdAt
        case updatedAt
        case deletedAt
        case name
        case version
        case description
        case type
        case tenantId
        case releaseNumber
        case status
    }

    public let id: String
    public let createdAt: Date
    public let updatedAt: Date
    public let deletedAt: Date?
    public let name: String
    public let version: String
    public let description: String?
    public let type: ReleaseType
    public let tenantId: String
    public let releaseNumber: Int
    public let status: ReleaseStatus
}

public struct AppReleaseStub: Codable, Equatable, Hashable, Identifiable {
    // MARK: - Lifecycle

    public init(
        id: String,
        createdAt: Date,
        updatedAt: Date,
        deletedAt: Date?,
        name: String,
        version: String,
        description: String?,
        type: ReleaseType,
        tenantId: String,
        releaseNumber: Int,
        status: ReleaseStatus,
        header: ReleaseHeader?
    ) {
        self.id = id
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.deletedAt = deletedAt
        self.name = name
        self.version = version
        self.description = description
        self.type = type
        self.tenantId = tenantId
        self.releaseNumber = releaseNumber
        self.status = status
        self.header = header
    }

    // MARK: - Public

    public enum CodingKeys: String, CodingKey {
        case id
        case createdAt
        case updatedAt
        case deletedAt
        case name
        case version
        case description
        case type
        case tenantId
        case releaseNumber
        case status
        case header
    }

    public let id: String
    public let createdAt: Date
    public let updatedAt: Date
    public let deletedAt: Date?
    public let name: String
    public let version: String
    public let description: String?
    public let type: ReleaseType
    public let tenantId: String
    public let releaseNumber: Int
    public let status: ReleaseStatus
    public let header: ReleaseHeader?
}

public struct AppReleaseCollectionResponse: Codable, Equatable, Hashable {
    // MARK: - Lifecycle

    public init(
        page: Int,
        pageCount: Int,
        pageSize: Int,
        totalCount: Int,
        data: [AppReleaseStub]
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
    public let data: [AppReleaseStub]
}

public struct AppReleaseConfiguration: Codable, Equatable, Hashable {
    // MARK: - Lifecycle

    public init(
        title: String,
        hasOtherReleases: Bool
    ) {
        self.title = title
        self.hasOtherReleases = hasOtherReleases
    }

    // MARK: - Public

    public enum CodingKeys: String, CodingKey {
        case title
        case hasOtherReleases
    }

    /// Contextual title for full screen presentation "What's new" for example.
    /// When this is present, the name of the release will be displayed as the
    /// subtitle in the release details screen.
    public let title: String

    /// Indicates that releases other than the current one are present. Can be
    /// used to determine whether or not to show a button to push to a changelog
    public let hasOtherReleases: Bool
}

public struct NewInstalledVersionInfo: Codable, Equatable, Hashable {
    // MARK: - Lifecycle

    public init(
        configuration: AppReleaseConfiguration,
        release: AppRelease
    ) {
        self.configuration = configuration
        self.release = release
    }

    // MARK: - Public

    public let configuration: AppReleaseConfiguration
    public let release: AppRelease
}

public struct AppInfo: Codable, Equatable, Hashable {
    // MARK: - Lifecycle

    public init(
        versionToken: String,
        newInstalledVersionInfo: NewInstalledVersionInfo?,
        legal: LegalInfo
    ) {
        self.versionToken = versionToken
        self.newInstalledVersionInfo = newInstalledVersionInfo
        self.legal = legal
    }

    // MARK: - Public

    public enum CodingKeys: String, CodingKey {
        case versionToken
        case newInstalledVersionInfo
        case legal
    }

    public let versionToken: String
    public let newInstalledVersionInfo: NewInstalledVersionInfo?
    public let legal: LegalInfo
}

public struct LegalInfo: Codable, Equatable, Hashable {
    // MARK: - Lifecycle

    public init(privacyPolicy: LegalDocument?) {
        self.privacyPolicy = privacyPolicy
    }

    // MARK: - Public

    public let privacyPolicy: LegalDocument?

    // MARK: - Internal

    enum CodingKeys: CodingKey {
        case privacyPolicy
    }

    static let empty = LegalInfo(privacyPolicy: nil)
}

public struct LegalDocument: Codable, Equatable, Hashable, Identifiable {
    // MARK: - Lifecycle

    public init(
        id: String,
        type: String,
        title: String,
        url: URL
    ) {
        self.id = id
        self.type = type
        self.title = title
        self.url = url
    }

    // MARK: - Public

    public let id: String
    public let type: String
    public let title: String
    public let url: URL

    // MARK: - Internal

    enum CodingKeys: CodingKey {
        case id
        case type
        case title
        case url
    }
}
