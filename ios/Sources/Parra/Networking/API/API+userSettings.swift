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
        return try await hitEndpoint(
            .getUserSettingsLayouts,
            cachePolicy: .init(.reloadIgnoringLocalAndRemoteCacheData)
        )
    }

    func getSettingsLayout(
        layoutId: String
    ) async throws -> ParraUserSettingsLayout {
        return try await hitEndpoint(
            .getUserSettingsLayout(layoutId: layoutId),
            cachePolicy: .init(.reloadIgnoringLocalAndRemoteCacheData)
        )
    }
}
