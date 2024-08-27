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
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        // Visit Parra's configuration docs to learn what options are available.
        // https://docs.parra.io/sdks/ios/configuration
        ParraApp(
            tenantId: "{{ tenant.id }}",
            applicationId: "{{ app.id }}",
            appDelegate: appDelegate
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
