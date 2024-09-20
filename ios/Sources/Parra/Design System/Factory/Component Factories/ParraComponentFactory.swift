//
//  ParraComponentFactory.swift
//  Parra
//
//  Created by Mick MacCallum on 1/28/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

@Observable
public class ParraComponentFactory {
    // MARK: - Lifecycle

    init(
        attributes: ComponentAttributesProvider =
            ParraGlobalComponentAttributes(),
        theme: ParraTheme
    ) {
        self.attributeProvider = attributes
        self.theme = theme
    }

    // MARK: - Public

    public let attributeProvider: ComponentAttributesProvider
    public let theme: ParraTheme

    // MARK: - Internal

    static let `default` = ParraComponentFactory(theme: .default)
}
