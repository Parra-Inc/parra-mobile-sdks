//
//  ComponentFactory+Menus.swift
//  Parra
//
//  Created by Mick MacCallum on 3/7/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

public extension ParraComponentFactory {
    @ViewBuilder
    func buildMenu(
        config: ParraMenuConfig,
        content: ParraMenuContent,
        localAttributes: ParraAttributes.Menu? = nil
    ) -> ParraMenuComponent {
        let attributes = attributeProvider.menuAttributes(
            localAttributes: localAttributes,
            theme: theme
        )

        return ParraMenuComponent(
            config: config,
            content: content,
            attributes: attributes
        )
    }
}
