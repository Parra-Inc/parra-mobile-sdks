//
//  EdgeInsets+all.swift
//  Parra
//
//  Created by Mick MacCallum on 1/30/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

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
}
