//
//  EnvironmentValues+parraUserProperties.swift
//
//
//  Created by Mick MacCallum on 9/21/24.
//

import SwiftUI

public struct ParraUserPropertiesInstanceEnvironmentKey: EnvironmentKey {
    public static var defaultValue = ParraUserProperties.shared
}

@MainActor
public extension EnvironmentValues {
    var parraUserProperties: ParraUserProperties {
        get {
            self[ParraUserPropertiesInstanceEnvironmentKey.self]
        }

        set {
            self[ParraUserPropertiesInstanceEnvironmentKey.self] = newValue
        }
    }
}
