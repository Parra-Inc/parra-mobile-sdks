//
//  AuthenticatedRequestAttributeOptions.swift
//  Parra
//
//  Created by Mick MacCallum on 6/24/23.
//  Copyright © 2023 Parra, Inc. All rights reserved.
//

import Foundation

struct AuthenticatedRequestAttributeOptions: OptionSet {
    // MARK: Lifecycle

    init(rawValue: Int) {
        self.rawValue = rawValue
    }

    // MARK: Internal

    static let requiredReauthentication = AuthenticatedRequestAttributeOptions(
        rawValue: 1 << 0
    )

    static let requiredRetry = AuthenticatedRequestAttributeOptions(
        rawValue: 1 << 1
    )

    static let exceededRetryLimit = AuthenticatedRequestAttributeOptions(
        rawValue: 1 << 2
    )

    let rawValue: Int
}
