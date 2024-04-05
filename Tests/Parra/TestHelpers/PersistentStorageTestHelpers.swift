//
//  PersistentStorageTestHelpers.swift
//  Tests
//
//  Created by Mick MacCallum on 3/17/22.
//

import Foundation
@testable import Parra

func clearParraUserDefaultsSuite() {
    if let bundleIdentifier = ParraInternal.appBundleIdentifier(
        bundle: .parraBundle
    ) {
        UserDefaults.standard.removePersistentDomain(
            forName: bundleIdentifier
        )
        UserDefaults.standard.synchronize()
    }
}
