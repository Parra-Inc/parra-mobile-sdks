//
//  UserDefaults.swift
//  Parra
//
//  Created by Mick MacCallum on 7/8/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import Foundation

private let defaults = UserDefaults(
    suiteName: ParraInternal.appUserDefaultsSuite(
        bundle: .parraBundle
    )
) ?? .standard

extension UserDefaults {
    static let parra: UserDefaults = defaults
}
