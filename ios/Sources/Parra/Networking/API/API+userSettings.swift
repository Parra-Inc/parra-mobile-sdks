//
//  API+userSettings.swift
//  Parra
//
//  Created by Mick MacCallum on 10/29/24.
//

import Combine
import Foundation

extension API {
    func getSettingsLayouts() async throws -> [ParraUserSettingsLayout] {
        guard let userInfo = await dataManager.getCurrentUser()?.info else {
            throw ParraError.message(
                "Can not get settings layouts. Not logged in."
            )
        }

        return try await hitEndpoint(
            .getUserSettingsLayouts(userId: userInfo.id),
            cachePolicy: .init(.reloadIgnoringLocalAndRemoteCacheData)
        )
    }

    func getSettingsLayout(
        layoutId: String
    ) async throws -> ParraUserSettingsLayout {
        guard let userInfo = await dataManager.getCurrentUser()?.info else {
            throw ParraError.message(
                "Can not get settings layout. Not logged in."
            )
        }

        return try await hitEndpoint(
            .getUserSettingsLayout(userId: userInfo.id, layoutId: layoutId),
            cachePolicy: .init(.reloadIgnoringLocalAndRemoteCacheData)
        )
    }
}
