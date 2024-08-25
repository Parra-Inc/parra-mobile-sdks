//
//  ParraDemoApp.swift
//  Parra Demo
//
//  Bootstrapped with ❤️ by Parra on 08/01/2024.
//  Copyright © 2024 Parra Inc.. All rights reserved.
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
struct ParraDemoApp: App {
    @UIApplicationDelegateAdaptor(
        ParraAppDelegate<ParraSceneDelegate>.self
    ) var appDelegate

    var body: some Scene {
        ParraApp(
            tenantId: "201cbcf0-b5d6-4079-9e4d-177ae04cc9f4", // demo tenant
            applicationId: "360b600d-a689-4ac0-8e57-1abcfeca4835", // dev app
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
