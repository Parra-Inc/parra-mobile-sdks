//
//  ComponentFactory+Image.swift
//  Parra
//
//  Created by Mick MacCallum on 5/7/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

extension ComponentFactory {
    @ViewBuilder
    func buildImage(
        content: ParraImageContent,
        localAttributes: ParraAttributes.Image? = nil
    ) -> some View {
        let attributes = attributeProvider.imageAttributes(
            content: content,
            localAttributes: localAttributes,
            theme: theme
        )

        ImageComponent(
            content: content,
            attributes: attributes
        )
    }

    @ViewBuilder
    func buildAsyncImage(
        content: AsyncImageContent,
        localAttributes: ParraAttributes.AsyncImage? = nil
    ) -> some View {
        let attributes = attributeProvider.asyncImageAttributes(
            content: content,
            localAttributes: localAttributes,
            theme: theme
        )

        AsyncImageComponent(
            content: content,
            attributes: attributes
        )
    }
}
