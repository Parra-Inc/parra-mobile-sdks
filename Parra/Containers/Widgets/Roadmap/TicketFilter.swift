//
//  TicketFilter.swift
//  Parra
//
//  Created by Mick MacCallum on 3/4/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import Foundation

enum TicketFilter {
    case inProgress
    case requests

    // MARK: - Internal

    var paramName: String {
        switch self {
        case .inProgress:
            return "in_progress"
        case .requests:
            return "requests"
        }
    }

    var toTab: RoadmapWidget.Tab {
        switch self {
        case .inProgress:
            return .inProgress
        case .requests:
            return .requests
        }
    }
}
