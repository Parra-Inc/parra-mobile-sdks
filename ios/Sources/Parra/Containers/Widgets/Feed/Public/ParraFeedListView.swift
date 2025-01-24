//
//  ParraFeedListView.swift
//  Parra
//
//  Created by Mick MacCallum on 9/27/24.
//

import SwiftUI

public struct ParraFeedListView: View {
    // MARK: - Lifecycle

    public init(
        items: [ParraFeedItem],
        itemSpacing: CGFloat = 16,
        containerGeometry: GeometryProxy,
        navigationPath: Binding<NavigationPath>,
        itemAtIndexDidAppear: @escaping (_: Int) -> Void,
        performActionForFeedItemData: @escaping (_: ParraFeedItemData) -> Void
    ) {
        self.items = items
        self.itemSpacing = itemSpacing
        self.containerGeometry = containerGeometry
        _navigationPath = navigationPath
        self.itemAtIndexDidAppear = itemAtIndexDidAppear
        self.performActionForFeedItemData = performActionForFeedItemData
    }

    // MARK: - Public

    public let items: [ParraFeedItem]
    public let itemSpacing: CGFloat
    public let containerGeometry: GeometryProxy
    public let itemAtIndexDidAppear: (Int) -> Void
    public let performActionForFeedItemData: (_ feedItemData: ParraFeedItemData) -> Void

    public var body: some View {
        // Spacing must be implemented in cells for self-sizing reasons.
        LazyVStack(alignment: .center, spacing: 0) {
            createCells(with: containerGeometry)
        }
        .navigationDestination(
            isPresented: Binding<Bool>(
                get: {
                    return presentedCreatorUpdate != nil
                },
                set: { value in
                    if !value {
                        presentedCreatorUpdate = nil
                    }
                }
            ),
            destination: {
                if let presentedCreatorUpdate {
                    FeedCreatorUpdateDetailView(
                        creatorUpdate: presentedCreatorUpdate.creatorUpdate,
                        feedItem: presentedCreatorUpdate.feedItem,
                        reactor: presentedCreatorUpdate.reactor,
                        navigationPath: $navigationPath
                    )
                    .environmentObject(contentObserver)
                }
            }
        )
    }

    // MARK: - Internal

    @Binding var navigationPath: NavigationPath

    // MARK: - Private

    @State private var presentedCreatorUpdate: FeedCreatorUpdateDetailParams?
    @Environment(FeedWidget.ContentObserver.self) private var contentObserver

    @ViewBuilder
    private func createCells(
        with containerGeometry: GeometryProxy
    ) -> some View {
        let spacing = itemSpacing / 2

        ForEach(
            Array(items.enumerated()),
            id: \.element
        ) {
            index,
                item in
            if case .feedItemYoutubeVideo(let data) = item.data {
                FeedYouTubeVideoView(
                    youtubeVideo: data,
                    feedItemId: item.id,
                    reactionOptions: item.reactionOptions?.elements,
                    reactions: item.reactions?.elements,
                    containerGeometry: containerGeometry,
                    spacing: spacing,
                    navigationPath: $navigationPath,
                    performActionForFeedItemData: performActionForFeedItemData
                )
                .id(item.id)
                .onAppear {
                    itemAtIndexDidAppear(index)
                }
            } else if case .contentCard(let data) = item.data {
                FeedContentCardView(
                    contentCard: data,
                    feedItemId: item.id,
                    reactionOptions: item.reactionOptions?.elements,
                    reactions: item.reactions?.elements,
                    containerGeometry: containerGeometry,
                    spacing: spacing,
                    navigationPath: $navigationPath,
                    performActionForFeedItemData: performActionForFeedItemData
                )
                .id(item.id)
                .onAppear {
                    itemAtIndexDidAppear(index)
                }
            } else if case .creatorUpdate(let data) = item.data {
                FeedCreatorUpdateView(
                    params: FeedCreatorUpdateParams(
                        creatorUpdate: data,
                        feedItem: item,
                        reactionOptions: item.reactionOptions?.elements,
                        reactions: item.reactions?.elements,
                        containerGeometry: containerGeometry,
                        spacing: spacing,
                        performActionForFeedItemData: performActionForFeedItemData,
                        performCreatorUpdateSelection: { detailParams in
                            presentedCreatorUpdate = detailParams
                        }
                    )
                )
                .id(item.id)
                .onAppear {
                    itemAtIndexDidAppear(index)
                }
            } else {
                EmptyView()
                    .id(item.id)
                    .onAppear {
                        itemAtIndexDidAppear(index)
                    }
            }
        }
    }
}
