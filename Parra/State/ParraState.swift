//
//  ParraState.swift
//  Parra
//
//  Created by Mick MacCallum on 6/24/23.
//  Copyright © 2023 Parra, Inc. All rights reserved.
//

import Foundation

actor ParraState {
    // MARK: - Lifecycle

    init() {}

    init(
        initialized: Bool = false,
        pushToken: String? = nil,
        registeredModules: [String: ParraModule] = [:]
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

    // MARK: - Public

    public internal(set) var tenantId: String?
    public internal(set) var applicationId: String?

    // MARK: - Internal

    // MARK: Init

    func isInitialized() -> Bool {
        return initialized
    }

    func initialize() {
        initialized = true
    }

    func deinitialize() {
        initialized = false
    }

    // MARK: - Parra Modules

    func getAllRegisteredModules() async -> [ParraModule] {
        let modules = registeredModules.dictionaryRepresentation().values
            .map { wrapper in
                return wrapper.module
            }

        return modules
    }

    /// Registers the provided ParraModule with the Parra module. This exists for
    /// usage by other Parra modules only. It is used to allow the Parra module
    /// to identify which other Parra modules have been installed.
    func registerModule(module: ParraModule) {
        let key = type(of: module).name as NSString

        registeredModules.setObject(
            ModuleObjectWrapper(module: module),
            forKey: key
        )
    }

    func unregisterModule(module: ParraModule) async {
        let key = type(of: module).name

        unregisterModule(named: key)
    }

    nonisolated func unregisterModule(module: ParraModule) {
        let key = type(of: module).name

        Task {
            await unregisterModule(named: key)
        }
    }

    /// Checks whether the provided module has already been registered with Parra
    func hasRegisteredModule(module: ParraModule) -> Bool {
        let key = type(of: module).name as NSString

        return registeredModules.object(forKey: key) != nil
    }

    // MARK: - Push

    func getCachedTemporaryPushToken() -> String? {
        return pushToken
    }

    func setTemporaryPushToken(_ token: String) {
        pushToken = token
    }

    func clearTemporaryPushToken() {
        pushToken = nil
    }

    // MARK: - Tenant/app Ids

    func setTenantId(_ tenantId: String?) {
        self.tenantId = tenantId
    }

    func setApplicationId(_ applicationId: String?) {
        self.applicationId = applicationId
    }

    // MARK: - Private

    private class ModuleObjectWrapper: NSObject {
        // MARK: - Lifecycle

        init(module: ParraModule) {
            self.module = module
        }

        // MARK: - Fileprivate

        fileprivate let module: ParraModule
    }

    /// Wether or not the SDK has been initialized by calling `Parra.initialize()`
    private var initialized = false

    /// A push notification token that is being temporarily cached. Caching should only occur
    /// for short periods until the SDK is prepared to upload it. Caching it longer term can
    /// lead to invalid tokens being held onto for too long.
    private var pushToken: String?

    private let registeredModules = NSMapTable<NSString, ModuleObjectWrapper>(
        keyOptions: .copyIn,
        valueOptions: .strongMemory
    )

    private func unregisterModule(named name: String) {
        registeredModules.removeObject(
            forKey: name as NSString
        )
    }
}
