//
//  ParraAppState.swift
//  Parra
//
//  Created by Mick MacCallum on 2/12/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

class ParraAppState: ObservableObject, Equatable {
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

    // MARK: - Internal

    static func == (lhs: ParraAppState, rhs: ParraAppState) -> Bool {
        return lhs.applicationId == rhs.applicationId
            && lhs.tenantId == rhs.tenantId
            && lhs.pushToken == rhs.pushToken
    }
}
