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
    ) async throws -> ParraImageAssetStub {
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

        guard let userInfo = await dataManager.getCurrentUser()?.info else {
            throw ParraError.message("Can not delete account. Not logged in.")
        }

        let _: EmptyResponseObject = try await hitEndpoint(
            .deleteAvatar(userId: userInfo.id),
            cachePolicy: .reloadIgnoringLocalAndRemoteCacheData
        )
    }

    func getUserInfo(
        timeout: TimeInterval? = nil
    ) async throws -> UserInfoResponse {
        return try await hitEndpoint(.getUserInfo, timeout: timeout)
    }

    func updateUserInfo(
        name: String? = nil,
        firstName: String? = nil,
        lastName: String? = nil
    ) async throws -> ParraUser.Info {
        let requestBody = UpdateUserRequestBody(
            firstName: firstName,
            lastName: lastName,
            name: name
        )

        guard let userInfo = await dataManager.getCurrentUser()?.info else {
            throw ParraError.message("Can not delete account. Not logged in.")
        }

        return try await hitEndpoint(
            .updateUserInfo(userId: userInfo.id),
            cachePolicy: .reloadIgnoringLocalAndRemoteCacheData,
            body: requestBody
        )
    }

    func logout() async throws -> AuthLogoutResponseBody {
        return try await hitEndpoint(
            .postLogout,
            cachePolicy: .reloadIgnoringLocalAndRemoteCacheData
        )
    }

    func deleteAccount() async throws {
        logger.warn("Preparing to delete account")

        guard let userInfo = await dataManager.getCurrentUser()?.info else {
            throw ParraError.message("Can not delete account. Not logged in.")
        }

        let _: EmptyResponseObject = try await hitEndpoint(
            .deleteUser(userId: userInfo.id),
            cachePolicy: .reloadIgnoringLocalAndRemoteCacheData
        )
    }
}
