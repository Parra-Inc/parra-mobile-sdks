//
//  LaunchScreenType.swift
//  Parra
//
//  Created by Mick MacCallum on 2/14/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

public enum LaunchScreenType {
    case `default`(ParraDefaultLaunchScreen.Config)
    case storyboard(ParraStoryboardLaunchScreen.Config)
    case custom(any View)
}
