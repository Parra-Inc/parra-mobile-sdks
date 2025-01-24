//
//  ParraFeedWidget.swift
//  Parra
//
//  Created by Mick MacCallum on 9/26/24.
//

import SwiftUI

@MainActor
public struct ParraFeedWidget: View {
    // MARK: - Lifecycle

    public init(
        feedId: String,
        config: ParraFeedConfiguration = .default,
        navigationPath: Binding<NavigationPath>
    ) {
        self.feedId = feedId
        self.config = config
        self._navigationPath = navigationPath
    }

    // MARK: - Public

    public let feedId: String
    public let config: ParraFeedConfiguration
    @Binding public var navigationPath: NavigationPath

    public var body: some View {
        let container: FeedWidget = parra.parraInternal
            .containerRenderer.renderContainer(
                params: FeedWidget.ContentObserver.InitialParams(
                    feedId: feedId,
                    config: config,
                    feedCollectionResponse: nil,
                    api: parra.parraInternal.api
                ),
                config: config,
                contentTransformer: nil,
                navigationPath: $navigationPath
            )

        return container
    }

    // MARK: - Private

    @Environment(\.parra) private var parra
}
