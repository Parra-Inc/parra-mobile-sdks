//
//  AppInfo+Fixtures.swift
//  Parra
//
//  Created by Mick MacCallum on 3/19/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

extension AppInfo: ParraFixture {
    static func validStates() -> [AppInfo] {
        return [
            AppInfo(
                versionToken: "1.0.0",
                newInstalledVersionInfo: NewInstalledVersionInfo(
                    configuration: AppReleaseConfiguration(
                        title: "My new release",
                        hasOtherReleases: false
                    ),
                    release: AppRelease.validStates()[0]
                ),
                termsOfUse: URL(string: "https://parra.io/tos"),
                privacyPolicy: URL(string: "https://parra.io/privacy")
            )
        ]
    }

    static func invalidStates() -> [AppInfo] {
        return []
    }
}
