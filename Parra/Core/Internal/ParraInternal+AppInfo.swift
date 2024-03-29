//
//  ParraInternal+AppInfo.swift
//  Parra
//
//  Created by Mick MacCallum on 3/25/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import Foundation

extension ParraInternal {
    /// The internal version string. Might be the build number, or more advanced
    /// version string like v1.0.1-beta
    static func appBundleVersion(
        bundle: Bundle = Bundle.main
    ) -> String? {
        return bundle.infoDictionary?["CFBundleVersion"] as? String
    }

    /// The user facing version string. Like 1.0.0
    static func appBundleVersionShort(
        bundle: Bundle = Bundle.main
    ) -> String? {
        return bundle.infoDictionary?["CFBundleShortVersionString"] as? String
    }

    static func appBundleIdentifier(
        bundle: Bundle = Bundle.main
    ) -> String? {
        return bundle.bundleIdentifier
    }

    static func isBundleIdDemoApp() -> Bool {
        return appBundleIdentifier() == Constants.betaAppBundleId
    }
}
