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
struct SampleApp: App {
    @UIApplicationDelegateAdaptor(
        ParraAppDelegate<ParraSceneDelegate>.self
    ) var appDelegate

    var body: some Scene {
        ParraApp(
            workspaceId: Parra.Demo.workspaceId,
            applicationId: Parra.Demo.applicationId,
            appDelegate: appDelegate,
            authenticationMethod: .parra
        ) {
            WindowGroup {
                ParraRequiredAuthWindow(
                    authenticatedContent: { _ in
                        ContentView()
                    },
                    unauthenticatedContent: {
                        ParraDefaultAuthenticationFlowView(
                            flowConfig: .default
                        )
                    }
                )
            }
        }
    }
}
