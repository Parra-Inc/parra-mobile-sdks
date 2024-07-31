//
//  ParraDevApp.swift
//  ParraDev
//
//  Created by Mick MacCallum on 7/31/24.
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
