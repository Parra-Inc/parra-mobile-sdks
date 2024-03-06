//
//  AuthenticatedRequestResponseContext.swift
//  Parra
//
//  Created by Mick MacCallum on 3/6/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import Foundation

struct AuthenticatedRequestResponseContext {
    let attributes: AuthenticatedRequestAttributeOptions

    /// The HTTP status code of the request. Only unset if the request failed
    /// due to exception
    let statusCode: Int?
}
