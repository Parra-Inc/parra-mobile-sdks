//
//  ParraUserManager.swift
//  Parra
//
//  Created by Mick MacCallum on 7/19/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import Foundation

public final class ParraUserManager {
    // MARK: - Lifecycle

    init(parraInternal: ParraInternal) {
        self.parraInternal = parraInternal
    }

    // MARK: - Public

    /// Performs an update on the info for the current user. `name`, `firstName`
    /// and `lastName` will be removed if `nil` is passed. For `properties`,
    /// passing `nil` has no effect. If `properties` is provided, it will be
    /// merged with any existing user properties.
    public func updateUser(
        name: String? = nil,
        firstName: String? = nil,
        lastName: String? = nil,
        properties: [String: ParraAnyCodable]? = nil
    ) async throws {
        let updated = try await parraInternal.api.updateUserInfo(
            name: name,
            firstName: firstName,
            lastName: lastName,
            properties: properties
        )

        try await parraInternal.authService.applyUserInfoUpdate(updated)

        await ParraUserProperties.shared.forceSetStore(updated.properties)
    }

    // MARK: - Internal

    let parraInternal: ParraInternal
}
