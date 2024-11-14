//
//  EnvironmentValues+parraUserEntitlements.swift
//  Parra
//
//  Created by Mick MacCallum on 11/12/24.
//

import SwiftUI

public struct ParraUserEntitlementsInstanceEnvironmentKey: EnvironmentKey {
    public static var defaultValue = ParraUserEntitlements.shared
}

@MainActor
public extension EnvironmentValues {
    var parraUserEntitlements: ParraUserEntitlements {
        get {
            self[ParraUserEntitlementsInstanceEnvironmentKey.self]
        }

        set {
            self[ParraUserEntitlementsInstanceEnvironmentKey.self] = newValue
        }
    }
}
