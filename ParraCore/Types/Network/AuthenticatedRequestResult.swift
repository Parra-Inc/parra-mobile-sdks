//
//  AuthenticatedRequestResult.swift
//  ParraCore
//
//  Created by Mick MacCallum on 6/24/23.
//  Copyright © 2023 Parra, Inc. All rights reserved.
//

import Foundation

public struct AuthenticatedRequestResult<T: Decodable> {
    public let result: Result<T, Error>
    public let attributes: AuthenticatedRequestAttributeOptions

    init(result: Result<T, Error>,
         responseAttributes: AuthenticatedRequestAttributeOptions = []) {

        self.result = result
        self.attributes = responseAttributes
    }
}
