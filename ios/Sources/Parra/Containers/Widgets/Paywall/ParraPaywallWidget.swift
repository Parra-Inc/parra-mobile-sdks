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
        paywall: ParraAppPaywall,
        config: ParraPaywallConfig
    ) {
        self.paywall = paywall
        self.config = config
    }

    // MARK: - Public

    public let paywall: ParraAppPaywall
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
                    iapType: paywall.iapType,
                    paywallProducts: paywallProducts,
                    marketingContent: paywall.marketingContent,
                    sections: paywall.sections,
                    config: config,
                    api: parra.parraInternal.api
                ),
                config: config,
                contentTransformer: nil,
                navigationPath: $navigationPath
            )

        return container
    }

    // MARK: - Private

    @State private var navigationPath: NavigationPath = .init()

    @Environment(\.parra) private var parra
}
