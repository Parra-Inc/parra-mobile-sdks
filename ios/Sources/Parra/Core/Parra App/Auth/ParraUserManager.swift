//
//  ParraUserManager.swift
//  Parra
//
//  Created by Mick MacCallum on 7/19/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import Foundation
import UIKit

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

        ParraUserProperties.shared.forceSetStore(updated.properties)
        ParraUserSettings.shared.updateStore(updated.settings)
    }

    /// Uploads the provided image and assigns it as the user's profile picture.
    /// Pass `nil` to delete the user's current profile picture.
    public func updateUserProfilePicture(
        _ image: UIImage?
    ) async throws {
        if let image {
            let resized = image.resized()
            let asset = try await parraInternal.api.uploadAvatar(
                image: resized
            )

            await parraInternal.api.cacheAsset(asset)
        } else {
            try await parraInternal.api.deleteAvatar()
        }

        try await parraInternal.authService.refreshUserInfo()
    }

    // MARK: - Internal

    let parraInternal: ParraInternal
}
