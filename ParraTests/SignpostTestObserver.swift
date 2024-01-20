//
//  SignpostTestObserver.swift
//  ParraTests
//
//  Created by Mick MacCallum on 10/8/23.
//  Copyright © 2023 Parra, Inc. All rights reserved.
//

import Foundation
import XCTest
import OSLog

/// https://www.iosdev.recipes/os-signpost/
class SignpostTestObserver: NSObject, XCTestObservation {

    // Create a custom log subsystem and relevant category
    let log = OSLog(subsystem: "com.parra.test-profiling", category: "signposts")

    override init() {
        super.init()

        // XCTestObservation keeps a strong reference to observers
        XCTestObservationCenter.shared.addTestObserver(self)
    }

    // MARK: - Test Bundle

    func testBundleWillStart(_ testBundle: Bundle) {
        let id = OSSignpostID(log: log, object: testBundle)
        os_signpost(.begin, log: log, name: "test bundle", signpostID: id, "%@", testBundle.description)
    }

    func testBundleDidFinish(_ testBundle: Bundle) {
        let id = OSSignpostID(log: log, object: testBundle)
        os_signpost(.end, log: log, name: "test bundle", signpostID: id, "%@", testBundle.description)
    }
}
