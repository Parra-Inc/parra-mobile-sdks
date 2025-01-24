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
        config: ParraStorefrontWidgetConfig = .default,
        delegate: ParraStorefrontWidgetDelegate? = nil,
        navigationPath: Binding<NavigationPath>
    ) {
        self.config = config
        self.delegate = delegate
        _navigationPath = navigationPath
    }

    // MARK: - Public

    public let config: ParraStorefrontWidgetConfig
    public let delegate: ParraStorefrontWidgetDelegate?

    public var body: some View {
        let container: StorefrontWidget = Parra.containerRenderer.renderContainer(
            params: StorefrontWidget.ContentObserver.InitialParams(
                config: config,
                delegate: delegate,
                productsResponse: ParraStorefront.cachedPreloadResponse
            ),
            config: config,
            navigationPath: $navigationPath
        )

        return container
    }

    // MARK: - Internal

    // MARK: - Internal

    @Binding var navigationPath: NavigationPath
}
