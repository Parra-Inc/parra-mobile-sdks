//
//  PaywallWidget+ContentObserver+InitialParams.swift
//  Parra
//
//  Created by Mick MacCallum on 11/12/24.
//

import StoreKit
import SwiftUI

enum PaywallProducts: Equatable {
    case products([Product])
    case productIds([String])
    case groupId(String)
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
