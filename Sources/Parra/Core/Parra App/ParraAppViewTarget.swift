//
//  ParraAppViewTarget.swift
//  Parra
//
//  Created by Mick MacCallum on 4/12/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import Foundation

enum ParraAppViewTarget {
    case app(
        ParraAuthenticationMethod,
        ParraAppState,
        ParraLaunchScreen.Config?
    )
    case preview
}
