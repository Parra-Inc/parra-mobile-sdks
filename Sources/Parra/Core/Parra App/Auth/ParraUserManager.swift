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

    /// An object representing the currently logged in user, if one exists.
    /// This is only relevant to Parra Auth.
    @Published public internal(set) var current: ParraUser?

    /// Updates the provided personal info on the current user. Any fields that
    /// are unset will be removed from the user.
    public func updatePersonalInfo(
        name: String? = nil,
        firstName: String? = nil,
        lastName: String? = nil
    ) async throws {
        guard current != nil else {
            throw ParraError.unauthenticated
        }

        let updated = try await parraInternal.api.updateUserInfo(
            name: name ?? "null",
            firstName: firstName ?? "null",
            lastName: lastName ?? "null"
        )

        try await parraInternal.authService.applyUserInfoUpdate(updated)

        objectWillChange.send()
    }

    // MARK: - Internal

    let parraInternal: ParraInternal
}
