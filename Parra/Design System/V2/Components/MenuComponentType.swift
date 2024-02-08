//
//  MenuComponentType.swift
//  Parra
//
//  Created by Mick MacCallum on 2/5/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

protocol MenuComponentType: View {
    var config: MenuConfig { get }
    var content: MenuContent { get }
    var style: ParraAttributedMenuStyle { get }

    init(
        config: MenuConfig,
        content: MenuContent,
        style: ParraAttributedMenuStyle
    )

    static func applyStandardCustomizations(
        onto inputAttributes: MenuAttributes?,
        theme: ParraTheme,
        config: MenuConfig
    ) -> MenuAttributes
}
