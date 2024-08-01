//
//  ParraAttributes+Image.swift
//  Parra
//
//  Created by Mick MacCallum on 5/7/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

public extension ParraAttributes {
    struct Image: ParraCommonViewAttributes {
        // MARK: - Lifecycle

        public init(
            tint: Color? = nil,
            opacity: CGFloat? = nil,
            size: CGSize? = nil,
            border: ParraAttributes.Border = .init(),
            cornerRadius: ParraCornerRadiusSize? = nil,
            padding: ParraPaddingSize? = nil,
            background: Color? = nil
        ) {
            self.tint = tint
            self.opacity = opacity
            self.size = size
            self.border = border
            self.cornerRadius = cornerRadius
            self.padding = padding
            self.background = background
        }

        // MARK: - Public

        public internal(set) var tint: Color?
        public internal(set) var opacity: CGFloat?
        public internal(set) var size: CGSize?
        public internal(set) var border: ParraAttributes.Border
        public internal(set) var cornerRadius: ParraCornerRadiusSize?
        public internal(set) var padding: ParraPaddingSize?
        public internal(set) var background: Color?
    }

    struct AsyncImage: ParraCommonViewAttributes {
        // MARK: - Lifecycle

        public init(
            tint: Color? = nil,
            opacity: CGFloat? = nil,
            size: CGSize? = nil,
            border: ParraAttributes.Border = .init(),
            cornerRadius: ParraCornerRadiusSize? = nil,
            padding: ParraPaddingSize? = nil,
            background: Color? = nil
        ) {
            self.tint = tint
            self.opacity = opacity
            self.size = size
            self.border = border
            self.cornerRadius = cornerRadius
            self.padding = padding
            self.background = background
        }

        // MARK: - Public

        public internal(set) var tint: Color?
        public internal(set) var opacity: CGFloat?
        public internal(set) var size: CGSize?
        public internal(set) var border: ParraAttributes.Border
        public internal(set) var cornerRadius: ParraCornerRadiusSize?
        public internal(set) var padding: ParraPaddingSize?
        public internal(set) var background: Color?
    }
}

// MARK: - ParraAttributes.Image + OverridableAttributes

extension ParraAttributes.Image: OverridableAttributes {
    func mergingOverrides(
        _ overrides: ParraAttributes.Image?
    ) -> ParraAttributes.Image {
        ParraAttributes.Image(
            tint: overrides?.tint ?? tint,
            opacity: overrides?.opacity ?? opacity,
            size: overrides?.size ?? size,
            border: border.mergingOverrides(overrides?.border),
            cornerRadius: overrides?.cornerRadius ?? cornerRadius,
            padding: overrides?.padding ?? padding,
            background: overrides?.background ?? background
        )
    }
}

// MARK: - ParraAttributes.AsyncImage + OverridableAttributes

extension ParraAttributes.AsyncImage: OverridableAttributes {
    func mergingOverrides(
        _ overrides: ParraAttributes.AsyncImage?
    ) -> ParraAttributes.AsyncImage {
        ParraAttributes.AsyncImage(
            tint: overrides?.tint ?? tint,
            opacity: overrides?.opacity ?? opacity,
            size: overrides?.size ?? size,
            border: border.mergingOverrides(overrides?.border),
            cornerRadius: overrides?.cornerRadius ?? cornerRadius,
            padding: overrides?.padding ?? padding,
            background: overrides?.background ?? background
        )
    }
}
