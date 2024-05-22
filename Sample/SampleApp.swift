//
//  SampleApp.swift
//  Sample
//
//  Created by Mick MacCallum on 2/8/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import Parra
import SwiftUI

@main
final class SampleApp: ParraApp<ParraAppDelegate, ParraSceneDelegate> {
    required init() {
        super.init()

        configureParra(
            workspaceId: Parra.Demo.workspaceId,
            applicationId: Parra.Demo.applicationId,
            appContent: {
                ParraRequiredAuthView(
                    authenticatedContent: { _ in
                        ContentView()
                    },
                    unauthenticatedContent: { _ in
                        ParraDefaultAuthenticationFlowView(
                            flowConfig: .default
                        )
                    }
                )
            }
        )
    }
}
