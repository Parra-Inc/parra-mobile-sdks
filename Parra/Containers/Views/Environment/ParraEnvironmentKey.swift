//
//  ParraEnvironmentKey.swift
//  Parra
//
//  Created by Mick MacCallum on 3/23/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

public struct ParraInstanceEnvironmentKey: EnvironmentKey {
    public static var defaultValue: Parra = .default
}

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
