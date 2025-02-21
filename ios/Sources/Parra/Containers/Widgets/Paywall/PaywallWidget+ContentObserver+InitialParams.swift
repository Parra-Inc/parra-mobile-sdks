//
//  PaywallWidget+ContentObserver+InitialParams.swift
//  Parra
//
//  Created by Mick MacCallum on 11/12/24.
//

import StoreKit
import SwiftUI

enum PaywallProducts: Equatable, CustomStringConvertible {
    case products([Product])
    case productIds([String])
    case groupId(String)

    // MARK: - Internal

    var description: String {
        switch self {
        case .products(let products):
            "products(\(products.map(\.id).joined(separator: ",")))"
        case .productIds(let productIds):
            "productIds(\(productIds.joined(separator: ",")))"
        case .groupId(let groupId):
            "groupId(\(groupId))"
        }
    }

    var productIds: [String]? {
        switch self {
        case .products(let products):
            return products.map(\.id)
        case .productIds(let productIds):
            return productIds
        case .groupId(let string):
            return nil
        }
    }
}

// MARK: - PaywallWidget.ContentObserver.InitialParams

extension PaywallWidget.ContentObserver {
    struct InitialParams {
        let paywallId: String
        let iapType: PaywallIapType
        let paywallProducts: PaywallProducts
        let marketingContent: ApplePaywallMarketingContent?
        let sections: [ParraPaywallSection]?
        let config: ParraPaywallConfig
        let api: API
        let appInfo: ParraAppInfo
    }
}
