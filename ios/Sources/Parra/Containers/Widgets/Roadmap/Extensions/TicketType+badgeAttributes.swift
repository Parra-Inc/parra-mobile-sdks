//
//  TicketType+badgeAttributes.swift
//  Parra
//
//  Created by Mick MacCallum on 3/12/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

extension ParraTicketType {
    var symbolName: String {
        switch self {
        case .bug:
            return "circle.fill"
        case .feature:
            return "plus"
        case .improvement:
            return "sparkles"
        case .task:
            return "checkmark"
        }
    }

    var size: CGSize {
        return CGSize(width: 16, height: 16)
    }

    var imageSize: CGSize {
        switch self {
        case .bug:
            return CGSize(width: 6, height: 6)
        case .feature:
            return CGSize(width: 12, height: 12)
        case .improvement:
            return CGSize(width: 12, height: 12)
        case .task:
            return CGSize(width: 12, height: 12)
        }
    }

    var backgroundColor: ParraColor {
        switch self {
        case .bug:
            return ParraColorSwatch.rose.shade400
        case .feature:
            return ParraColorSwatch.green.shade400
        case .improvement:
            return ParraColorSwatch.indigo.shade400
        case .task:
            return ParraColorSwatch.sky.shade400
        }
    }

    var title: String {
        switch self {
        case .bug:
            return "bug"
        case .feature:
            return "feature"
        case .improvement:
            return "improvement"
        case .task:
            return "task"
        }
    }

    var navigationTitle: String {
        switch self {
        case .bug:
            return "Bug report"
        case .feature:
            return "Feature request"
        case .improvement:
            return "Suggested improvement"
        case .task:
            return "Task"
        }
    }

    var explanation: String {
        switch self {
        case .bug:
            return "When unexpected behavior occurs within the app, such as glitches or crashes."
        case .feature:
            return "When you envision new capabilities or enhancements that could make the app more useful or enjoyable."
        case .improvement:
            return "When you spot opportunities to refine existing features or the app's overall performance for a better experience."
        case .task:
            return "Something that needs to be completed or changed that doesn't fall into other categories like bug fixes or features."
        }
    }
}
