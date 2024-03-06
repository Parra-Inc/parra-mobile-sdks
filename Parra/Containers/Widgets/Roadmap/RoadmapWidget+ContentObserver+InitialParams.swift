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
        let roadmapConfig: AppRoadmapConfiguration
        let selectedTab: RoadmapWidget.Tab
        let ticketResponse: UserTicketCollectionResponse
        let networkManager: ParraNetworkManager
    }
}
