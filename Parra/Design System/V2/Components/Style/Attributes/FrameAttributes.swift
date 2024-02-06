//
//  FrameAttributes.swift
//  Parra
//
//  Created by Mick MacCallum on 1/31/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

internal struct FrameAttributes {
    internal let minWidth: CGFloat?
    internal let idealWidth: CGFloat?
    internal let maxWidth: CGFloat?
    internal let minHeight: CGFloat?
    internal let idealHeight: CGFloat?
    internal let maxHeight: CGFloat?
    internal let alignment: Alignment

    internal init(
        minWidth: CGFloat? = nil,
        idealWidth: CGFloat? = nil,
        maxWidth: CGFloat? = nil,
        minHeight: CGFloat? = nil,
        idealHeight: CGFloat? = nil,
        maxHeight: CGFloat? = nil,
        alignment: Alignment = .center
    ) {
        self.minWidth = minWidth
        self.idealWidth = idealWidth
        self.maxWidth = maxWidth
        self.minHeight = minHeight
        self.idealHeight = idealHeight
        self.maxHeight = maxHeight
        self.alignment = alignment
    }
}
