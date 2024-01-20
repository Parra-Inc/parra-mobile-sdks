//
//  ParraState.swift
//  ParraTests
//
//  Created by Mick MacCallum on 7/3/23.
//  Copyright © 2023 Parra, Inc. All rights reserved.
//

import Foundation
@testable import Parra

extension ParraState {
    static let initialized = ParraState(initialized: true)
    static let uninitialized = ParraState(initialized: false)
}

extension ParraConfigState {
    static func initialized(
        tenantId: String,
        applicationId: String
    ) -> ParraConfigState {
        var config = ParraConfiguration.default

        config.setTenantId(tenantId)
        config.setApplicationId(applicationId)

        return ParraConfigState(
            currentState: config
        )
    }
}
