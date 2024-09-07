//
//  EdgeInsets+inits.swift
//  Parra
//
//  Created by Mick MacCallum on 1/30/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI
import UIKit

public extension EdgeInsets {
    init(_ allSides: CGFloat) {
        self.init(
            top: allSides,
            leading: allSides,
            bottom: allSides,
            trailing: allSides
        )
    }

    init(
        vertical: CGFloat,
        horizontal: CGFloat
    ) {
        self.init(
            top: vertical,
            leading: horizontal,
            bottom: vertical,
            trailing: horizontal
        )
    }

    init(_ edgeInsets: UIEdgeInsets) {
        self.init(
            top: edgeInsets.top,
            leading: edgeInsets.left,
            bottom: edgeInsets.bottom,
            trailing: edgeInsets.right
        )
    }

    internal static func padding(
        top: CGFloat = 0.0,
        leading: CGFloat = 0.0,
        bottom: CGFloat = 0.0,
        trailing: CGFloat = 0.0
    ) -> EdgeInsets {
        return EdgeInsets(
            top: top,
            leading: leading,
            bottom: bottom,
            trailing: trailing
        )
    }

    internal static func padding(
        vertical: CGFloat = 0.0,
        horizontal: CGFloat = 0.0
    ) -> EdgeInsets {
        return EdgeInsets(
            vertical: vertical,
            horizontal: horizontal
        )
    }
}
