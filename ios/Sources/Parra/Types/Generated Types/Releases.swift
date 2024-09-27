//
//  Releases.swift
//  Parra
//
//  Created by Mick MacCallum on 3/29/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import Foundation

public struct ParraSize: Codable, Equatable, Hashable {
    // MARK: - Lifecycle

    public init(
        width: CGFloat,
        height: CGFloat
    ) {
        self.width = width
        self.height = height
    }

    // MARK: - Public

    public let width: CGFloat
    public let height: CGFloat

    // MARK: - Internal

    var toCGSize: CGSize {
        return CGSize(width: width, height: height)
    }
}

public enum ParraTicketType: String, Codable, Equatable, CaseIterable {
    case bug
    case feature
    case improvement
    case task
}

public enum ParraTicketStatus: String, Codable, Equatable, CaseIterable {
    case open
    case planning
    case inProgress =
        "in_progress" // Keep the underscore. Enums decode differently!
    case done
    case live
    case closed
    case archived
}

public enum ParraTicketDisplayStatus: String, Codable, Equatable, CaseIterable {
    case pending
    case inProgress =
        "in_progress" // Keep the underscore. Enums decode differently!
    case live
    case rejected
}

public struct ParraUserTicket: Codable, Equatable, Hashable, Identifiable {
    // MARK: - Lifecycle

    public init(
        id: String,
        ticketNumber: String,
        createdAt: Date,
        updatedAt: Date,
        deletedAt: Date?,
        title: String,
        type: ParraTicketType,
        description: String?,
        status: ParraTicketStatus,
        displayStatus: ParraTicketDisplayStatus,
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
        self.type = .init(type)
        self.description = description
        self.status = .init(status)
        self.displayStatus = .init(displayStatus)
        self.displayStatusBadgeTitle = displayStatusBadgeTitle
        self.voteCount = voteCount
        self.votingEnabled = votingEnabled
        self.voted = voted
    }

    // MARK: - Public

    public let id: String
    public let ticketNumber: String
    public let createdAt: Date
    public let updatedAt: Date
    public let deletedAt: Date?
    public let title: String
    public let type: NilFailureDecodable<ParraTicketType>
    public let description: String?
    public let status: NilFailureDecodable<ParraTicketStatus>
    public let displayStatus: NilFailureDecodable<ParraTicketDisplayStatus>
    public let displayStatusBadgeTitle: String
    public internal(set) var voteCount: Int
    /// Whether voting is enabled on an individual ticket. Behavior is to hide
    /// the vote button and vote count if this is set. Could be set per ticket
    /// or globally in dashboard config but will resolve to per ticket field
    /// being set.
    public let votingEnabled: Bool
    public let voted: Bool

    // MARK: - Internal

    enum CodingKeys: String, CodingKey {
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
}

struct CollectionResponse: Codable, Equatable, Hashable {
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

    public let page: Int
    public let pageCount: Int
    public let pageSize: Int
    public let totalCount: Int

    // MARK: - Internal

    enum CodingKeys: String, CodingKey {
        case page
        case pageCount
        case pageSize
        case totalCount
    }
}

public struct ParraUserTicketCollectionResponse: Codable, Equatable, Hashable {
    // MARK: - Lifecycle

    public init(
        page: Int,
        pageCount: Int,
        pageSize: Int,
        totalCount: Int,
        data: [ParraUserTicket]
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
    public let data: PartiallyDecodableArray<ParraUserTicket>

    // MARK: - Internal

    enum CodingKeys: String, CodingKey {
        case page
        case pageCount
        case pageSize
        case totalCount
        case data
    }
}

public struct ParraRoadmapConfigurationTab: Codable, Equatable, Hashable,
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

public struct ParraAppRoadmapConfiguration: Codable, Equatable, Hashable {
    // MARK: - Lifecycle

    public init(
        form: ParraFeedbackFormDataStub?,
        tabs: [ParraRoadmapConfigurationTab]
    ) {
        self.form = form
        self.tabs = .init(tabs)
    }

    // MARK: - Public

    public let form: ParraFeedbackFormDataStub?
    public let tabs: PartiallyDecodableArray<ParraRoadmapConfigurationTab>
}

public enum ParraTicketPriority: String, Codable, CaseIterable {
    case low
    case medium
    case high
    case urgent
}

public enum ParraTicketIconType: String, Codable {
    case emoji
}

public struct ParraTicketIcon: Codable, Equatable, Hashable {
    // MARK: - Lifecycle

    public init(
        type: ParraTicketIconType,
        value: String
    ) {
        self.type = type
        self.value = value
    }

    // MARK: - Public

    public let type: ParraTicketIconType
    public let value: String
}

public struct ParraTicketStub: Codable, Equatable, Hashable, Identifiable {
    // MARK: - Lifecycle

    public init(
        id: String,
        createdAt: Date,
        updatedAt: Date,
        deletedAt: Date?,
        title: String,
        shortTitle: String?,
        type: ParraTicketType,
        status: ParraTicketStatus,
        priority: ParraTicketPriority?,
        description: String?,
        votingEnabled: Bool,
        isPublic: Bool,
        userNoteId: String?,
        estimatedStartDate: Date?,
        estimatedCompletionDate: Date?,
        icon: ParraTicketIcon?,
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
        self.type = .init(type)
        self.status = .init(status)
        self.priority = .init(priority)
        self.description = description
        self.votingEnabled = votingEnabled
        self.isPublic = isPublic
        self.userNoteId = userNoteId
        self.estimatedStartDate = estimatedStartDate
        self.estimatedCompletionDate = estimatedCompletionDate
        self.icon = .init(icon)
        self.ticketNumber = ticketNumber
        self.tenantId = tenantId
        self.voteCount = voteCount
        self.releasedAt = releasedAt
    }

    // MARK: - Public

    public let id: String
    public let createdAt: Date
    public let updatedAt: Date
    public let deletedAt: Date?
    public let title: String
    public let shortTitle: String?
    public let type: NilFailureDecodable<ParraTicketType>
    public let status: NilFailureDecodable<ParraTicketStatus>
    public let priority: NilFailureDecodable<ParraTicketPriority>?
    public let description: String?
    public let votingEnabled: Bool
    public let isPublic: Bool
    public let userNoteId: String?
    public let estimatedStartDate: Date?
    public let estimatedCompletionDate: Date?
    public let icon: NilFailureDecodable<ParraTicketIcon>?
    public let ticketNumber: String
    public let tenantId: String
    public let voteCount: Int
    public let releasedAt: String?

    // MARK: - Internal

    enum CodingKeys: String, CodingKey {
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
}

struct Ticket: Codable, Equatable, Hashable, Identifiable {
    // MARK: - Lifecycle

    public init(
        id: String,
        createdAt: Date,
        updatedAt: Date,
        deletedAt: Date?,
        title: String,
        shortTitle: String?,
        type: ParraTicketType,
        status: ParraTicketStatus,
        priority: ParraTicketPriority?,
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
        self.type = .init(type)
        self.status = .init(status)
        self.priority = .init(priority)
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

    public let id: String
    public let createdAt: Date
    public let updatedAt: Date
    public let deletedAt: Date?
    public let title: String
    public let shortTitle: String?
    public let type: NilFailureDecodable<ParraTicketType>
    public let status: NilFailureDecodable<ParraTicketStatus>
    public let priority: NilFailureDecodable<ParraTicketPriority>?
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

    // MARK: - Internal

    enum CodingKeys: String, CodingKey {
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
}

public struct ParraAppReleaseItem: Codable, Equatable, Hashable, Identifiable {
    // MARK: - Lifecycle

    public init(
        id: String,
        createdAt: Date,
        updatedAt: Date,
        deletedAt: Date?,
        releaseId: String,
        ticketId: String,
        ticket: ParraTicketStub
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

    public let id: String
    public let createdAt: Date
    public let updatedAt: Date
    public let deletedAt: Date?
    public let releaseId: String
    public let ticketId: String
    public let ticket: ParraTicketStub

    // MARK: - Internal

    enum CodingKeys: String, CodingKey {
        case id
        case createdAt
        case updatedAt
        case deletedAt
        case releaseId
        case ticketId
        case ticket
    }
}

public struct ParraAppReleaseSection: Codable, Identifiable, Equatable, Hashable {
    // MARK: - Lifecycle

    public init(
        id: String,
        title: String,
        items: [ParraAppReleaseItem]
    ) {
        self.id = id
        self.title = title
        self.items = .init(items)
    }

    // MARK: - Public

    public let id: String
    public let title: String
    public let items: PartiallyDecodableArray<ParraAppReleaseItem>
}

public struct ParraAppRelease: Codable, Equatable, Hashable, Identifiable {
    // MARK: - Lifecycle

    public init(
        id: String,
        createdAt: Date,
        updatedAt: Date,
        deletedAt: Date?,
        name: String,
        version: String,
        description: String?,
        type: ParraReleaseType?,
        tenantId: String,
        releaseNumber: Int,
        status: ParraReleaseStatus?,
        sections: [ParraAppReleaseSection],
        header: ParraReleaseHeader?
    ) {
        self.id = id
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.deletedAt = deletedAt
        self.name = name
        self.version = version
        self.description = description
        self.type = .init(type)
        self.tenantId = tenantId
        self.releaseNumber = releaseNumber
        self.status = .init(status)
        self.sections = .init(sections)
        self.header = header
    }

    // MARK: - Public

    public let id: String
    public let createdAt: Date
    public let updatedAt: Date
    public let deletedAt: Date?
    public let name: String
    public let version: String
    public let description: String?
    public let type: NilFailureDecodable<ParraReleaseType>
    public let tenantId: String
    public let releaseNumber: Int
    public let status: NilFailureDecodable<ParraReleaseStatus>
    public let sections: PartiallyDecodableArray<ParraAppReleaseSection>
    public let header: ParraReleaseHeader?

    // MARK: - Internal

    enum CodingKeys: String, CodingKey {
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
}

public struct ParraReleaseHeader: Codable, Equatable, Hashable, Identifiable {
    // MARK: - Lifecycle

    public init(
        id: String,
        size: ParraSize,
        url: String
    ) {
        self.id = id
        self.size = size
        self.url = url
    }

    // MARK: - Public

    public let id: String
    public let size: ParraSize
    public let url: String
}

public enum ParraReleaseStatus: String, Codable, CaseIterable {
    case pending
    case scheduled
    case released
}

public enum ParraReleaseType: String, Codable, CaseIterable {
    case major
    case minor
    case patch
    case launch
}

struct ReleaseStub: Codable, Equatable, Hashable, Identifiable {
    // MARK: - Lifecycle

    public init(
        id: String,
        createdAt: Date,
        updatedAt: Date,
        deletedAt: Date?,
        name: String,
        version: String,
        description: String?,
        type: ParraReleaseType,
        tenantId: String,
        releaseNumber: Int,
        status: ParraReleaseStatus
    ) {
        self.id = id
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.deletedAt = deletedAt
        self.name = name
        self.version = version
        self.description = description
        self.type = .init(type)
        self.tenantId = tenantId
        self.releaseNumber = releaseNumber
        self.status = .init(status)
    }

    // MARK: - Public

    public let id: String
    public let createdAt: Date
    public let updatedAt: Date
    public let deletedAt: Date?
    public let name: String
    public let version: String
    public let description: String?
    public let type: NilFailureDecodable<ParraReleaseType>
    public let tenantId: String
    public let releaseNumber: Int
    public let status: NilFailureDecodable<ParraReleaseStatus>

    // MARK: - Internal

    enum CodingKeys: String, CodingKey {
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
}

struct AppReleaseStub: Codable, Equatable, Hashable, Identifiable {
    // MARK: - Lifecycle

    public init(
        id: String,
        createdAt: Date,
        updatedAt: Date,
        deletedAt: Date?,
        name: String,
        version: String,
        description: String?,
        type: ParraReleaseType,
        tenantId: String,
        releaseNumber: Int,
        status: ParraReleaseStatus,
        header: ParraReleaseHeader?
    ) {
        self.id = id
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.deletedAt = deletedAt
        self.name = name
        self.version = version
        self.description = description
        self.type = .init(type)
        self.tenantId = tenantId
        self.releaseNumber = releaseNumber
        self.status = .init(status)
        self.header = header
    }

    // MARK: - Public

    public let id: String
    public let createdAt: Date
    public let updatedAt: Date
    public let deletedAt: Date?
    public let name: String
    public let version: String
    public let description: String?
    public let type: NilFailureDecodable<ParraReleaseType>
    public let tenantId: String
    public let releaseNumber: Int
    public let status: NilFailureDecodable<ParraReleaseStatus>
    public let header: ParraReleaseHeader?

    // MARK: - Internal

    enum CodingKeys: String, CodingKey {
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
}

struct AppReleaseCollectionResponse: Codable, Equatable, Hashable {
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
        self.data = .init(data)
    }

    // MARK: - Public

    public let page: Int
    public let pageCount: Int
    public let pageSize: Int
    public let totalCount: Int
    public let data: PartiallyDecodableArray<AppReleaseStub>

    // MARK: - Internal

    enum CodingKeys: String, CodingKey {
        case page
        case pageCount
        case pageSize
        case totalCount
        case data
    }
}

public struct ParraAppReleaseConfiguration: Codable, Equatable, Hashable {
    // MARK: - Lifecycle

    public init(
        title: String,
        hasOtherReleases: Bool
    ) {
        self.title = title
        self.hasOtherReleases = hasOtherReleases
    }

    // MARK: - Public

    /// Contextual title for full screen presentation "What's new" for example.
    /// When this is present, the name of the release will be displayed as the
    /// subtitle in the release details screen.
    public let title: String

    /// Indicates that releases other than the current one are present. Can be
    /// used to determine whether or not to show a button to push to a changelog
    public let hasOtherReleases: Bool

    // MARK: - Internal

    enum CodingKeys: String, CodingKey {
        case title
        case hasOtherReleases
    }
}

public struct ParraNewInstalledVersionInfo: Codable, Equatable, Hashable {
    // MARK: - Lifecycle

    public init(
        configuration: ParraAppReleaseConfiguration,
        release: ParraAppRelease
    ) {
        self.configuration = configuration
        self.release = release
    }

    // MARK: - Public

    public let configuration: ParraAppReleaseConfiguration
    public let release: ParraAppRelease
}

public enum ParraDomainType: String, Codable {
    case managed
    case external
    case subdomain
    case fallback
}

public enum ParraDomainStatus: String, Codable {
    case setup
    case pending
    case error
    case disabled
    case deleted
}

public struct ParraExternalDomainData: Codable, Equatable, Hashable {
    // MARK: - Lifecycle

    public init(
        status: ParraDomainStatus,
        name: String,
        disabled: Bool
    ) {
        self.status = .init(status)
        self.name = name
        self.disabled = disabled
    }

    // MARK: - Public

    public let status: NilFailureDecodable<ParraDomainStatus>
    public let name: String
    public let disabled: Bool
}

public enum ParraDomainData: Codable, Equatable, Hashable {
    case externalDomainData(ParraExternalDomainData)
}

public struct ParraDomain: Codable, Equatable, Hashable, Identifiable {
    // MARK: - Lifecycle

    public init(
        id: String,
        type: ParraDomainType,
        name: String,
        title: String,
        host: String,
        url: URL,
        data: ParraDomainData?
    ) {
        self.id = id
        self.type = .init(type)
        self.name = name
        self.title = title
        self.host = host
        self.url = url
        self.data = data
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(String.self, forKey: .id)
        self.type = try container.decode(
            NilFailureDecodable<ParraDomainType>.self,
            forKey: .type
        )
        self.name = try container.decode(String.self, forKey: .name)
        self.title = try container.decode(String.self, forKey: .title)
        self.host = try container.decode(String.self, forKey: .host)
        self.url = try container.decode(URL.self, forKey: .url)

        if let type = type.value {
            switch type {
            case .external:
                self.data = try .externalDomainData(container.decode(
                    ParraExternalDomainData.self,
                    forKey: .data
                ))
            case .fallback:
                self.data = nil
            case .managed:
                self.data = nil
            case .subdomain:
                self.data = nil
            }
        } else {
            self.data = nil
        }
    }

    // MARK: - Public

    public let id: String
    public let type: NilFailureDecodable<ParraDomainType>
    public let name: String
    public let title: String
    public let host: String
    public let url: URL
    public let data: ParraDomainData?

    public func encode(to encoder: any Encoder) throws {
        var container = encoder.container(
            keyedBy: CodingKeys.self
        )

        try container.encode(id, forKey: .id)
        try container.encode(type, forKey: .type)
        try container.encode(name, forKey: .name)
        try container.encode(title, forKey: .title)
        try container.encode(host, forKey: .host)
        try container.encode(url, forKey: .url)

        switch data {
        case .externalDomainData(let externalDomainData):
            try container.encode(externalDomainData, forKey: .data)
        default:
            break
        }
    }

    // MARK: - Internal

    enum CodingKeys: String, CodingKey {
        case id
        case type
        case name
        case title
        case host
        case url
        case data
    }
}

public struct ParraEntitlement: Codable, Equatable, Hashable {
    public init(
    ) {}
}

public struct ParraTenantAppInfoStub: Codable, Equatable, Hashable, Identifiable {
    // MARK: - Lifecycle

    public init(
        id: String,
        createdAt: String,
        updatedAt: String,
        deletedAt: String?,
        name: String,
        issuer: String,
        subdomain: String?,
        isTest: Bool,
        parentTenantId: String?,
        logo: ParraImageAssetStub?,
        domains: [ParraDomain]?,
        urls: [URL]?,
        entitlements: [ParraEntitlement]?,
        hideBranding: Bool
    ) {
        self.id = id
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.deletedAt = deletedAt
        self.name = name
        self.issuer = issuer
        self.subdomain = subdomain
        self.isTest = isTest
        self.parentTenantId = parentTenantId
        self.logo = logo
        self.domains = .init(domains ?? [])
        self.urls = urls
        self.entitlements = .init(entitlements ?? [])
        self.hideBranding = hideBranding
    }

    // MARK: - Public

    public let id: String
    public let createdAt: String
    public let updatedAt: String
    public let deletedAt: String?
    public let name: String
    /// The url of the preferred domain for this tenant to be used in issuer
    /// routes.
    public let issuer: String
    public let subdomain: String?
    public let isTest: Bool
    public let parentTenantId: String?
    public let logo: ParraImageAssetStub?
    public let domains: PartiallyDecodableArray<ParraDomain>?
    public let urls: [URL]?
    public let entitlements: PartiallyDecodableArray<ParraEntitlement>?
    /// Parra branding is hidden within the SDK for some paid plans.
    public let hideBranding: Bool

    // MARK: - Internal

    enum CodingKeys: String, CodingKey {
        case id
        case createdAt
        case updatedAt
        case deletedAt
        case name
        case issuer
        case subdomain
        case isTest
        case parentTenantId
        case logo
        case domains
        case urls
        case entitlements
        case hideBranding
    }
}

public struct ParraApplicationIosConfig: Codable, Equatable, Hashable {
    // MARK: - Lifecycle

    public init(
        name: String,
        description: String?,
        appId: String?,
        teamId: String?,
        bundleId: String,
        defaultFeedbackFormId: String?,
        errorFeedbackFormId: String?,
        metadata: ParraMetadata
    ) {
        self.name = name
        self.description = description
        self.appId = appId
        self.teamId = teamId
        self.bundleId = bundleId
        self.defaultFeedbackFormId = defaultFeedbackFormId
        self.errorFeedbackFormId = errorFeedbackFormId
        self.metadata = metadata
    }

    // MARK: - Public

    public let name: String
    public let description: String?
    public let appId: String?
    public let teamId: String?
    public let bundleId: String
    public let defaultFeedbackFormId: String?
    public let errorFeedbackFormId: String?
    public let metadata: ParraMetadata

    /// Computed using the value from ``appId`` in the format
    /// `itms-apps://itunes.apple.com/app/id\(appId)`.
    public var appStoreUrl: URL? {
        guard let appId else {
            return nil
        }

        return URL(
            string: "https://apps.apple.com/us/app/id\(appId)"
        )
    }

    /// Computed using the value from ``appId`` in the format
    /// `itms-apps://itunes.apple.com/app/id\(appId)`.
    public var appStoreWriteReviewUrl: URL? {
        guard let appId else {
            return nil
        }

        return URL(
            string: "https://apps.apple.com/app/id\(appId)?action=write-review"
        )
    }

    // MARK: - Internal

    enum CodingKeys: String, CodingKey {
        case name
        case description
        case appId
        case teamId
        case bundleId
        case defaultFeedbackFormId
        case errorFeedbackFormId
        case metadata
    }
}

@Observable
public final class ParraAppInfo: Codable, Equatable,
    Hashable
{
    // MARK: - Lifecycle

    public init(
        versionToken: String?,
        newInstalledVersionInfo: ParraNewInstalledVersionInfo?,
        tenant: ParraTenantAppInfoStub,
        auth: ParraAppAuthInfo,
        legal: ParraLegalInfo,
        application: ParraApplicationIosConfig
    ) {
        self.versionToken = versionToken
        self.newInstalledVersionInfo = newInstalledVersionInfo
        self.tenant = tenant
        self.auth = auth
        self.legal = legal
        self.application = application
    }

    // MARK: - Public

    public let application: ParraApplicationIosConfig
    public let versionToken: String?
    public let newInstalledVersionInfo: ParraNewInstalledVersionInfo?
    public let tenant: ParraTenantAppInfoStub
    public let auth: ParraAppAuthInfo
    public let legal: ParraLegalInfo

    public static func == (
        lhs: ParraAppInfo,
        rhs: ParraAppInfo
    ) -> Bool {
        return lhs.versionToken == rhs.versionToken
            && lhs.newInstalledVersionInfo == rhs.newInstalledVersionInfo
            && lhs.tenant == rhs.tenant
            && lhs.auth == rhs.auth
            && lhs.legal == rhs.legal
            && lhs.application == rhs.application
    }

    public func hash(
        into hasher: inout Hasher
    ) {
        hasher.combine(versionToken)
        hasher.combine(newInstalledVersionInfo)
        hasher.combine(tenant)
        hasher.combine(auth)
        hasher.combine(legal)
        hasher.combine(application)
    }

    // MARK: - Internal

    enum CodingKeys: String, CodingKey {
        case application
        case versionToken
        case newInstalledVersionInfo
        case tenant
        case auth
        case legal
    }

    static let `default` = ParraAppInfo(
        versionToken: nil,
        newInstalledVersionInfo: nil,
        tenant: ParraTenantAppInfoStub(
            id: "",
            createdAt: "",
            updatedAt: "",
            deletedAt: nil,
            name: "",
            issuer: "",
            subdomain: nil,
            isTest: false,
            parentTenantId: nil,
            logo: nil,
            domains: nil,
            urls: nil,
            entitlements: nil,
            hideBranding: false
        ),
        auth: ParraAppAuthInfo(
            database: nil,
            passwordless: nil
        ),
        legal: ParraLegalInfo(),
        application: ParraApplicationIosConfig(
            name: "",
            description: nil,
            appId: nil,
            teamId: nil,
            bundleId: "",
            defaultFeedbackFormId: nil,
            errorFeedbackFormId: nil,
            metadata: ParraMetadata()
        )
    )
}

public struct ParraPasswordRule: Codable, Equatable, Hashable {
    // MARK: - Lifecycle

    public init(
        regularExpression: String,
        errorMessage: String
    ) {
        self.regularExpression = regularExpression
        self.errorMessage = errorMessage
    }

    // MARK: - Public

    public let regularExpression: String
    public let errorMessage: String
}

public struct ParraPasswordConfig: Codable, Equatable, Hashable {
    // MARK: - Lifecycle

    public init(
        iosPasswordRulesDescriptor: String?,
        rules: [ParraPasswordRule]
    ) {
        self.iosPasswordRulesDescriptor = iosPasswordRulesDescriptor
        self.rules = .init(rules)
    }

    // MARK: - Public

    public let iosPasswordRulesDescriptor: String?
    public let rules: PartiallyDecodableArray<ParraPasswordRule>
}

public struct ParraUsernameConfig: Codable, Equatable, Hashable {
    // MARK: - Lifecycle

    public init(
        required: Bool,
        allowSignup: Bool
    ) {
        self.required = required
        self.allowSignup = allowSignup
    }

    // MARK: - Public

    public let required: Bool
    public let allowSignup: Bool
}

public struct ParraEmailConfig: Codable, Equatable, Hashable {
    // MARK: - Lifecycle

    public init(
        required: Bool,
        requireVerification: Bool,
        allowSignup: Bool
    ) {
        self.required = required
        self.requireVerification = requireVerification
        self.allowSignup = allowSignup
    }

    // MARK: - Public

    public let required: Bool
    public let requireVerification: Bool
    public let allowSignup: Bool
}

public struct ParraPhoneNumberConfig: Codable, Equatable, Hashable {
    // MARK: - Lifecycle

    public init(
        required: Bool,
        requireVerification: Bool,
        allowSignup: Bool
    ) {
        self.required = required
        self.requireVerification = requireVerification
        self.allowSignup = allowSignup
    }

    // MARK: - Public

    public let required: Bool
    public let requireVerification: Bool
    public let allowSignup: Bool
}

public struct ParraAppInfoDatabaseConfig: Codable, Equatable, Hashable {
    // MARK: - Lifecycle

    public init(
        password: ParraPasswordConfig?,
        username: ParraUsernameConfig?,
        email: ParraEmailConfig?,
        phoneNumber: ParraPhoneNumberConfig?,
        passkeys: ParraAppInfoPasskeysConfig?,
        anonymousAuth: ParraAppInfoAnonymousAuthConfig?
    ) {
        self.password = password
        self.username = username
        self.email = email
        self.phoneNumber = phoneNumber
        self.passkeys = passkeys
        self.anonymousAuth = anonymousAuth
    }

    // MARK: - Public

    public let password: ParraPasswordConfig?
    public let username: ParraUsernameConfig?
    public let email: ParraEmailConfig?
    public let phoneNumber: ParraPhoneNumberConfig?
    public let passkeys: ParraAppInfoPasskeysConfig?
    public let anonymousAuth: ParraAppInfoAnonymousAuthConfig?
}

public struct ParraAuthInfoPasswordlessSmsConfig: Codable, Equatable, Hashable {
    // MARK: - Lifecycle

    public init(
        otpLength: Int
    ) {
        self.otpLength = otpLength
    }

    // MARK: - Public

    public let otpLength: Int

    // MARK: - Internal

    enum CodingKeys: String, CodingKey {
        case otpLength
    }
}

public struct ParraAuthInfoPasswordlessConfig: Codable, Equatable, Hashable {
    // MARK: - Lifecycle

    public init(
        sms: ParraAuthInfoPasswordlessSmsConfig?
    ) {
        self.sms = sms
    }

    // MARK: - Public

    public let sms: ParraAuthInfoPasswordlessSmsConfig?

    // MARK: - Internal

    static let `default` = ParraAuthInfoPasswordlessConfig(
        sms: ParraAuthInfoPasswordlessSmsConfig(otpLength: 6)
    )
}

public struct ParraAppInfoPasskeysConfig: Codable, Equatable, Hashable {}

public struct ParraAppInfoAnonymousAuthConfig: Codable, Equatable, Hashable {}

public final class ParraAppAuthInfo: Codable, Equatable, Hashable {
    // MARK: - Lifecycle

    public init(
        database: ParraAppInfoDatabaseConfig?,
        passwordless: ParraAuthInfoPasswordlessConfig?
    ) {
        self.database = database
        self.passwordless = passwordless
    }

    // MARK: - Public

    public let database: ParraAppInfoDatabaseConfig?
    public let passwordless: ParraAuthInfoPasswordlessConfig?

    public static func == (
        lhs: ParraAppAuthInfo,
        rhs: ParraAppAuthInfo
    ) -> Bool {
        return lhs.database == rhs.database && lhs.passwordless == rhs
            .passwordless
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(database)
        hasher.combine(passwordless)
    }

    // MARK: - Internal

    var supportsPasskeys: Bool {
        return database?.passkeys != nil
    }

    var supportsAnonymous: Bool {
        return database?.anonymousAuth != nil
    }
}

public struct ParraLegalInfo: Codable, Equatable, Hashable {
    // MARK: - Lifecycle

    public init(
        privacyPolicy: ParraLegalDocument? = nil,
        termsOfService: ParraLegalDocument? = nil
    ) {
        self.privacyPolicy = privacyPolicy
        self.termsOfService = termsOfService
    }

    // MARK: - Public

    public let privacyPolicy: ParraLegalDocument?
    public let termsOfService: ParraLegalDocument?

    public var allDocuments: [ParraLegalDocument] {
        var documents = [ParraLegalDocument]()

        if let privacyPolicy {
            documents.append(privacyPolicy)
        }

        if let termsOfService {
            documents.append(termsOfService)
        }

        return documents
    }

    public var hasDocuments: Bool {
        return !allDocuments.isEmpty
    }

    // MARK: - Internal

    enum CodingKeys: CodingKey {
        case privacyPolicy
        case termsOfService
    }

    static let empty = ParraLegalInfo()
}

public struct ParraLegalDocument: Codable, Equatable, Hashable, Identifiable {
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
