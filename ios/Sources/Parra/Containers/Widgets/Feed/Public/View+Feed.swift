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
    func presentParraFeedView(
        by feedId: String,
        isPresented: Binding<Bool>,
        config: ParraFeedConfiguration = .default,
        onDismiss: ((ParraSheetDismissType) -> Void)? = nil
    ) -> some View {
        let transformParams = FeedTransformParams(feedId: feedId)

        let transformer: ViewDataLoader<
            FeedTransformParams,
            FeedParams,
            FeedWidget
        >.Transformer = { parra, _ in
            let response = try await parra.parraInternal.api
                .paginateFeed(feedId: feedId, limit: 15, offset: 0)

            return FeedParams(
                feedId: feedId,
                feedCollectionResponse: response
            )
        }

        return loadAndPresentSheet(
            loadType: .init(
                get: {
                    if isPresented.wrappedValue {
                        return .transform(transformParams, transformer)
                    } else {
                        return nil
                    }
                },
                set: { type in
                    if type == nil {
                        isPresented.wrappedValue = false
                    }
                }
            ),
            with: .feedLoader(
                feedId: feedId,
                config: config
            ),
            onDismiss: onDismiss
        )
    }
}