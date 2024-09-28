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
    func presentParraRoadmapWidget(
        isPresented: Binding<Bool>,
        config: ParraRoadmapWidgetConfig = .default,
        onDismiss: ((ParraSheetDismissType) -> Void)? = nil
    ) -> some View {
        let transformParams = RoadmapParams(
            limit: 15,
            offset: 0
        )

        let transformer: ViewDataLoader<
            RoadmapParams,
            ParraRoadmapInfo,
            RoadmapWidget
        >.Transformer = { parra, transformParams in
            let roadmapConfig = try await parra.parraInternal.api.getRoadmap()

            guard let tab = roadmapConfig.tabs.elements.first else {
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

            return ParraRoadmapInfo(
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

    @MainActor
    func presentParraRoadmapWidget(
        with resultBinding: Binding<ParraRoadmapInfo?>,
        config: ParraRoadmapWidgetConfig = .default,
        onDismiss: ((ParraSheetDismissType) -> Void)? = nil
    ) -> some View {
        return loadAndPresentSheet(
            loadType: .init(
                get: {
                    if let result = resultBinding.wrappedValue {
                        return .raw(result)
                    } else {
                        return nil
                    }
                },
                set: { type in
                    if type == nil {
                        resultBinding.wrappedValue = nil
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
