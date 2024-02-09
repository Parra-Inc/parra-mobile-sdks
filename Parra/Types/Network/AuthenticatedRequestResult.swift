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
        responseAttributes: AuthenticatedRequestAttributeOptions = []
    ) {
        self.result = result
        self.attributes = responseAttributes
    }

    // MARK: - Internal

    let result: Result<T, Error>
    let attributes: AuthenticatedRequestAttributeOptions
}
