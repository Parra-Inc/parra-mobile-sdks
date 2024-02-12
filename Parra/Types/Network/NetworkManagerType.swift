//
//  NetworkManagerType.swift
//  Parra
//
//  Created by Mick MacCallum on 6/24/23.
//  Copyright © 2023 Parra, Inc. All rights reserved.
//

import Foundation

protocol NetworkManagerType {
    init(
        appState: ParraAppState,
        dataManager: ParraDataManager,
        configuration: ParraInstanceNetworkConfiguration
    )

    func updateAuthenticationProvider(
        _ provider: ParraAuthenticationProviderFunction?
    ) async

    func getAuthenticationProvider() async
        -> ParraAuthenticationProviderFunction?

    func refreshAuthentication() async throws -> ParraCredential
}
