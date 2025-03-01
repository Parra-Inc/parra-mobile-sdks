//
//  FeedCreatorUpdateDetailView.swift
//  Parra
//
//  Created by Mick MacCallum on 12/16/24.
//

import SwiftUI

struct FeedCreatorUpdateDetailView: View {
    // MARK: - Lifecycle

    init(
        creatorUpdate: ParraCreatorUpdateAppStub,
        feedItem: ParraFeedItem,
        reactor: StateObject<Reactor>,
        navigationPath: Binding<NavigationPath>
    ) {
        self.creatorUpdate = creatorUpdate
        self.feedItem = feedItem
        self._reactor = reactor
        self._navigationPath = navigationPath
    }

    // MARK: - Internal

    let creatorUpdate: ParraCreatorUpdateAppStub
    let feedItem: ParraFeedItem
    @StateObject var reactor: Reactor
    @Binding var navigationPath: NavigationPath

    var body: some View {
        GeometryReader { geometry in
            let container: FeedCommentWidget = parra.parraInternal
                .containerRenderer.renderContainer(
                    params: FeedCommentWidget.ContentObserver.InitialParams(
                        feedItem: feedItem,
                        config: .default,
                        commentsResponse: nil,
                        attachmentPaywall: creatorUpdate.attachmentPaywall,
                        api: parra.parraInternal.api
                    ),
                    config: ParraFeedCommentWidgetConfig(
                        headerViewBuilder: {
                            let cornerRadius = theme.cornerRadius.value(
                                for: .xl
                            )

                            FeedCreatorUpdateDetailHeaderView(
                                creatorUpdate: creatorUpdate,
                                feedItem: feedItem,
                                containerGeometry: geometry,
                                reactor: reactor
                            )
                            .clipShape(
                                .rect(
                                    topLeadingRadius: 0,
                                    bottomLeadingRadius: cornerRadius.bottomLeading,
                                    bottomTrailingRadius: cornerRadius.bottomTrailing,
                                    topTrailingRadius: 0
                                )
                            )
                        }
                    ),
                    contentTransformer: nil,
                    navigationPath: $navigationPath
                )

            container
                .toolbarBackground(
                    theme.palette.primaryBackground,
                    for: .navigationBar
                )
        }
    }

    // MARK: - Private

    @Environment(\.parraComponentFactory) private var componentFactory
    @Environment(\.parraTheme) private var theme
    @Environment(\.parra) private var parra
}
