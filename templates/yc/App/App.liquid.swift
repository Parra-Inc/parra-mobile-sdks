//
//  {{ app.name.upper_camel }}App.swift
//  {{ app.name.raw }}
//
//  Bootstrapped with ❤️ by Parra on {{ "now" | date: "%m/%d/%Y" }}.
//  Copyright © {{ "now" | date: "%Y" }} {{ tenant.name }}. All rights reserved.
//

import Parra
import SwiftUI

private let configuration = ParraConfiguration(
    theme: ParraTheme(
        lightPalette: ParraColorPalette(
            primary: ParraColorSwatch(
                primary: Color(red: 238 / 255.0, green: 93 / 255.0, blue: 25 / 255.0),
                name: "Primary"
            ),
            secondary: ParraColorSwatch(
                primary: Color.secondary,
                name: "Secondary"
            ),
            primaryBackground: Color(red: 245 / 255.0, green: 245 / 255.0, blue: 238 / 255.0),
            secondaryBackground: .white,
            primaryText: ParraColorSwatch(
                primary: Color(red: 17 / 255.0, green: 24 / 255.0, blue: 39 / 255.0),
                name: "Primary Text"
            ),
            secondaryText: ParraColorSwatch(
                primary: Color(red: 60 / 255.0, green: 60 / 255.0, blue: 67 / 255.0),
                name: "Secondary Text"
            ),
            primarySeparator: ParraColorSwatch(
                primary: Color(red: 229 / 255.0, green: 231 / 255.0, blue: 235 / 255.0),
                name: "Primary Separator"
            ),
            secondarySeparator: ParraColorSwatch(
                primary: Color(red: 198 / 255.0, green: 198 / 255.0, blue: 198 / 255.0),
                name: "Secondary Separator"
            ),
            error: ParraColorSwatch(
                primary: Color(red: 225 / 255.0, green: 82 / 255.0, blue: 65 / 255.0),
                name: "Error"
            ),
            warning: ParraColorSwatch(
                primary: Color(red: 253 / 255.0, green: 169 / 255.0, blue: 66 / 255.0),
                name: "Warning"
            ),
            info: ParraColorSwatch(
                primary: Color(red: 38 / 255.0, green: 139 / 255.0, blue: 210 / 255.0),
                name: "Info"
            ),
            success: ParraColorSwatch(primary: .green, name: "Success")
        )
    )
)

@main
struct {{ app.name.upper_camel }}: App {
    @UIApplicationDelegateAdaptor(
        ParraAppDelegate<ParraSceneDelegate>.self
    ) var appDelegate

    var body: some Scene {
        ParraApp(
            tenantId: "{{ tenant.id }}",
            applicationId: "{{ app.id }}",
            appDelegate: appDelegate,
            configuration: configuration
        ) {
            WindowGroup {
                ParraOptionalAuthWindow {
                    ContentView()
                }
            }
        }
    }
}
