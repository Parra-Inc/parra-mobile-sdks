//
//  ViewDataLoader+Roadmap.swift
//  Parra
//
//  Created by Mick MacCallum on 3/5/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

struct RoadmapParams: Equatable {
    let limit: Int
    let offset: Int
}

struct RoadmapLoaderResult: Equatable {
    let roadmapConfig: AppRoadmapConfiguration
    let selectedTab: RoadmapConfigurationTab
    let ticketResponse: UserTicketCollectionResponse
}

extension ViewDataLoader {
    static func roadmapLoader(
        config: RoadmapWidgetConfig
    ) -> ViewDataLoader<RoadmapParams, RoadmapLoaderResult, RoadmapWidget> {
        return ViewDataLoader<
            RoadmapParams,
            RoadmapLoaderResult,
            RoadmapWidget
        >(
            renderer: { parra, params, _ in
                let container: RoadmapWidget = parra.parraInternal
                    .containerRenderer.renderContainer(
                        params: RoadmapWidget.ContentObserver.InitialParams(
                            roadmapConfig: params.roadmapConfig,
                            selectedTab: params.selectedTab,
                            ticketResponse: params.ticketResponse,
                            api: parra.parraInternal.api
                        ),
                        config: config
                    ) { _ in
                        // TODO: Dismisser set on container.contentObserver?
                    }

                return container
            }
        )
    }
}
