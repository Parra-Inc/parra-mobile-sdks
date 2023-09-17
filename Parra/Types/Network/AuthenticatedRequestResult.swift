//
//  AuthenticatedRequestResult.swift
//  Parra
//
//  Created by Mick MacCallum on 6/24/23.
//  Copyright © 2023 Parra, Inc. All rights reserved.
//

import Foundation

internal struct AuthenticatedRequestResult<T: Decodable> {
    internal let result: Result<T, Error>
    internal let attributes: AuthenticatedRequestAttributeOptions

    internal init(
        result: Result<T, Error>,
        responseAttributes: AuthenticatedRequestAttributeOptions = []
    ) {
        self.result = result
        self.attributes = responseAttributes
    }
}
