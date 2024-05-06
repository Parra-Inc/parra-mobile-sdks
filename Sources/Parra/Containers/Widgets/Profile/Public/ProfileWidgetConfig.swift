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
        self.settingsEnabled = ProfileWidgetConfig.default.settingsEnabled
    }

    public init(
        settingsEnabled: Bool = ProfileWidgetConfig.default.settingsEnabled
    ) {
        self.settingsEnabled = settingsEnabled
    }

    // MARK: - Public

    public static let `default` = ProfileWidgetConfig(
        settingsEnabled: true
    )

    public let settingsEnabled: Bool
}
