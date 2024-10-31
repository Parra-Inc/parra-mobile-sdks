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
        appConfig: ParraConfiguration,
        dataManager: DataManager
    ) {
        self.configuration = configuration
        self.appState = appState
        self.appConfig = appConfig
        self.dataManager = dataManager
    }

    // MARK: - Internal

    let configuration: ServerConfiguration
    let appState: ParraAppState
    let appConfig: ParraConfiguration
    let dataManager: DataManager

    weak var delegate: ServerDelegate?

    lazy var urlSessionDelegateProxy: UrlSessionDelegateProxy =
        .init(
            delegate: self
        )
}
