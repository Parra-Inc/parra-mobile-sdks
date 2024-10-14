//
//  EnvironmentValues+parraComponentFactory.swift
//
//
//  Created by Mick MacCallum on 9/20/24.
//

import SwiftUI

public struct ParraComponentFactoryInstanceEnvironmentKey: EnvironmentKey {
    public static var defaultValue: ParraComponentFactory = .default
}

@MainActor
public extension EnvironmentValues {
    var parraComponentFactory: ParraComponentFactory {
        get {
            self[ParraComponentFactoryInstanceEnvironmentKey.self]
        }

        set {
            self[ParraComponentFactoryInstanceEnvironmentKey.self] = newValue
        }
    }
}
