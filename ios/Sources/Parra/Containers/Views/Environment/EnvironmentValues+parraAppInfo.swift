//
//  EnvironmentValues+parraAppInfo.swift
//
//
//  Created by Mick MacCallum on 9/20/24.
//

import SwiftUI

public struct ParraAppInfoInstanceEnvironmentKey: EnvironmentKey {
    public static var defaultValue: ParraAppInfo = .default
}

@MainActor
public extension EnvironmentValues {
    var parraAppInfo: ParraAppInfo {
        get {
            self[ParraAppInfoInstanceEnvironmentKey.self]
        }

        set {
            self[ParraAppInfoInstanceEnvironmentKey.self] = newValue
        }
    }
}
