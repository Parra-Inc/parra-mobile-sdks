//
//  ParraGlobalComponentAttributes+Image.swift
//  Parra
//
//  Created by Mick MacCallum on 5/7/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import Foundation

public extension ParraGlobalComponentAttributes {
    func imageAttributes(
        content: ParraImageContent,
        localAttributes: ParraAttributes.Image?,
        theme: ParraTheme
    ) -> ParraAttributes.Image {
        return ParraAttributes.Image().mergingOverrides(localAttributes)
    }

    func asyncImageAttributes(
        content: AsyncImageContent,
        localAttributes: ParraAttributes.AsyncImage?,
        theme: ParraTheme
    ) -> ParraAttributes.AsyncImage {
        return ParraAttributes.AsyncImage().mergingOverrides(localAttributes)
    }
}
