//
//  ProfileWidgetConfig.swift
//  Parra
//
//  Created by Mick MacCallum on 5/1/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

public class ProfileWidgetConfig: ContainerConfig {
    // MARK: - Lifecycle

    required init() {
        self.title = ProfileWidgetConfig.default.title
    }

    public init(
        title: LabelConfig = ProfileWidgetConfig.default.title
    ) {
        self.title = title
    }

    // MARK: - Public

    public static let `default` = ProfileWidgetConfig(
        title: LabelConfig(fontStyle: .largeTitle)
    )

    public let title: LabelConfig
}
