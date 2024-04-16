//
//  ParraAuthStateEnvironmentKey.swift
//  Parra
//
//  Created by Mick MacCallum on 4/12/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

public struct ParraAuthStateEnvironmentKey: EnvironmentKey {
    public static var defaultValue = ParraAuthState()
}

public extension EnvironmentValues {
    var parraAuthState: ParraAuthState {
        get {
            self[ParraAuthStateEnvironmentKey.self]
        }

        set {
            self[ParraAuthStateEnvironmentKey.self] = newValue
        }
    }
}
