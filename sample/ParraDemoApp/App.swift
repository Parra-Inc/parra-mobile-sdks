//
//  ParraDemoAppApp.swift
//  Parra Demo
//
//  Bootstrapped with ❤️ by Parra on 02/27/2025.
//  Copyright © 2025 Parra Inc.. All rights reserved.
//

import Parra
import SwiftUI

@main
struct ParraDemoApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        // Visit Parra's configuration docs to learn what options are available.
        // https://docs.parra.io/sdks/ios/configuration
        ParraApp(
            tenantId: "201cbcf0-b5d6-4079-9e4d-177ae04cc9f4",
            applicationId: "edec3a6c-a375-4a9d-bce8-eb00860ef228",
            appDelegate: appDelegate,
            configuration: ParraConfiguration(
                pushNotificationOptions: .allWithoutProvisional
            )
        ) {
            WindowGroup {
                // Use the ParraOptionalAuthWindow if you don't support user sign-in
                // or don't require that users be logged in to use your app. Use
                // ParraRequiredAuthWindow if signing in is required.
                ParraOptionalAuthWindow {
                    ContentView()
                }
            }
        }
    }
}
