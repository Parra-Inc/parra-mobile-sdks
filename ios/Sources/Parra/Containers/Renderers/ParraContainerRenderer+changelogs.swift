//
//  ParraContainerRenderer+changelogs.swift
//  Parra
//
//  Created by Mick MacCallum on 2/25/25.
//

import SwiftUI

extension ParraContainerRenderer {
    @MainActor
    static func changelogRenderer(
        config: ChangelogWidget.Config,
        parra: Parra,
        data: ParraChangelogInfo,
        navigationPath: Binding<NavigationPath>,
        dismisser: ParraSheetDismisser?
    ) -> ChangelogWidget {
        return parra.parraInternal
            .containerRenderer.renderContainer(
                params: .init(
                    appReleaseCollection: data.appReleaseCollection,
                    api: parra.parraInternal.api
                ),
                config: config,
                contentTransformer: nil,
                navigationPath: navigationPath
            )
    }

    @MainActor
    static func paywallRenderer(
        config: PaywallWidget.Config,
        parra: Parra,
        data: ParraPaywall,
        navigationPath: Binding<NavigationPath>,
        dismisser: ParraSheetDismisser?
    ) -> PaywallWidget {
        return parra.parraInternal
            .containerRenderer.renderContainer(
                params: .init(
                    paywallId: data.paywall.id,
                    iapType: data.paywall.iapType,
                    paywallProducts: data.products,
                    marketingContent: data.paywall.marketingContent,
                    sections: data.paywall.sections,
                    config: config,
                    api: parra.parraInternal.api
                ),
                config: config,
                contentTransformer: nil,
                navigationPath: navigationPath
            )
    }
}
