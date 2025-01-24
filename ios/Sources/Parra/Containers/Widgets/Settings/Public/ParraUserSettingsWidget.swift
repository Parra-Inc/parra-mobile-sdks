//
//  ParraUserSettingsWidget.swift
//  Parra
//
//  Created by Mick MacCallum on 10/29/24.
//

import SwiftUI

// Fetches settings view with provided id and renders it in ParraUserSettingsView

public struct ParraUserSettingsWidget: View {
    // MARK: - Lifecycle

    public init(
        layoutId: String,
        config: ParraUserSettingsConfiguration = .default
    ) {
        self.layoutId = layoutId
        self.config = config
    }

    // MARK: - Public

    public let layoutId: String
    public let config: ParraUserSettingsConfiguration

    public var body: some View {
        let container: UserSettingsWidget = parra.parraInternal
            .containerRenderer.renderContainer(
                params: UserSettingsWidget.ContentObserver.InitialParams(
                    layoutId: layoutId,
                    layout: nil,
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
