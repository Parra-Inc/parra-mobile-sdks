//
//  AuthenticationWidgetConfig.swift
//  Tests
//
//  Created by Mick MacCallum on 4/16/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

public class ParraAuthConfig: ContainerConfig {
    // MARK: - Lifecycle

    required init() {
        self.appIcon = ParraAuthConfig.default.appIcon
    }

    public init(
        appIcon: ParraImageContent?
    ) {
        self.appIcon = appIcon
    }

    // MARK: - Public

    public static let `default` = ParraAuthConfig(
        appIcon: nil
    )

    public let appIcon: ParraImageContent?
}
