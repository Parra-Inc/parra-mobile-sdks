//
//  View+applyLabelAttributes.swift
//  Parra
//
//  Created by Mick MacCallum on 5/14/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

public extension View {
    @ViewBuilder
    func applyLabelAttributes(
        _ attributes: ParraAttributes.Label,
        using theme: ParraTheme
    ) -> some View {
        applyCommonViewAttributes(attributes, from: theme)
    }
}
