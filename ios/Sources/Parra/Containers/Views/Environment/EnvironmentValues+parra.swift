//
//  EnvironmentValues+parra.swift
//
//
//  Created by Mick MacCallum on 9/20/24.
//

import SwiftUI

public struct ParraInstanceEnvironmentKey: EnvironmentKey {
    public static var defaultValue: Parra = .default
}

@MainActor
public extension EnvironmentValues {
    var parra: Parra {
        get {
            self[ParraInstanceEnvironmentKey.self]
        }

        set {
            self[ParraInstanceEnvironmentKey.self] = newValue
        }
    }
}
