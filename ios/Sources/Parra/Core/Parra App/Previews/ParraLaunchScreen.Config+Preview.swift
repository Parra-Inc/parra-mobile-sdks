//
//  ParraLaunchScreen.Config+Preview.swift
//  Parra
//
//  Created by Mick MacCallum on 2/19/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

public extension ParraLaunchScreen.Options {
    nonisolated static let preview = ParraLaunchScreen.Options(
        type: .default(
            ParraDefaultLaunchScreen.Config()
        ),
        fadeDuration: 0.0
    )
}
