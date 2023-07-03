//
//  NetworkManagerType.swift
//  Parra
//
//  Created by Mick MacCallum on 6/24/23.
//  Copyright © 2023 Parra, Inc. All rights reserved.
//

import Foundation

internal protocol NetworkManagerType: ParraModuleStateAccessor {
    init(
        state: ParraState,
        configState: ParraConfigState,
        dataManager: ParraDataManager,
        urlSession: URLSessionType,
        jsonEncoder: JSONEncoder,
        jsonDecoder: JSONDecoder
    )

    func updateAuthenticationProvider(_ provider: ParraAuthenticationProviderFunction?) async
    func getAuthenticationProvider() async -> ParraAuthenticationProviderFunction?
    func refreshAuthentication() async throws -> ParraCredential
}
