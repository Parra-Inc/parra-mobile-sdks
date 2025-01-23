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
    func `guard`(
        _ condition: Bool,
        @ViewBuilder elseRenderer: (Self) -> some View
    ) -> some View {
        if condition {
            self
        } else {
            elseRenderer(self)
        }
    }

    @ViewBuilder
    func withContent<Content>(
        content: Content?,
        @ViewBuilder renderer: (_ content: Content) -> some View,
        @ViewBuilder elseRenderer: () -> some View = {
            EmptyView()
        }
    ) -> some View {
        if let content {
            renderer(content)
        } else {
            elseRenderer()
        }
    }

    @ViewBuilder
    func withContent<Content, Style>(
        content: Content?,
        style: Style?,
        @ViewBuilder renderer: (
            _ content: Content,
            _ style: Style
        ) -> some View,
        @ViewBuilder elseRenderer: () -> some View = {
            EmptyView()
        }
    ) -> some View {
        if let content, let style {
            renderer(content, style)
        } else {
            elseRenderer()
        }
    }
}
