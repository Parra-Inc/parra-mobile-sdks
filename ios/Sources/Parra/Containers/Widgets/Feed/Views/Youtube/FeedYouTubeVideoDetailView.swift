//
//  FeedYouTubeVideoDetailView.swift
//  Parra
//
//  Created by Mick MacCallum on 9/25/24.
//

import SwiftUI

struct FeedYouTubeVideoDetailView: View {
    // MARK: - Lifecycle

    init(
        youtubeVideo: ParraFeedItemYoutubeVideoData,
        feedItem: ParraFeedItem,
        reactor: StateObject<Reactor>,
        navigationPath: Binding<NavigationPath>
    ) {
        self.youtubeVideo = youtubeVideo
        self.feedItem = feedItem
        self._reactor = reactor
        self._navigationPath = navigationPath
    }

    // MARK: - Internal

    let youtubeVideo: ParraFeedItemYoutubeVideoData
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
                        attachmentPaywall: nil,
                        api: parra.parraInternal.api,
                        refreshOnAppear: false
                    ),
                    config: ParraFeedCommentWidgetConfig(
                        headerViewBuilder: {
                            let cornerRadius = theme.cornerRadius.value(
                                for: .xl
                            )

                            FeedYouTubeVideoDetailViewHeader(
                                youtubeVideo: youtubeVideo,
                                feedItem: feedItem,
                                containerGeometry: geometry,
                                reactor: _reactor
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
