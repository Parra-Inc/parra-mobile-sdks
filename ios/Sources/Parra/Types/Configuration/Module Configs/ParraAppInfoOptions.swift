//
//  ParraAppInfoOptions.swift
//  Parra
//
//  Created by Mick MacCallum on 3/24/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import Foundation

public struct ParraAppInfoOptions: ParraConfigurationOptionType {
    // MARK: - Lifecycle

    public init(bundleId: String) {
        self.bundleId = bundleId
    }

    // MARK: - Public

    public static var `default`: ParraAppInfoOptions = .init(
        bundleId: Bundle.main.bundleIdentifier ?? "unknown"
    )

    /// The bundle identifier of the app. This is used in requests to Parra's
    /// servers to identify traffic and in other areas, like checking for latest
    /// updates from Apple for "What's new" functionality. By default, this will
    /// be the bundle identifier from ``Bundle/main`` but can be overridden here
    /// if you have a custom configuartion or beta environments that you want to
    /// handle differently.
    public let bundleId: String
}
