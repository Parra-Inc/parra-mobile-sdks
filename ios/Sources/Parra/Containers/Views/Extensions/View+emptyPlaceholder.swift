//
//  View+emptyPlaceholder.swift
//  Parra
//
//  Created by Mick MacCallum on 3/6/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

struct EmptyPlaceholderModifier<Items: Collection>: ViewModifier {
    let items: Items
    let placeholder: AnyView

    @ViewBuilder
    func body(content: Content) -> some View {
        if !items.isEmpty {
            content
        } else {
            placeholder
        }
    }
}

public extension View {
    func emptyPlaceholder(
        _ items: some Collection,
        @ViewBuilder _ placeholder: @escaping () -> some View
    ) -> some View {
        modifier(
            EmptyPlaceholderModifier(
                items: items,
                placeholder: AnyView(placeholder())
            )
        )
    }
}
