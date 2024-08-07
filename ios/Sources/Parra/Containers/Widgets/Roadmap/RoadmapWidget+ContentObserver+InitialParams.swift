//
//  RoadmapWidget+ContentObserver+InitialParams.swift
//  Parra
//
//  Created by Mick MacCallum on 3/5/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import Foundation

extension RoadmapWidget.ContentObserver {
    struct InitialParams {
        let roadmapConfig: ParraAppRoadmapConfiguration
        let selectedTab: ParraRoadmapConfigurationTab
        let ticketResponse: ParraUserTicketCollectionResponse
        let api: API
    }
}
