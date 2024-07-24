//
//  Parra+AppInfo.swift
//  Sample
//
//  Created by Mick MacCallum on 7/18/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import Foundation

public extension Parra {
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
}
