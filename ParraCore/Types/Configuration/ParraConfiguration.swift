//
//  ParraConfiguration.swift
//  ParraCore
//
//  Created by Mick MacCallum on 11/26/22.
//  Copyright © 2022 Parra, Inc. All rights reserved.
//

import Foundation

public struct ParraConfiguration {
    public let loggerConfig: ParraLoggerConfig
    public internal(set) var tenantId: String?

    // Public version of this initializer should be kept up to date to include
    // all fields except for tenantId.
    public init(loggerConfig: ParraLoggerConfig) {
        self.loggerConfig = loggerConfig
        self.tenantId = nil
    }

    public static let `default` = ParraConfiguration(
        loggerConfig: .default
    )

    internal mutating func setTenantId(_ tenantId: String?) {
        self.tenantId = tenantId
    }
}
