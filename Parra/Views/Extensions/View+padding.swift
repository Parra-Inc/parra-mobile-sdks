//
//  View+padding.swift
//  Parra
//
//  Created by Mick MacCallum on 2/27/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

extension View {
    func padding(
        _ edges: Edge.Set,
        from edgeInsets: EdgeInsets
    ) -> some View {
        if edges.contains(.all) {
            return padding(edgeInsets)
        }

        var insets = EdgeInsets()

        if edges.contains(.top) || edges.contains(.vertical) {
            insets.top = edgeInsets.top
        }

        if edges.contains(.bottom) || edges.contains(.vertical) {
            insets.bottom = edgeInsets.bottom
        }

        if edges.contains(.leading) || edges.contains(.horizontal) {
            insets.leading = edgeInsets.leading
        }

        if edges.contains(.trailing) || edges.contains(.horizontal) {
            insets.trailing = edgeInsets.trailing
        }

        return padding(insets)
    }
}
