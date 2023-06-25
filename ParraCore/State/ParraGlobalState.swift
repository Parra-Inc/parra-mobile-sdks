//
//  ParraGlobalState.swift
//  ParraCore
//
//  Created by Mick MacCallum on 6/24/23.
//  Copyright © 2023 Parra, Inc. All rights reserved.
//

import Foundation

@globalActor
internal struct ParraGlobalState {
    internal static let shared = State()

    internal actor State {
        /// Wether or not the SDK has been initialized by calling `Parra.initialize()`
        private var initialized = false

        /// A push notification token that is being temporarily cached. Caching should only occur
        /// for short periods until the SDK is prepared to upload it. Caching it longer term can
        /// lead to invalid tokens being held onto for too long.
        private var pushToken: String?

        fileprivate init() {}

        // MARK: Init
        internal func isInitialized() -> Bool {
            return initialized
        }

        internal func initialize() {
            initialized = true
        }

        internal func deinitialize() {
            initialized = false
        }

        // MARK: - Push
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
