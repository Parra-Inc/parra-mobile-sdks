//
//  RequestConfig.swift
//  ParraCore
//
//  Created by Mick MacCallum on 1/2/23.
//  Copyright © 2023 Parra, Inc. All rights reserved.
//

import Foundation

internal struct RequestConfig {
    internal private(set) var shouldReauthenticate: Bool
    internal private(set) var remainingTries: Int

    internal init(shouldReauthenticate: Bool, remainingTries: Int) {
        self.shouldReauthenticate = shouldReauthenticate
        self.remainingTries = remainingTries
    }

    static let `default` = RequestConfig(
        shouldReauthenticate: true,
        remainingTries: 1
    )

    var shouldRetry: Bool {
        return remainingTries > 1
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
}
