//
//  ParraDemoAppApp.swift
//  Parra Demo
//
//  Bootstrapped with ❤️ by Parra on 08/18/2024.
//  Copyright © 2024 Parra Inc.. All rights reserved.
//

import Parra
import SwiftUI

@main
struct ParraDemoApp: App {
    @UIApplicationDelegateAdaptor(
        ParraAppDelegate<ParraSceneDelegate>.self
    ) var appDelegate

    var body: some Scene {
        ParraApp(
            workspaceId: "201cbcf0-b5d6-4079-9e4d-177ae04cc9f4",
            applicationId: "edec3a6c-a375-4a9d-bce8-eb00860ef228",
            appDelegate: appDelegate
        ) {
            WindowGroup {
                ParraOptionalAuthWindow { _ in
                    ContentView()
                }
            }
        }
    }
}
