//
//  ExternalResourceServer.swift
//  Parra
//
//  Created by Mick MacCallum on 4/11/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import Foundation

@MainActor
final class ExternalResourceServer: Server {
    // MARK: - Lifecycle

    init(
        configuration: ServerConfiguration,
        appState: ParraAppState,
        appConfig: ParraConfiguration

    ) {
        self.configuration = configuration
        self.appState = appState
        self.appConfig = appConfig
    }

    // MARK: - Internal

    let configuration: ServerConfiguration
    let appState: ParraAppState
    let appConfig: ParraConfiguration

    weak var delegate: ServerDelegate?

    lazy var urlSessionDelegateProxy: UrlSessionDelegateProxy =
        .init(
            delegate: self
        )
}
