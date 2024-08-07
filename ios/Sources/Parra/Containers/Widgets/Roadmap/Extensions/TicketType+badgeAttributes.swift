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
        }
    }

    var backgroundColor: ParraColor {
        switch self {
        case .bug:
            return ParraColorSwatch.red.shade500
        case .feature:
            return ParraColorSwatch.sky.shade400
        case .improvement:
            return ParraColorSwatch.lime.shade400
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
        }
    }
}
