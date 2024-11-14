//
//  ViewDataLoader+Paywall.swift
//  Parra
//
//  Created by Mick MacCallum on 11/12/24.
//

import StoreKit
import SwiftUI

struct PaywallParams: Equatable {
    let id: String
    let paywallProducts: PaywallProducts
    let marketingContent: ParraPaywallMarketingContent?
    let appInfo: ParraAppInfo
}

struct PaywallTransformParams: Equatable {
    let entitlement: String
    let context: String?
}

extension ParraViewDataLoader {
    static func paywallLoader(
        config: ParraPaywallConfig
    ) -> ParraViewDataLoader<PaywallTransformParams, PaywallParams, PaywallWidget> {
        return ParraViewDataLoader<
            PaywallTransformParams,
            PaywallParams,
            PaywallWidget
        >(
            renderer: { parra, params, _ in
                let container: PaywallWidget = parra.parraInternal
                    .containerRenderer.renderContainer(
                        params: PaywallWidget.ContentObserver
                            .InitialParams(
                                paywallId: params.id,
                                paywallProducts: params.paywallProducts,
                                marketingContent: params.marketingContent,
                                config: config,
                                api: parra.parraInternal.api,
                                appInfo: params.appInfo
                            ),
                        config: config,
                        contentTransformer: nil
                    )

                return container
            }
        )
    }
}
