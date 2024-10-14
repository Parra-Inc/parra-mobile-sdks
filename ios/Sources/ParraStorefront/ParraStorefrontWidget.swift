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
        config: ParraStorefrontConfig,
        delegate: ParraStorefrontWidgetDelegate? = nil
    ) {
        self.config = config
        self.delegate = delegate
    }

    // MARK: - Public

    public let config: ParraStorefrontConfig
    public let delegate: ParraStorefrontWidgetDelegate?

    public var body: some View {
        let container: StorefrontWidget = Parra.containerRenderer.renderContainer(
            params: StorefrontWidget.ContentObserver.InitialParams(
                config: config,
                delegate: delegate,
                productsResponse: nil
            ),
            config: config
        )

        return container
    }

    // MARK: - Internal
}
