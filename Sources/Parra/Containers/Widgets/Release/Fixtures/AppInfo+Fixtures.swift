//
//  AppInfo+Fixtures.swift
//  Parra
//
//  Created by Mick MacCallum on 3/19/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

extension ParraAppInfo: ParraFixture {
    static func validStates() -> [ParraAppInfo] {
        return [
            ParraAppInfo(
                versionToken: "1.0.0",
                newInstalledVersionInfo: NewInstalledVersionInfo(
                    configuration: AppReleaseConfiguration(
                        title: "My new release",
                        hasOtherReleases: false
                    ),
                    release: AppRelease.validStates()[0]
                ),
                auth: ParraAppAuthInfo.validStates()[0],
                legal: LegalInfo.validStates()[0]
            )
        ]
    }

    static func invalidStates() -> [ParraAppInfo] {
        return []
    }
}
