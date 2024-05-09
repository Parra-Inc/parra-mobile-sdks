//
//  ParraGlobalComponentAttributes+Label.swift
//  Parra
//
//  Created by Mick MacCallum on 5/3/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import Foundation
import SwiftUI

public extension ParraGlobalComponentAttributes {
    func labelAttributes(
        for textStyle: ParraTextStyle,
        localAttributes: ParraAttributes.Label? = nil,
        theme: ParraTheme
    ) -> ParraAttributes.Label {
        let text = textAttributes(
            for: textStyle,
            theme: theme
        )

        return ParraAttributes.Label(
            text: text,
            icon: ParraAttributes.Image(
                tint: text.color
            )
        ).mergingOverrides(localAttributes)
    }
}
