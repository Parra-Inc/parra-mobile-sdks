//
//  EnvironmentValues+parraConfiguration.swift
//  Parra
//
//  Created by Mick MacCallum on 11/4/24.
//

import SwiftUI

public struct ParraConfigurationInstanceEnvironmentKey: EnvironmentKey {
    public static var defaultValue: ParraConfiguration = .default
}

@MainActor
public extension EnvironmentValues {
    var parraConfiguration: ParraConfiguration {
        get {
            self[ParraConfigurationInstanceEnvironmentKey.self]
        }

        set {
            self[ParraConfigurationInstanceEnvironmentKey.self] = newValue
        }
    }
}
