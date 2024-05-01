//
//  ParraProfileView.swift
//  Parra
//
//  Created by Mick MacCallum on 4/30/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

public struct ParraProfileView: View {
    // MARK: - Lifecycle

    public init(
        config: ProfileWidgetConfig = .default,
        builderConfig: ProfileWidgetBuilderConfig = .init()
    ) {
        self.config = config
        self.builderConfig = builderConfig
    }

    // MARK: - Public

    public var body: some View {
        let container: ProfileWidget = parra.parraInternal
            .containerRenderer.renderContainer(
                with: builderConfig,
                params: .init(),
                config: config
            )

        return container
    }

    // MARK: - Private

    @Environment(\.parra) private var parra

    private let config: ProfileWidgetConfig
    private let builderConfig: ProfileWidgetBuilderConfig
}
