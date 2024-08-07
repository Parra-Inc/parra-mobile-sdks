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

public struct ParraRoadmapInfo: Equatable {
    public let roadmapConfig: ParraAppRoadmapConfiguration
    public let selectedTab: ParraRoadmapConfigurationTab
    public let ticketResponse: ParraUserTicketCollectionResponse
}

extension ViewDataLoader {
    static func roadmapLoader(
        config: ParraRoadmapWidgetConfig
    ) -> ViewDataLoader<RoadmapParams, ParraRoadmapInfo, RoadmapWidget> {
        return ViewDataLoader<
            RoadmapParams,
            ParraRoadmapInfo,
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
                        config: config,
                        contentTransformer: nil
                    )

                return container
            }
        )
    }
}
