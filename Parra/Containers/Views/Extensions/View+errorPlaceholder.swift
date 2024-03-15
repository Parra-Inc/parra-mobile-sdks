//
//  View+errorPlaceholder.swift
//  Parra
//
//  Created by Mick MacCallum on 3/14/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

struct ErrorPlaceholderModifier: ViewModifier {
    let error: Error?
    let placeholder: AnyView

    @ViewBuilder
    func body(content: Content) -> some View {
        if error == nil {
            content
        } else {
            placeholder
        }
    }
}

extension View {
    func errorPlaceholder(
        _ error: Error?,
        _ placeholder: @escaping () -> some View
    ) -> some View {
        modifier(
            ErrorPlaceholderModifier(
                error: error,
                placeholder: AnyView(placeholder())
            )
        )
    }
}
