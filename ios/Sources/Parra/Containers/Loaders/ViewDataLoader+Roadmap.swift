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

public struct ParraRoadmapInfo: Equatable, Sendable {
    public let roadmapConfig: ParraAppRoadmapConfiguration
    public let selectedTab: ParraRoadmapConfigurationTab
    public let ticketResponse: ParraUserTicketCollectionResponse
}

extension ParraViewDataLoader {
    static func roadmapLoader(
        config: ParraRoadmapWidgetConfig
    ) -> ParraViewDataLoader<RoadmapParams, ParraRoadmapInfo, RoadmapWidget> {
        return ParraViewDataLoader<
            RoadmapParams,
            ParraRoadmapInfo,
            RoadmapWidget
        >(
            renderer: { parra, data, navigationPath, dismisser in
                return ParraContainerRenderer
                    .roadmapRenderer(
                        config: config,
                        parra: parra,
                        data: data,
                        navigationPath: navigationPath,
                        dismisser: dismisser
                    )
            }
        )
    }
}
