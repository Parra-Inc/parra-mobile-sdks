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
    @UIApplicationDelegateAdaptor(
        ParraAppDelegate<ParraSceneDelegate>.self
    ) var appDelegate

    var body: some Scene {
        ParraApp(
            tenantId: "201cbcf0-b5d6-4079-9e4d-177ae04cc9f4", // demo tenant
            applicationId: "360b600d-a689-4ac0-8e57-1abcfeca4835", // dev app
            appDelegate: appDelegate
        ) {
            WindowGroup {
                ParraOptionalAuthWindow {
                    ContentView()
                }
            }
        }
    }
}
