//
//  ComponentFactory+Menus.swift
//  Parra
//
//  Created by Mick MacCallum on 3/7/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

extension ComponentFactory {
    @ViewBuilder
    func buildMenu(
        config: MenuConfig,
        content: MenuContent,
        localAttributes: ParraAttributes.Menu? = nil
    ) -> some View {
        let attributes = attributeProvider.menuAttributes(
            localAttributes: localAttributes,
            theme: theme
        )

        MenuComponent(
            config: config,
            content: content,
            attributes: attributes
        )
    }
}
