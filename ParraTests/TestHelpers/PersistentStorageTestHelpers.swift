//
//  PersistentStorageTestHelpers.swift
//  ParraTests
//
//  Created by Mick MacCallum on 3/17/22.
//

import Foundation
@testable import Parra

func clearParraUserDefaultsSuite() {
    if let bundleIdentifier = ParraInternal.bundle().bundleIdentifier {
        UserDefaults.standard.removePersistentDomain(
            forName: bundleIdentifier
        )
        UserDefaults.standard.synchronize()
    }
}
