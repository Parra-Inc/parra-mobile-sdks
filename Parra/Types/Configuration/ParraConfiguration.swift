//
//  ParraConfiguration.swift
//  Parra
//
//  Created by Mick MacCallum on 11/26/22.
//  Copyright © 2022 Parra, Inc. All rights reserved.
//

import Foundation

public struct ParraConfiguration {
    public let loggerConfig: ParraLoggerConfig
    public internal(set) var tenantId: String?
    public internal(set) var applicationId: String?

    // Public version of this initializer should be kept up to date to include
    // all fields except for tenantId and applicationId
    public init(loggerConfig: ParraLoggerConfig) {
        self.loggerConfig = loggerConfig
        self.tenantId = nil
        self.applicationId = nil
    }

    public static let `default` = ParraConfiguration(
        loggerConfig: .default
    )

    internal mutating func setTenantId(_ tenantId: String?) {
        self.tenantId = tenantId
    }

    internal mutating func setApplicationId(_ applicationId: String?) {
        self.applicationId = applicationId
    }
}
