//
//  RoadmapWidget+Tab.swift
//  Parra
//
//  Created by Mick MacCallum on 3/2/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

public enum ParraRoadmapTab: CaseIterable, Identifiable {
    case inProgress
    case requests

    // MARK: - Public

    public var id: String {
        return title
    }

    // MARK: - Internal

    var title: String {
        switch self {
        case .inProgress:
            return "In progress"
        case .requests:
            return "Requests"
        }
    }

    var filter: TicketFilter {
        switch self {
        case .inProgress:
            return .inProgress
        case .requests:
            return .requests
        }
    }
}
