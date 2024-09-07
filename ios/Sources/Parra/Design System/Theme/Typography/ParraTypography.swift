//
//  ParraTypography.swift
//  Parra
//
//  Created by Mick MacCallum on 1/20/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

public struct ParraTypography {
    // MARK: - Lifecycle

    public init(textStyles: [Font.TextStyle: ParraAttributes.Text]) {
        self.textStyles = textStyles
    }

    // MARK: - Public

    public static let `default` = ParraTypography(
        textStyles: [:]
    )

    public let textStyles: [Font.TextStyle: ParraAttributes.Text]

    // MARK: - Internal

    func getTextAttributes(
        for fontStyle: Font.TextStyle?
    ) -> ParraAttributes.Text? {
        guard let fontStyle else {
            return nil
        }

        return textStyles[fontStyle]
    }
}
