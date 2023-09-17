//
//  AuthenticatedRequestAttributeOptions.swift
//  Parra
//
//  Created by Mick MacCallum on 6/24/23.
//  Copyright © 2023 Parra, Inc. All rights reserved.
//

import Foundation

internal struct AuthenticatedRequestAttributeOptions: OptionSet {
    internal let rawValue: Int

    internal static let requiredReauthentication = AuthenticatedRequestAttributeOptions(
        rawValue: 1 << 0
    )
    
    internal static let requiredRetry = AuthenticatedRequestAttributeOptions(
        rawValue: 1 << 1
    )
    
    internal static let exceededRetryLimit = AuthenticatedRequestAttributeOptions(
        rawValue: 1 << 2
    )

    internal init(rawValue: Int) {
        self.rawValue = rawValue
    }
}
