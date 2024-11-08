//
//  EnvironmentValues+parraAlertManager.swift
//  Parra
//
//  Created by Mick MacCallum on 11/8/24.
//

import SwiftUI

public struct ParraAlertManagerInstanceEnvironmentKey: EnvironmentKey {
    public static var defaultValue: ParraAlertManager = .shared
}

@MainActor
public extension EnvironmentValues {
    var parraAlertManager: ParraAlertManager {
        get {
            self[ParraAlertManagerInstanceEnvironmentKey.self]
        }

        set {
            self[ParraAlertManagerInstanceEnvironmentKey.self] = newValue
        }
    }
}
