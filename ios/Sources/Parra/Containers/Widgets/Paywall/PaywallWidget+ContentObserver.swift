//
//  PaywallWidget+ContentObserver.swift
//  Parra
//
//  Created by Mick MacCallum on 11/12/24.
//

import SwiftUI

extension PaywallWidget {
    @Observable
    class ContentObserver: ParraContainerContentObserver {
        // MARK: - Lifecycle

        required init(
            initialParams: InitialParams
        ) {
            self.initialParams = initialParams

            self.content = Content(
                config: initialParams.config,
                appInfo: initialParams.appInfo,
                marketingContent: initialParams.marketingContent
            )
        }

        // MARK: - Internal

        var content: Content
        let initialParams: InitialParams
    }
}
