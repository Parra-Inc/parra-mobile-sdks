//
//  ParraUserManager.swift
//  Parra
//
//  Created by Mick MacCallum on 7/19/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import Foundation

public final class ParraUserManager: ObservableObject {
    // MARK: - Lifecycle

    init(parraInternal: ParraInternal) {
        self.parraInternal = parraInternal
    }

    // MARK: - Public

    /// Updates the provided personal info on the current user. Any fields that
    /// are unset will be removed from the user.
    public func updatePersonalInfo(
        name: String? = nil,
        firstName: String? = nil,
        lastName: String? = nil
    ) async throws {
        let updated = try await parraInternal.api.updateUserInfo(
            name: name,
            firstName: firstName,
            lastName: lastName
        )

        try await parraInternal.authService.applyUserInfoUpdate(updated)
    }

    // MARK: - Internal

    let parraInternal: ParraInternal
}
