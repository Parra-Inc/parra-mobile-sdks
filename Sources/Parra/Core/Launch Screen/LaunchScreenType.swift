//
//  LaunchScreenType.swift
//  Parra
//
//  Created by Mick MacCallum on 2/14/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

public enum LaunchScreenType: Equatable {
    case `default`(ParraDefaultLaunchScreen.Config)
    case storyboard(ParraStoryboardLaunchScreen.Config)
    case custom(any View)

    // MARK: - Public

    public static func == (
        lhs: LaunchScreenType,
        rhs: LaunchScreenType
    ) -> Bool {
        switch (lhs, rhs) {
        case (.default(let lConfig), .default(let rConfig)):
            return lConfig == rConfig
        case (.storyboard(let lConfig), .storyboard(let rConfig)):
            return lConfig == rConfig
        case (.custom, .custom):
            return false
        default:
            return false
        }
    }
}
