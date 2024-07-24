//
//  AuthenticatedRequestResult.swift
//  Parra
//
//  Created by Mick MacCallum on 6/24/23.
//  Copyright © 2023 Parra, Inc. All rights reserved.
//

import Foundation

struct AuthenticatedRequestResult<T: Decodable> {
    // MARK: - Lifecycle

    init(
        result: Result<T, Error>,
        responseContext: AuthenticatedRequestResponseContext
    ) {
        self.result = result
        self.context = responseContext
    }

    // MARK: - Internal

    let result: Result<T, Error>
    let context: AuthenticatedRequestResponseContext
}
