//
//  View+applyImageAttributes.swift
//  Parra
//
//  Created by Mick MacCallum on 5/14/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

public extension View {
    @ViewBuilder
    func applyImageAttributes(
        _ attributes: ParraAttributes.Image,
        using theme: ParraTheme
    ) -> some View {
        withFrame(attributes.size)
            .foregroundStyle(
                attributes.tint ?? theme.palette.secondary.toParraColor()
            )
            .opacity(attributes.opacity ?? 1.0)
            .applyCommonViewAttributes(attributes, from: theme)
    }

    @ViewBuilder
    func applyAsyncImageAttributes(
        _ attributes: ParraAttributes.AsyncImage,
        using theme: ParraTheme
    ) -> some View {
        withFrame(attributes.size)
            .foregroundStyle(
                attributes.tint ?? theme.palette.secondary.toParraColor()
            )
            .opacity(attributes.opacity ?? 1.0)
            .applyCommonViewAttributes(attributes, from: theme)
    }

    @ViewBuilder
    private func withFrame(
        _ size: CGSize?
    ) -> some View {
        if let size {
            frame(width: size.width, height: size.height)
        } else {
            self
        }
    }
}
