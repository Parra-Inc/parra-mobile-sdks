//
//  ParraPushNotificationOptions.swift
//  Parra
//
//  Created by Mick MacCallum on 3/23/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import Foundation

public struct ParraPushNotificationOptions: ParraConfigurationOptionType {
    // MARK: - Lifecycle

    public init(enabled: Bool) {
        self.enabled = enabled
    }

    // MARK: - Public

    public static var `default`: ParraPushNotificationOptions = .init(
        enabled: false
    )

    public let enabled: Bool
}
