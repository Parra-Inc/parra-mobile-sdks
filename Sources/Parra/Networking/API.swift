//
//  API.swift
//  Parra
//
//  Created by Mick MacCallum on 4/11/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import Foundation

final class API {
    // MARK: - Lifecycle

    init(
        apiResourceServer: ApiResourceServer
    ) {
        self.apiResourceServer = apiResourceServer
    }

    // MARK: - Private

    private let apiResourceServer: ApiResourceServer
}
