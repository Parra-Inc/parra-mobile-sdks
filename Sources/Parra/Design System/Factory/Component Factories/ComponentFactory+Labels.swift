//
//  ComponentFactory+Labels.swift
//  Parra
//
//  Created by Mick MacCallum on 3/7/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

extension ComponentFactory {
    @ViewBuilder
    func buildLabel(
        fontStyle: ParraTextStyle,
        content: LabelContent
    ) -> LabelComponent {
        let attributes = attributeProvider.labelAttributes(
            for: fontStyle,
            theme: theme
        )

        LabelComponent(
            content: content,
            attributes: attributes
        )
    }
}
