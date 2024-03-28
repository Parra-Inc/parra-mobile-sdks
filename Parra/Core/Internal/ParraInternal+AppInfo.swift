//
//  ParraInternal+AppInfo.swift
//  Parra
//
//  Created by Mick MacCallum on 3/25/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import Foundation

extension ParraInternal {
    static func appBundleVersion(
        bundle: Bundle = Bundle.main
    ) -> String? {
        return bundle.infoDictionary?["CFBundleVersion"] as? String
    }

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
