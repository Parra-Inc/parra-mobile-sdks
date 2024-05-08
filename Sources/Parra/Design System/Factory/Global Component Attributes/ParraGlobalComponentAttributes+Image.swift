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
        content: ParraImageContent
    ) -> ParraAttributes.Image {
        return ParraAttributes.Image()
    }

    func asyncImageAttributes(
        content: AsyncImageContent
    ) -> ParraAttributes.AsyncImage {
        return ParraAttributes.AsyncImage()
    }
}
