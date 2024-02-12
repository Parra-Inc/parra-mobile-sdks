//
//  ParraState.swift
//  Parra
//
//  Created by Mick MacCallum on 6/24/23.
//  Copyright © 2023 Parra, Inc. All rights reserved.
//

import Foundation
import SwiftUI

@MainActor
class ParraAppState: ObservableObject {
    // MARK: - Lifecycle

    init(
        tenantId: String,
        applicationId: String
    ) {
        self.tenantId = tenantId
        self.applicationId = applicationId
        self.pushToken = nil
    }

    // MARK: - Public

    public private(set) var tenantId: String
    public private(set) var applicationId: String

    /// A push notification token that is being temporarily cached. Caching
    /// should only occur for short periods until the SDK is prepared to upload
    /// it. Caching it longer term can lead to invalid tokens being held onto
    /// for too long.
    public private(set) var pushToken: Data?
}

actor ParraState {
    // MARK: - Lifecycle

    init() {}

    init(
        initialized: Bool = false,
        pushToken: String? = nil
    ) {
        self.initialized = initialized
        self.pushToken = pushToken
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

    /// Wether or not the SDK has been initialized by calling `Parra.initialize()`
    private var initialized = false

    private var pushToken: String?
}
