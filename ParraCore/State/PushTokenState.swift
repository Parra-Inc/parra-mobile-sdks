//
//  PushTokenState.swift
//  ParraCore
//
//  Created by Mick MacCallum on 6/24/23.
//  Copyright © 2023 Parra, Inc. All rights reserved.
//

import Foundation

@globalActor
internal struct PushTokenState {
    internal static let shared = State()

    internal actor State {
        private var pushToken: String?

        fileprivate init() {}

        internal func getCachedTemporaryPushToken() -> String? {
            return pushToken
        }

        internal func setTemporaryPushToken(_ token: String) {
            pushToken = token
        }

        internal func clearTemporaryPushToken() {
            pushToken = nil
        }
    }
}
