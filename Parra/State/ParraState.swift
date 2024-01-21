//
//  ParraState.swift
//  Parra
//
//  Created by Mick MacCallum on 6/24/23.
//  Copyright © 2023 Parra, Inc. All rights reserved.
//

import Foundation

internal actor ParraState {
    private class ModuleObjectWrapper: NSObject {
        fileprivate let module: ParraModule

        init(module: ParraModule) {
            self.module = module
        }
    }

    /// Wether or not the SDK has been initialized by calling `Parra.initialize()`
    private var initialized = false

    public internal(set) var tenantId: String?
    public internal(set) var applicationId: String?

    /// A push notification token that is being temporarily cached. Caching should only occur
    /// for short periods until the SDK is prepared to upload it. Caching it longer term can
    /// lead to invalid tokens being held onto for too long.
    private var pushToken: String?

    private let registeredModules = NSMapTable<NSString, ModuleObjectWrapper>(
        keyOptions: .copyIn,
        valueOptions: .strongMemory
    )

    internal init() {}

    internal init(
        initialized: Bool = false,
        pushToken: String? = nil,
        registeredModules: [String : ParraModule] = [:]
    ) {
        self.initialized = initialized
        self.pushToken = pushToken

        for (key, value) in registeredModules {
            self.registeredModules.setObject(
                ModuleObjectWrapper(module: value),
                forKey: key as NSString
            )
        }
    }

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

    internal func getAllRegisteredModules() async -> [ParraModule] {
        let modules = registeredModules.dictionaryRepresentation().values.map { wrapper in
            return wrapper.module
        }

        return modules
    }

    /// Registers the provided ParraModule with the Parra module. This exists for 
    /// usage by other Parra modules only. It is used to allow the Parra module
    /// to identify which other Parra modules have been installed.
    internal func registerModule(module: ParraModule) {
        let key = type(of: module).name as NSString

        registeredModules.setObject(
            ModuleObjectWrapper(module: module),
            forKey: key
        )
    }

    internal func unregisterModule(module: ParraModule) async {
        let key = type(of: module).name

        unregisterModule(named: key)
    }

    nonisolated internal func unregisterModule(module: ParraModule) {
        let key = type(of: module).name

        Task {
            await unregisterModule(named: key)
        }
    }

    private func unregisterModule(named name: String) {
        registeredModules.removeObject(
            forKey: name as NSString
        )
    }

    /// Checks whether the provided module has already been registered with Parra
    internal func hasRegisteredModule(module: ParraModule) -> Bool {
        let key = type(of: module).name as NSString

        return registeredModules.object(forKey: key) != nil
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

    // MARK: - Tenant/app Ids

    internal func setTenantId(_ tenantId: String?) {
        self.tenantId = tenantId
    }

    internal func setApplicationId(_ applicationId: String?) {
        self.applicationId = applicationId
    }
}
