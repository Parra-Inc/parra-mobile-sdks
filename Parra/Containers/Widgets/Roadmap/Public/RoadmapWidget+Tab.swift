//
//  RoadmapWidget+Tab.swift
//  Parra
//
//  Created by Mick MacCallum on 3/2/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

extension RoadmapWidget {
    enum Tab: CaseIterable, Identifiable {
        case inProgress
        case requests

        // MARK: - Internal

        var title: String {
            switch self {
            case .inProgress:
                return "In progress"
            case .requests:
                return "Requests"
            }
        }

        var id: String {
            return title
        }
    }
}
