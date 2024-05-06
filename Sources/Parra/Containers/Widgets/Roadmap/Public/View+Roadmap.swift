//
//  View+Roadmap.swift
//  Parra
//
//  Created by Mick MacCallum on 3/5/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

public extension View {
    /// Automatically fetches the feedback form with the provided id and
    /// presents it in a sheet based on the value of the `isPresented` binding.
    @MainActor
    func presentParraRoadmap(
        isPresented: Binding<Bool>,
        config: RoadmapWidgetConfig = .default,
        onDismiss: ((SheetDismissType) -> Void)? = nil
    ) -> some View {
        let transformParams = RoadmapParams(
            limit: 15,
            offset: 0
        )

        let transformer: ViewDataLoader<
            RoadmapParams,
            RoadmapLoaderResult,
            RoadmapWidget
        >.Transformer = { parra, transformParams in
            let roadmapConfig = try await parra.parraInternal.api.getRoadmap()

            guard let tab = roadmapConfig.tabs.first else {
                throw ParraError.message(
                    "Can not paginate tickets. Roadmap response has no tabs."
                )
            }

            let ticketResponse = try await parra.parraInternal
                .api
                .paginateTickets(
                    limit: transformParams.limit,
                    offset: transformParams.offset,
                    filter: tab.key
                )

            return RoadmapLoaderResult(
                roadmapConfig: roadmapConfig,
                selectedTab: tab,
                ticketResponse: ticketResponse
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
            with: .roadmapLoader(
                config: config
            ),
            onDismiss: onDismiss
        )
    }
}
