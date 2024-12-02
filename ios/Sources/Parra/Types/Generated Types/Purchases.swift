//
//  Purchases.swift
//  Parra
//
//  Created by Mick MacCallum on 11/12/24.
//

import Foundation

public struct ParraPaywallMarketingContent: Codable, Equatable, Hashable {
    public let title: String?
    public let subtitle: String?
    public let productImage: ParraImageAsset?
}

public struct ParraApplePaywall: Codable, Equatable, Hashable, Identifiable {
    public let id: String
    public let groupId: String?
    public let productIds: [String]?
    public let marketingContent: ParraPaywallMarketingContent?
}

public struct ParraUserEntitlementsResponseBody: Codable, Equatable, Hashable {
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
