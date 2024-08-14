//
//  PersistentStorageTestHelpers.swift
//  Tests
//
//  Created by Mick MacCallum on 3/17/22.
//

import Foundation
@testable import Parra

func clearParraUserDefaultsSuite() {
    let suiteName = ParraInternal.appUserDefaultsSuite()

    UserDefaults.standard.removePersistentDomain(
        forName: suiteName
    )
    UserDefaults.standard.synchronize()
}
