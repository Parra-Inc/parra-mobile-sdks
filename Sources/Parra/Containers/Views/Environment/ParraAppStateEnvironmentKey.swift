//
//  ParraAppStateEnvironmentKey.swift
//  Parra
//
//  Created by Mick MacCallum on 4/12/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

public struct ParraAppStateEnvironmentKey: EnvironmentKey {
    public static var defaultValue: ParraAppState = .init(
        tenantId: "",
        applicationId: ""
    )
}

public extension EnvironmentValues {
    var parraAppState: ParraAppState {
        get {
            self[ParraAppStateEnvironmentKey.self]
        }

        set {
            self[ParraAppStateEnvironmentKey.self] = newValue
        }
    }
}
