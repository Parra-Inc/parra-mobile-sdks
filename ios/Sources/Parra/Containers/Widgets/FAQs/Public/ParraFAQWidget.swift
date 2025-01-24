//
//  ParraFAQWidget.swift
//  Parra
//
//  Created by Mick MacCallum on 12/3/24.
//

import SwiftUI

public struct ParraFAQWidget: View {
    // MARK: - Lifecycle

    public init(
        layoutId: String,
        config: ParraUserSettingsConfiguration = .default,
        navigationPath: Binding<NavigationPath>
    ) {
        self.layoutId = layoutId
        self.config = config
        _navigationPath = navigationPath
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

    // MARK: - Internal

    @Binding var navigationPath: NavigationPath

    // MARK: - Private

    @Environment(\.parra) private var parra
}
