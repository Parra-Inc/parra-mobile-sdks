//
//  Purchases.swift
//  Parra
//
//  Created by Mick MacCallum on 11/12/24.
//

import Foundation

public enum AppPaywallType: String, Codable {
    case apple
    case parra
}

public struct ApplePaywallMarketingContent: Codable, Equatable, Hashable {
    // MARK: - Lifecycle

    public init(
        title: String,
        subtitle: String?,
        productImage: ParraImageAsset?
    ) {
        self.title = title
        self.subtitle = subtitle
        self.productImage = productImage
    }

    // MARK: - Public

    public let title: String
    public let subtitle: String?
    public let productImage: ParraImageAsset?
}

public struct ParraPaywallHeaderSection: Codable, Equatable, Hashable, Identifiable {
    // MARK: - Lifecycle

    public init(
        id: String,
        title: String,
        type: String,
        description: String?,
        icon: ParraImageAsset?
    ) {
        self.id = id
        self.title = title
        self.type = type
        self.description = description
        self.icon = icon
    }

    // MARK: - Public

    public let id: String
    public let title: String
    public let type: String
    public let description: String?
    public let icon: ParraImageAsset?
}

public struct PaywallOffering: Codable, Equatable, Hashable, Identifiable {
    // MARK: - Lifecycle

    public init(
        id: String,
        title: String
    ) {
        self.id = id
        self.title = title
    }

    // MARK: - Public

    public let id: String
    public let title: String
}

public struct ParraPaywallOfferingSection: Codable, Equatable, Hashable, Identifiable {
    // MARK: - Lifecycle

    public init(
        id: String,
        type: String,
        offerings: [PaywallOffering]
    ) {
        self.id = id
        self.type = type
        self.offerings = offerings
    }

    // MARK: - Public

    public let id: String
    public let type: String
    public let offerings: [PaywallOffering]
}

public enum ParraAppPaywallSectionType: String, Codable {
    case header
    case offerings
}

public enum ParraPaywallSection: Codable, Equatable, Hashable, Identifiable {
    case paywallHeaderSection(ParraPaywallHeaderSection)
    case paywallOfferingSection(ParraPaywallOfferingSection)

    // MARK: - Lifecycle

    public init(from decoder: Decoder) throws {
        let typeContainer = try decoder.container(keyedBy: CodingKeys.self)
        let container = try decoder.singleValueContainer()
        let type = try typeContainer.decode(
            ParraAppPaywallSectionType.self,
            forKey: .type
        )

        switch type {
        case .header:
            self = try .paywallHeaderSection(
                container.decode(ParraPaywallHeaderSection.self)
            )
        case .offerings:
            self = try .paywallOfferingSection(
                container.decode(ParraPaywallOfferingSection.self)
            )
        }
    }

    // MARK: - Public

    public var id: String {
        switch self {
        case .paywallHeaderSection(let parraPaywallHeaderSection):
            return parraPaywallHeaderSection.id
        case .paywallOfferingSection(let parraPaywallOfferingSection):
            return parraPaywallOfferingSection.id
        }
    }

    public func encode(to encoder: any Encoder) throws {
        var container = encoder.singleValueContainer()

        switch self {
        case .paywallHeaderSection(let parraPaywallHeaderSection):
            try container.encode(parraPaywallHeaderSection)
        case .paywallOfferingSection(let parraPaywallOfferingSection):
            try container.encode(parraPaywallOfferingSection)
        }
    }

    // MARK: - Private

    private enum CodingKeys: String, CodingKey {
        case type
    }
}

public struct ParraAppPaywall: Codable, Equatable, Hashable, Identifiable {
    // MARK: - Lifecycle

    public init(
        id: String,
        createdAt: String,
        updatedAt: String,
        deletedAt: String?,
        type: AppPaywallType,
        groupId: String?,
        productIds: [String]?,
        marketingContent: ApplePaywallMarketingContent?,
        sections: [ParraPaywallSection]?
    ) {
        self.id = id
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.deletedAt = deletedAt
        self.type = type
        self.groupId = groupId
        self.productIds = productIds
        self.marketingContent = marketingContent
        self.sections = sections
    }

    // MARK: - Public

    public let id: String
    public let createdAt: String
    public let updatedAt: String
    public let deletedAt: String?
    public let type: AppPaywallType
    public let groupId: String?
    public let productIds: [String]?
    /// This is for legacy code paths only and can be ignored. The sections
    /// list will have a header item that includes this information.
    public let marketingContent: ApplePaywallMarketingContent?
    public let sections: [ParraPaywallSection]?
}

public struct ParraUserEntitlementsResponseBody: Codable, Equatable, Hashable, Sendable {
    // MARK: - Lifecycle

    init(entitlements: [ParraUserEntitlement]) {
        self.entitlements = entitlements
    }

    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        self.entitlements = try container
            .decodeIfPresent(
                PartiallyDecodableArray<ParraUserEntitlement>.self,
                forKey: .entitlements
            )?.elements ?? []
    }

    // MARK: - Public

    public let entitlements: [ParraUserEntitlement]
}
