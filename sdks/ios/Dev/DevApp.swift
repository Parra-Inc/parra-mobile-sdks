//
//  DevApp.swift
//  Dev
//
//  Created by Mick MacCallum on 7/24/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import Parra
import SwiftUI

@main
struct DevApp: App {
    @UIApplicationDelegateAdaptor(
        ParraAppDelegate<ParraSceneDelegate>.self
    ) var appDelegate

    var body: some Scene {
        ParraApp(
            // TODO: These should probably be a staging tenant
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
