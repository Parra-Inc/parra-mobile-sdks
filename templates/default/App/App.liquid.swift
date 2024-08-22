//
//  {{ app.name.upper_camel }}App.swift
//  {{ app.name.raw }}
//
//  Bootstrapped with ❤️ by Parra on {{ "now" | date: "%m/%d/%Y" }}.
//  Copyright © {{ "now" | date: "%Y" }} {{ tenant.name }}. All rights reserved.
//

import Parra
import SwiftUI

@main
struct {{ app.name.upper_camel }}: App {
    @UIApplicationDelegateAdaptor(
        ParraAppDelegate<ParraSceneDelegate>.self
    ) var appDelegate

    var body: some Scene {
        ParraApp(
            workspaceId: "{{ tenant.id }}",
            applicationId: "{{ app.id }}",
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
