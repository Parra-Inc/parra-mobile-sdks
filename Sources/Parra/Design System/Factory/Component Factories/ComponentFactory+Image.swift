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
        content: ParraImageContent
    ) -> some View {
        let attributes = attributeProvider.imageAttributes(
            content: content
        )

        ImageComponent(
            content: content,
            attributes: attributes
        )
    }

    @ViewBuilder
    func buildAsyncImage(
        content: AsyncImageContent
    ) -> some View {
        let attributes = attributeProvider.asyncImageAttributes(
            content: content
        )

        AsyncImageComponent(
            content: content,
            attributes: attributes
        )
    }
}
