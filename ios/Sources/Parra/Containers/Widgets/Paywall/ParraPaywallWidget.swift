//
//  ParraPaywallWidget.swift
//  Parra
//
//  Created by Mick MacCallum on 11/11/24.
//

import SwiftUI

@MainActor
public struct ParraPaywallWidget: View {
    // MARK: - Lifecycle

    public init(
        paywall: ParraApplePaywall,
        config: ParraPaywallConfig = .default
    ) {
        self.paywall = paywall
        self.config = config
    }

    // MARK: - Public

    public let paywall: ParraApplePaywall
    public let config: ParraPaywallConfig

    public var body: some View {
        let paywallProducts: PaywallProducts = if let productIds = paywall.productIds {
            .productIds(productIds)
        } else if let groupId = paywall.groupId {
            .groupId(groupId)
        } else {
            .productIds([])
        }

        let container: PaywallWidget = parra.parraInternal
            .containerRenderer.renderContainer(
                params: PaywallWidget.ContentObserver.InitialParams(
                    paywallId: paywall.id,
                    paywallProducts: paywallProducts,
                    marketingContent: paywall.marketingContent,
                    config: config,
                    api: parra.parraInternal.api,
                    appInfo: parraAppInfo
                ),
                config: config,
                contentTransformer: nil
            )

        return container
    }

    // MARK: - Private

    @Environment(\.parra) private var parra
    @Environment(\.parraAppInfo) private var parraAppInfo
}
