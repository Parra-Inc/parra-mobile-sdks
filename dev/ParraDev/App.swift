//
//  ParraDemoApp.swift
//  Parra Demo
//
//  Bootstrapped with ❤️ by Parra on 08/01/2024.
//  Copyright © 2024 Parra Inc.. All rights reserved.
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
            tenantId: "201cbcf0-b5d6-4079-9e4d-177ae04cc9f4", // demo tenant
            applicationId: "360b600d-a689-4ac0-8e57-1abcfeca4835", // dev app
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
