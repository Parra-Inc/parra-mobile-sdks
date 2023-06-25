//
//  AuthenticatedRequestAttributeOptions.swift
//  Parra
//
//  Created by Mick MacCallum on 6/24/23.
//  Copyright © 2023 Parra, Inc. All rights reserved.
//

import Foundation

public struct AuthenticatedRequestAttributeOptions: OptionSet {
    public let rawValue: Int

    public static let requiredReauthentication = AuthenticatedRequestAttributeOptions(rawValue: 1 << 0)
    public static let requiredRetry = AuthenticatedRequestAttributeOptions(rawValue: 1 << 1)
    public static let exceededRetryLimit = AuthenticatedRequestAttributeOptions(rawValue: 1 << 2)

    public init(rawValue: Int) {
        self.rawValue = rawValue
    }
}
