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
    let filter: TicketFilter
}

struct RoadmapLoaderResult: Equatable {
    let roadmapConfig: AppRoadmapConfiguration
    let selectedTab: RoadmapWidget.Tab
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
                async let getRoadmap = parra.networkManager.getRoadmap()
                async let getTickets = parra.networkManager.paginateTickets(
                    limit: transformParams.limit,
                    offset: transformParams.offset,
                    filter: transformParams.filter
                )

                let (roadmapConfig, ticketResponse) = try await (
                    getRoadmap,
                    getTickets
                )

                return RoadmapLoaderResult(
                    roadmapConfig: roadmapConfig,
                    selectedTab: transformParams.filter.toTab,
                    ticketResponse: ticketResponse
                )
            },
            renderer: { parra, params, _ in
                let container: RoadmapWidget = renderContainer(
                    from: parra,
                    with: localBuilder,
                    params: .init(
                        roadmapConfig: params.roadmapConfig,
                        selectedTab: params.selectedTab,
                        ticketResponse: params.ticketResponse,
                        networkManager: parra.networkManager
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
