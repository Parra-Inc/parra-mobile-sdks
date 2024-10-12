//
//  ParraStorefrontWidget.swift
//  Parra
//
//  Created by Mick MacCallum on 10/6/24.
//

import Parra
import SwiftUI

public struct ParraStorefrontWidget: View {
    // MARK: - Lifecycle

    public init(
        config: ParraStorefrontConfig
    ) {
        self.config = config
    }

    // MARK: - Public

    public let config: ParraStorefrontConfig

    public var body: some View {
        let container: StorefrontWidget = Parra.containerRenderer.renderContainer(
            params: StorefrontWidget.ContentObserver.InitialParams(
                config: config,
                productsResponse: nil
            ),
            config: config
        )

        return container
    }

    // MARK: - Internal
}
