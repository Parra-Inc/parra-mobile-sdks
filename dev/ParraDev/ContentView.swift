//
//  ContentView.swift
//  Parra Demo
//
//  Bootstrapped with ❤️ by Parra on 08/01/2024.
//  Copyright © 2024 Parra Inc.. All rights reserved.
//

import Parra
import SwiftUI

struct ContentView: View {
    @StateObject private var navigationState = AppNavigationState.shared

    var body: some View {
        ParraTabView(selection: $navigationState.selectedTab) {
            SampleTab(
                navigationPath: $navigationState.appTabNavigationPath
            )
            .tabItem {
                Label("App", systemImage: "app.dashed")
            }
            .tag(AppNavigationState.Tab.app)

            SettingsTab(
                navigationPath: $navigationState.profileTabNavigationPath
            )
            .tabItem {
                Label("Profile", systemImage: "person")
            }
            .tag(AppNavigationState.Tab.profile)
        }
        .environment(\.openURL, OpenURLAction { url in
            if navigationState.handleOpenedUrl(url) {
                return .handled
            }

            return .systemAction(url)
        })
    }
}

#Preview {
    ParraAppPreview(authState: .authenticatedPreview) {
        ContentView()
    }
}
