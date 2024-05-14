//
//  View+applyMenuAttributes.swift
//  Parra
//
//  Created by Mick MacCallum on 5/14/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

extension View {
    @ViewBuilder
    func applyMenuAttributes(
        _ attributes: ParraAttributes.Menu,
        using theme: ParraTheme
    ) -> some View {
        applyCommonViewAttributes(attributes, from: theme)
            .tint(attributes.tint)
    }
}
