//
//  ParraEnvironmentKey.swift
//  Parra
//
//  Created by Mick MacCallum on 3/23/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

@MainActor
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

@MainActor
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

@MainActor
public struct ParraAppearanceInstanceEnvironmentKey: EnvironmentKey {
    public static var defaultValue: Binding<ParraAppearance> = .constant(
        ParraAppearance.system
    )
}

@MainActor
public extension EnvironmentValues {
    var parraAppearance: Binding<ParraAppearance> {
        get {
            self[ParraAppearanceInstanceEnvironmentKey.self]
        }

        set {
            self[ParraAppearanceInstanceEnvironmentKey.self] = newValue
        }
    }
}

@MainActor
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

@MainActor
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
