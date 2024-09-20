//
//  EnvironmentValues+parraPreferredAppearance.swift
//
//
//  Created by Mick MacCallum on 9/20/24.
//

import SwiftUI

@MainActor
public struct ParraAppearanceInstanceEnvironmentKey: EnvironmentKey {
    public static var defaultValue: Binding<ParraAppearance> = .constant(
        ParraAppearance.system
    )
}

@MainActor
public extension EnvironmentValues {
    var parraPreferredAppearance: Binding<ParraAppearance> {
        get {
            self[ParraAppearanceInstanceEnvironmentKey.self]
        }

        set {
            self[ParraAppearanceInstanceEnvironmentKey.self] = newValue
        }
    }
}
