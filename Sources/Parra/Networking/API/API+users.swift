//
//  API+users.swift
//  Parra
//
//  Created by Mick MacCallum on 5/1/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import Foundation
import UIKit

private let logger = Logger()

extension API {
    func uploadAvatar(
        image: UIImage
    ) async throws -> ImageAssetStub {
        let imageField = try MultipartFormField(
            name: "image", // server side requirement
            image: image
        )

        return try await hitUploadEndpoint(
            .postUpdateAvatar,
            cachePolicy: .reloadIgnoringLocalAndRemoteCacheData,
            formFields: [imageField]
        )
    }

    func deleteAvatar() async throws {
        logger.debug("Deleting user avatar")

        guard let user = await dataManager.getCurrentUser()?.userInfo else {
            throw ParraError.message("Can not delete account. Not logged in.")
        }

        let _: EmptyResponseObject = try await hitEndpoint(
            .deleteAvatar(userId: user.id),
            cachePolicy: .reloadIgnoringLocalAndRemoteCacheData
        )
    }

    func deleteAccount() async throws {
        logger.warn("Preparing to delete account")

        guard let user = await dataManager.getCurrentUser()?.userInfo else {
            throw ParraError.message("Can not delete account. Not logged in.")
        }

        let _: EmptyResponseObject = try await hitEndpoint(
            .deleteUser(userId: user.id),
            cachePolicy: .reloadIgnoringLocalAndRemoteCacheData
        )
    }
}
