//
//  EnvironmentValues+parraTheme.swift
//
//
//  Created by Mick MacCallum on 9/20/24.
//

import SwiftUI

public struct ParraThemeInstanceEnvironmentKey: EnvironmentKey {
    public static var defaultValue = ParraTheme.default
}

@MainActor
public extension EnvironmentValues {
    var parraTheme: ParraTheme {
        get {
            self[ParraThemeInstanceEnvironmentKey.self]
        }

        set {
            self[ParraThemeInstanceEnvironmentKey.self] = newValue
        }
    }
}
