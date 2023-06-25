//
//  ParraGlobalState.swift
//  Parra
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

        private var registeredModules: [String: ParraModule] = [:]


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

        // MARK: - Parra Modules

        internal func getAllRegisteredModules() async -> [String: ParraModule] {
            return registeredModules
        }

        /// Registers the provided ParraModule with the Parra module. This exists for usage by other Parra modules only. It is used
        /// to allow the Parra module to identify which other Parra modules have been installed.
        internal func registerModule(module: ParraModule) {
            registeredModules[type(of: module).name] = module
        }

        // Mostly just a test helper
        internal func unregisterModule(module: ParraModule) {
            registeredModules.removeValue(forKey: type(of: module).name)
        }

        /// Checks whether the provided module has already been registered with Parra
        internal func hasRegisteredModule(module: ParraModule) -> Bool {
            return registeredModules[type(of: module).name] != nil
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
