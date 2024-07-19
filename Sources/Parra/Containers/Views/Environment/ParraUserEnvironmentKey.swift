//
//  ParraUserEnvironmentKey.swift
//  Parra
//
//  Created by Mick MacCallum on 7/19/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

public struct ParraUserInstanceEnvironmentKey: EnvironmentKey {
    public static var defaultValue: ParraUserManager = Parra.default.user
}

public extension EnvironmentValues {
    var parraUser: ParraUserManager {
        get {
            self[ParraUserInstanceEnvironmentKey.self]
        }

        set {
            self[ParraUserInstanceEnvironmentKey.self] = newValue
        }
    }
}
