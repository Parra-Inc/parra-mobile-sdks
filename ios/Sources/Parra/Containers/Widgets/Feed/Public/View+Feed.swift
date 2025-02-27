//
//  View+Feed.swift
//  Parra
//
//  Created by Mick MacCallum on 9/27/24.
//

import SwiftUI

public extension View {
    /// Automatically fetches the feed with the provided id and
    /// presents it in a sheet based on the value of the `isPresented` binding.
    @MainActor
    func presentParraFeedWidget(
        by feedId: String,
        presentationState: Binding<ParraSheetPresentationState>,
        config: ParraFeedConfiguration = .default,
        onDismiss: ((ParraSheetDismissType) -> Void)? = nil
    ) -> some View {
        let transformParams = FeedTransformParams(feedId: feedId)

        let transformer: ParraViewDataLoader<
            FeedTransformParams,
            FeedParams,
            FeedWidget
        >.Transformer = { parra, _ in
            do {
                let response = try await parra.parraInternal.api
                    .paginateFeed(feedId: feedId, limit: 15, offset: 0)

                return FeedParams(
                    feedId: feedId,
                    feedCollectionResponse: response
                )
            } catch let error as ParraError {
                if case .networkError(_, let response, _) = error {
                    if response.statusCode == 404 {
                        Logger.error("Can not find feed with id \(feedId)")
                    }
                }

                throw error
            }
        }

        return loadAndPresentSheet(
            name: "feed",
            presentationState: presentationState,
            transformParams: transformParams,
            transformer: transformer,
            with: .feedLoader(
                config: config
            ),
            onDismiss: onDismiss
        )
    }
}
