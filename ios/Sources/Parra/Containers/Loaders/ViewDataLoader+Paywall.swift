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
    let iapType: PaywallIapType
    let paywallProducts: PaywallProducts
    let marketingContent: ApplePaywallMarketingContent?
    let sections: [ParraPaywallSection]?
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
            renderer: { parra, params, navigationPath, _ in
                let container: PaywallWidget = parra.parraInternal
                    .containerRenderer.renderContainer(
                        params: PaywallWidget.ContentObserver.InitialParams(
                            paywallId: params.id,
                            iapType: params.iapType,
                            paywallProducts: params.paywallProducts,
                            marketingContent: params.marketingContent,
                            sections: params.sections,
                            config: config,
                            api: parra.parraInternal.api,
                            appInfo: params.appInfo
                        ),
                        config: config,
                        contentTransformer: nil,
                        navigationPath: navigationPath
                    )

                return container
            }
        )
    }
}
