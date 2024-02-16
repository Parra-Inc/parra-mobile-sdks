//
//  EdgeInsets+inits.swift
//  Parra
//
//  Created by Mick MacCallum on 1/30/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI
import UIKit

extension EdgeInsets {
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
}
