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
        config: RoadmapWidgetConfig,
        localBuilder: RoadmapWidget.BuilderConfig
    ) -> ViewDataLoader<RoadmapParams, RoadmapLoaderResult, RoadmapWidget> {
        return ViewDataLoader<
            RoadmapParams,
            RoadmapLoaderResult,
            RoadmapWidget
        >(
            loader: { parra, transformParams in
                let roadmapConfig = try await parra.parraInternal.networkManager
                    .getRoadmap()

                guard let tab = roadmapConfig.tabs.first else {
                    throw ParraError.message(
                        "Can not paginate tickets. Roadmap response has no tabs."
                    )
                }

                let ticketResponse = try await parra.parraInternal
                    .networkManager
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
            },
            renderer: { parra, params, _ in
                let container: RoadmapWidget = renderContainer(
                    from: parra.parraInternal,
                    with: localBuilder,
                    params: .init(
                        roadmapConfig: params.roadmapConfig,
                        selectedTab: params.selectedTab,
                        ticketResponse: params.ticketResponse,
                        networkManager: parra.parraInternal.networkManager
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
