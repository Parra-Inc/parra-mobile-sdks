//
//  ImageAttributes.swift
//  Parra
//
//  Created by Mick MacCallum on 3/4/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

public struct ImageAttributes: ParraStyleAttributes {
    // MARK: - Lifecycle

    public init(
        background: (any ShapeStyle)? = nil,
        cornerRadius: ParraCornerRadiusSize? = nil,
        tint: Color? = nil,
        opacity: Double? = nil,
        padding: EdgeInsets? = nil
    ) {
        self.background = background
        self.cornerRadius = cornerRadius
        self.tint = tint
        self.opacity = opacity
        self.padding = padding
        self.frame = nil
        self.borderWidth = nil
        self.borderColor = nil
    }

    init(
        background: (any ShapeStyle)? = nil,
        cornerRadius: ParraCornerRadiusSize? = nil,
        tint: Color? = nil,
        opacity: Double? = nil,
        padding: EdgeInsets? = nil,
        frame: FrameAttributes? = nil,
        borderWidth: CGFloat? = nil,
        borderColor: Color? = nil
    ) {
        self.background = background
        self.cornerRadius = cornerRadius
        self.tint = tint
        self.opacity = opacity
        self.padding = padding
        self.frame = frame
        self.borderWidth = borderWidth
        self.borderColor = borderColor
    }

    // MARK: - Public

    public let background: (any ShapeStyle)?
    public let cornerRadius: ParraCornerRadiusSize?
    public let tint: Color?
    public let opacity: Double?
    public let padding: EdgeInsets?

    // MARK: - Internal

    let frame: FrameAttributes?
    let borderWidth: CGFloat?
    let borderColor: Color?
}
