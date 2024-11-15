//
//  PaywallWidget+ContentObserver+Content.swift
//  Parra
//
//  Created by Mick MacCallum on 11/12/24.
//

import SwiftUI

extension PaywallWidget.ContentObserver {
    struct Content: ParraContainerContent {
        // MARK: - Lifecycle

        init(
            config: ParraPaywallConfig,
            appInfo: ParraAppInfo,
            marketingContent: ParraPaywallMarketingContent?
        ) {
            self.title = ParraLabelContent(
                text: marketingContent?.title ?? config.defaultTitle
            )

            self.subtitle = ParraLabelContent(
                text: marketingContent?.subtitle ?? config.defaultSubtitle
            )

            self.image = if let image = marketingContent?.productImage {
                ParraAsyncImageContent(url: image.url)
            } else {
                if let tenantLogo = appInfo.tenant.logo {
                    ParraAsyncImageContent(
                        url: tenantLogo.url,
                        originalSize: tenantLogo.size
                    )
                } else {
                    nil
                }
            }
        }

        // MARK: - Internal

        let title: ParraLabelContent
        let subtitle: ParraLabelContent
        let image: ParraAsyncImageContent?
    }
}
