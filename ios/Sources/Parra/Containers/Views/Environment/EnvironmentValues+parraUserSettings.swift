//
//  EnvironmentValues+parraUserSettings.swift
//  Parra
//
//  Created by Mick MacCallum on 10/31/24.
//

import SwiftUI

public struct ParraUserSettingsInstanceEnvironmentKey: EnvironmentKey {
    public static var defaultValue = ParraUserSettings.shared
}

@MainActor
public extension EnvironmentValues {
    var parraUserSettings: ParraUserSettings {
        get {
            self[ParraUserSettingsInstanceEnvironmentKey.self]
        }

        set {
            self[ParraUserSettingsInstanceEnvironmentKey.self] = newValue
        }
    }
}
