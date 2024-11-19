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
}

// MARK: - PaywallWidget.ContentObserver.InitialParams

extension PaywallWidget.ContentObserver {
    struct InitialParams {
        let paywallId: String
        let paywallProducts: PaywallProducts
        let marketingContent: ParraPaywallMarketingContent?
        let config: ParraPaywallConfig
        let api: API
        let appInfo: ParraAppInfo
    }
}
