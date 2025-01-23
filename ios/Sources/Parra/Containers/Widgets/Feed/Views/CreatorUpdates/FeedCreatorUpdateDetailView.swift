//
//  FeedCreatorUpdateDetailView.swift
//  Parra
//
//  Created by Mick MacCallum on 12/16/24.
//

import SwiftUI

struct FeedCreatorUpdateDetailView: View {
    // MARK: - Internal

    let creatorUpdate: ParraCreatorUpdateAppStub
    let feedItem: ParraFeedItem
    @ObservedObject var reactor: Reactor

    var body: some View {
        GeometryReader { geometry in
            let container: FeedCommentWidget = parra.parraInternal
                .containerRenderer.renderContainer(
                    params: FeedCommentWidget.ContentObserver.InitialParams(
                        feedItem: feedItem,
                        config: .default,
                        commentsResponse: nil,
                        api: parra.parraInternal.api
                    ),
                    config: FeedCommentWidgetConfig(
                        headerViewBuilder: {
                            let cornerRadius = theme.cornerRadius.value(for: .xl)

                            FeedCreatorUpdateDetailHeaderView(
                                creatorUpdate: creatorUpdate,
                                feedItemId: feedItem.id,
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
                    contentTransformer: nil
                )

            container
                .toolbarBackground(
                    theme.palette.primaryBackground,
                    for: .navigationBar
                )
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        ParraDismissButton()
                    }
                }
        }
    }

    // MARK: - Private

    @Environment(\.parraComponentFactory) private var componentFactory
    @Environment(\.parraTheme) private var theme
    @Environment(\.parra) private var parra
    @Environment(FeedWidget.ContentObserver.self) private var contentObserver
    @Environment(\.presentationMode) private var presentationMode
}
