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
        presentationState: Binding<ParraSheetPresentationState>,
        config: ParraRoadmapWidgetConfig = .default,
        onDismiss: ((ParraSheetDismissType) -> Void)? = nil
    ) -> some View {
        let transformParams = RoadmapParams(
            limit: 15,
            offset: 0
        )

        let transformer: ParraViewDataLoader<
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
            presentationState: presentationState,
            transformParams: transformParams,
            transformer: transformer,
            with: .roadmapLoader(
                config: config
            ),
            onDismiss: onDismiss
        )
    }

    @MainActor
    func presentParraRoadmapWidget(
        with dataBinding: Binding<ParraRoadmapInfo?>,
        config: ParraRoadmapWidgetConfig = .default,
        onDismiss: ((ParraSheetDismissType) -> Void)? = nil
    ) -> some View {
        return presentSheetWithData(
            data: dataBinding,
            config: config,
            with: ParraContainerRenderer.roadmapRenderer,
            onDismiss: onDismiss
        )
    }
}
