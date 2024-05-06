//
//  SegmentAttributes.swift
//  Parra
//
//  Created by Mick MacCallum on 2/29/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

public struct SegmentAttributes: ParraStyleAttributes {
    // MARK: - Lifecycle

    init(
        optionLabels: LabelAttributes = .init(),
        optionLabelBackgroundColor: Color? = nil,
        optionLabelSelectedBackgroundColor: Color? = nil,
        optionLabelSelectedFontColor: Color? = nil,
        cornerRadius: ParraCornerRadiusSize? = nil,
        padding: EdgeInsets? = nil,
        borderWidth: CGFloat? = nil,
        borderColor: Color? = nil
    ) {
        self.optionLabels = optionLabels
        self.optionLabelBackgroundColor = optionLabelBackgroundColor
        self
            .optionLabelSelectedBackgroundColor =
            optionLabelSelectedBackgroundColor
        self.optionLabelSelectedFontColor = optionLabelSelectedFontColor
        self.cornerRadius = cornerRadius
        self.padding = padding
        self.borderWidth = borderWidth
        self.borderColor = borderColor
    }

    // MARK: - Public

    /// Attributes to use on the labels for the segment's options in the
    /// unselected state.
    public let optionLabels: LabelAttributes

    public let optionLabelBackgroundColor: Color?
    public let optionLabelSelectedBackgroundColor: Color?
    public let optionLabelSelectedFontColor: Color?

    public let cornerRadius: ParraCornerRadiusSize?
    public let padding: EdgeInsets?

    public let borderWidth: CGFloat?
    public let borderColor: Color?
}
