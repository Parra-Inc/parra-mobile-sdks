//
//  GridLayout.swift
//  Parra
//
//  Created by Mick MacCallum on 9/30/24.
//

import SwiftUI

enum GridLayout: String, CaseIterable {
    case oneColumn = "1"
    case twoColumn = "2"
    case threeColumn = "3"

    // MARK: - Internal

    var icon: String {
        switch self {
        case .oneColumn:
            return "square"
        case .twoColumn:
            return "square.grid.2x2"
        case .threeColumn:
            return "square.grid.3x3"
        }
    }

    var columnCount: Int {
        switch self {
        case .oneColumn:
            return 1
        case .twoColumn:
            return 2
        case .threeColumn:
            return 3
        }
    }

    func getColumns(
        in geometry: GeometryProxy,
        with spacing: CGFloat
    ) -> [GridItem] {
        let outterGutters = 2
        let innerGutters = columnCount - 1
        let totalGutters = outterGutters + innerGutters

        let columnWidth =
            (
                (geometry.size.width - (CGFloat(totalGutters) * spacing)) /
                    CGFloat(columnCount)
            ).rounded(
                .down
            )

        let defaultItem = GridItem(
            .fixed(columnWidth),
            spacing: spacing
        )

        return Array(repeating: defaultItem, count: columnCount)
    }
}
