//
//  RequestConfig.swift
//  Parra
//
//  Created by Mick MacCallum on 1/2/23.
//  Copyright © 2023 Parra, Inc. All rights reserved.
//

import Foundation
import UIKit

internal struct RequestConfig {
    internal private(set) var shouldReauthenticate: Bool
    internal private(set) var remainingTries: Int
    internal private(set) var allowedTries: Int
    internal private(set) var attributes: AuthenticatedRequestAttributeOptions
    
    internal init(shouldReauthenticate: Bool,
                  allowedTries: Int,
                  attributes: AuthenticatedRequestAttributeOptions = []) {

        self.shouldReauthenticate = shouldReauthenticate
        self.remainingTries = allowedTries
        self.allowedTries = allowedTries
        self.attributes = attributes
    }

    static let `default` = RequestConfig(
        shouldReauthenticate: true,
        allowedTries: 1
    )

    static let `defaultWithRetries` = RequestConfig(
        shouldReauthenticate: true,
        allowedTries: 3
    )

    var shouldRetry: Bool {
        return remainingTries > 1
    }

    var retryDelay: TimeInterval {
        let diff = allowedTries - remainingTries

        if diff > 0 {
            return pow(2.0, TimeInterval(diff))
        }

        return 0
    }

    func withoutReauthenticating() -> RequestConfig {
        var newConfig = self

        newConfig.shouldReauthenticate = false

        return newConfig
    }

    func afterRetrying() -> RequestConfig {
        var newConfig = self

        newConfig.remainingTries = max(1, newConfig.remainingTries - 1)

        return newConfig
    }
    
    func withAttribute(_ attribute: AuthenticatedRequestAttributeOptions) -> RequestConfig {
        var newConfig = self

        newConfig.attributes.insert(attribute)

        return newConfig
    }
}
