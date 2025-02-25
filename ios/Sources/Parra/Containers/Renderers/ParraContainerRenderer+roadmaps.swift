//
//  ParraContainerRenderer+roadmaps.swift
//  Parra
//
//  Created by Mick MacCallum on 2/25/25.
//

import SwiftUI

extension ParraContainerRenderer {
    @MainActor
    static func roadmapRenderer(
        config: RoadmapWidget.Config,
        parra: Parra,
        data: ParraRoadmapInfo,
        navigationPath: Binding<NavigationPath>,
        dismisser: ParraSheetDismisser?
    ) -> RoadmapWidget {
        return parra.parraInternal
            .containerRenderer.renderContainer(
                params: RoadmapWidget.ContentObserver.InitialParams(
                    roadmapConfig: data.roadmapConfig,
                    selectedTab: data.selectedTab,
                    ticketResponse: data.ticketResponse,
                    api: parra.parraInternal.api
                ),
                config: config,
                contentTransformer: nil,
                navigationPath: navigationPath
            )
    }
}
