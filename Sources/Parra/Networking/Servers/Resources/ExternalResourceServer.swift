//
//  ExternalResourceServer.swift
//  Parra
//
//  Created by Mick MacCallum on 4/11/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import Foundation

final class ExternalResourceServer: Server {
    // MARK: - Lifecycle

    init(configuration: ServerConfiguration) {
        self.configuration = configuration
    }

    // MARK: - Internal

    let configuration: ServerConfiguration
}
