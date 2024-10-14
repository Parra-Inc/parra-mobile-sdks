//
//  EnvironmentValues+parraAuthState.swift
//
//
//  Created by Mick MacCallum on 9/20/24.
//

import SwiftUI

public struct ParraAuthStateInstanceEnvironmentKey: EnvironmentKey {
    public static var defaultValue: ParraAuthState = .undetermined
}

@MainActor
public extension EnvironmentValues {
    var parraAuthState: ParraAuthState {
        get {
            self[ParraAuthStateInstanceEnvironmentKey.self]
        }

        set {
            self[ParraAuthStateInstanceEnvironmentKey.self] = newValue
        }
    }
}
