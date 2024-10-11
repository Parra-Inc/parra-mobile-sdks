//
//  ContentView.swift
//  Parra Demo
//
//  Bootstrapped with ❤️ by Parra on 08/01/2024.
//  Copyright © 2024 Parra Inc.. All rights reserved.
//

import Parra
import SwiftUI

struct ContentFeedTab: View {
    var body: some View {
        ParraFeedWidget(
            feedId: "content",
            config: .default
        )
    }
}

struct HomeFeedTab: View {
    var body: some View {
        ParraFeedWidget(
            feedId: "home",
            config: .default
        )
    }
}

struct ContentView: View {
    var body: some View {
        TabView {
            ContentFeedTab()
                .tabItem {
                    Label("Feed", systemImage: "list")
                }

            HomeFeedTab()
                .tabItem {
                    Label("Feed", systemImage: "list")
                }

            SampleTab()
                .tabItem {
                    Label("App", systemImage: "app.dashed")
                }

            SettingsTab()
                .tabItem {
                    Label("Profile", systemImage: "person")
                }
        }
    }
}

#Preview {
    ParraAppPreview(authState: .authenticatedPreview) {
        ContentView()
    }
}
