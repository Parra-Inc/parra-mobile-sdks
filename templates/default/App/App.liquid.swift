//
//  {{ app.camel_name }}App.swift
//  {{ app.name }}
//
//  Bootstrapped with ❤️ by Parra on {{ "now" | date: "%m/%d/%Y" }}.
//  Copyright © {{ "now" | date: "%Y" }} {{ tenant.name }}. All rights reserved.
//

import Parra
import SwiftUI

@main
struct MyApp: App {
    @UIApplicationDelegateAdaptor(
        ParraAppDelegate<ParraSceneDelegate>.self
    ) var appDelegate

    var body: some Scene {
        ParraApp(
            workspaceId: "{{ tenant.id }}",
            applicationId: "{{ app.id }}",
            appDelegate: appDelegate,
            authenticationMethod: .parra
        ) {
            WindowGroup {
                ParraOptionalAuthWindow { _ in
                    ContentView()
                }
            }
        }
    }
}
