//
//  ParraInternal+AppInfo.swift
//  Parra
//
//  Created by Mick MacCallum on 3/25/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import Foundation

extension ParraInternal {
    static func appBundleIdentifier() -> String? {
        return Bundle.main.bundleIdentifier
    }

    /// Whether the current app with Parra installed is the demo app in
    /// TestFlight.
    static func isBundleIdDemoApp() -> Bool {
        return appBundleIdentifier() == Constants.betaAppBundleId
    }

    /// Whether the current app with Parra installed is the dev app.
    static func isBundleIdDevApp() -> Bool {
        return appBundleIdentifier() == Constants.devAppBundleId
    }

    static func appUserDefaultsSuite() -> String {
        // ! The suite can not be the bundle id. This will result in warning:
        // _NSUserDefaults_Log_Nonsensical_Suites

        let suffix = "parra.defaults"

        guard let bundleId = appBundleIdentifier() else {
            return suffix
        }

        return "\(bundleId).\(suffix)"
    }
}
