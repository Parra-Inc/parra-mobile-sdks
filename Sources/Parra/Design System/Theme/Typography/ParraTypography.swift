//
//  ParraTypography.swift
//  Parra
//
//  Created by Mick MacCallum on 1/20/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

public struct ParraTypography {
    // MARK: - Public

    public static let `default` = ParraTypography(
        textStyles: [:]
    )

    // MARK: - Internal

    let textStyles: [Font.TextStyle: ParraAttributes.Text]

    func getTextAttributes(
        for fontStyle: Font.TextStyle?
    ) -> ParraAttributes.Text? {
        guard let fontStyle else {
            return nil
        }

        return textStyles[fontStyle]
    }
}
