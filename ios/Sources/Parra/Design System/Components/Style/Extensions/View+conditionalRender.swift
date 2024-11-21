//
//  View+conditionalRender.swift
//  Parra
//
//  Created by Mick MacCallum on 3/13/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

extension View {
    @ViewBuilder
    func `if`(
        _ condition: Bool,
        @ViewBuilder renderer: (Self) -> some View
    ) -> some View {
        if condition {
            renderer(self)
        } else {
            self
        }
    }

    @ViewBuilder
    func withContent<Content>(
        content: Content?,
        @ViewBuilder renderer: (_ content: Content) -> some View
    ) -> some View {
        if let content {
            renderer(content)
        }
    }

    @ViewBuilder
    func withContent<Content, Style>(
        content: Content?,
        style: Style?,
        @ViewBuilder renderer: (
            _ content: Content,
            _ style: Style
        ) -> some View
    ) -> some View {
        if let content, let style {
            renderer(content, style)
        }
    }
}
