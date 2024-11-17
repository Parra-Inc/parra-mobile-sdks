//
//  ContentView.swift
//  Parra Demo
//
//  Bootstrapped with ❤️ by Parra on 08/01/2024.
//  Copyright © 2024 Parra Inc.. All rights reserved.
//

import Parra
import SwiftUI

struct FeedTab: View {
    var body: some View {
        ParraFeedWidget(feedId: "content")
    }
}

struct ContentView: View {
    @StateObject private var navigationState = AppNavigationState.shared
    @Environment(\.parra) private var parra

    @State var isPresentingPurchaseSheet: Bool = false

    var body: some View {
        TabView(selection: $navigationState.selectedTab) {
            SampleTab(
                navigationPath: $navigationState.appTabNavigationPath
            )
            .tabItem {
                Label("App", systemImage: "app.dashed")
            }
            .tag(AppNavigationState.Tab.app)

            FeedTab()
                .tabItem {
                    Label("Feed", systemImage: "app.dashed")
                }
                .tag(AppNavigationState.Tab.feed)

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
        .onAppear {
            parra.push.requestPushPermission()
        }
    }
}

#Preview {
    ParraAppPreview(authState: .authenticatedPreview) {
        ContentView()
    }
}
