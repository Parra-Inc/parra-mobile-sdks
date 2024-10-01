//
//  ParraAttributes+LoadingIndicator.swift
//  Parra
//
//  Created by Mick MacCallum on 6/21/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

// MARK: - ParraAttributes.LoadingIndicator

public extension ParraAttributes {
    struct LoadingIndicator {
        // MARK: - Lifecycle

        public init(
            title: ParraAttributes.Label = .init(),
            subtitle: ParraAttributes.Label = .init(),
            cancelButton: ParraAttributes.PlainButton = .init(),
            border: ParraAttributes.Border = .init(),
            cornerRadius: ParraCornerRadiusSize? = nil,
            padding: ParraPaddingSize? = nil,
            background: Color? = nil
        ) {
            self.title = title
            self.subtitle = subtitle
            self.cancelButton = cancelButton
            self.border = border
            self.cornerRadius = cornerRadius
            self.padding = padding
            self.background = background
        }

        // MARK: - Public

        public let title: ParraAttributes.Label
        public let subtitle: ParraAttributes.Label
        public let cancelButton: ParraAttributes.PlainButton

        public var border: ParraAttributes.Border
        public var cornerRadius: ParraCornerRadiusSize?
        public var padding: ParraPaddingSize?
        public var background: Color?
    }
}

// MARK: - ParraAttributes.LoadingIndicator + OverridableAttributes

extension ParraAttributes.LoadingIndicator: OverridableAttributes {
    func mergingOverrides(
        _ overrides: ParraAttributes.LoadingIndicator?
    ) -> ParraAttributes.LoadingIndicator {
        return ParraAttributes.LoadingIndicator(
            title: title.mergingOverrides(overrides?.title),
            subtitle: subtitle.mergingOverrides(overrides?.subtitle),
            cancelButton: cancelButton.mergingOverrides(
                overrides?.cancelButton
            ),
            border: border.mergingOverrides(overrides?.border),
            cornerRadius: overrides?.cornerRadius ?? cornerRadius,
            padding: overrides?.padding ?? padding,
            background: overrides?.background ?? background
        )
    }
}
