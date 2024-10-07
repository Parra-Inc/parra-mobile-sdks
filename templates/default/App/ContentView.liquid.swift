//
//  ContentView.swift
//  {{ app.name.raw }}
//
//  Bootstrapped with ❤️ by Parra on {{ "now" | date: "%m/%d/%Y" }}.
//  Copyright © {{ "now" | date: "%Y" }} {{ tenant.name }}. All rights reserved.
//

import Parra
import SwiftUI
import ParraStorefront

struct StoreTab: View {
    @Environment(\.parraTheme) private var parraTheme

    var body: some View {
        ParraStorefrontWidget()
    }
}

struct ContentView: View {
    var body: some View {
        TabView {
            SampleTab()
                .tabItem {
                    Label("App", systemImage: "app.dashed")
                }

            StoreTab()
                .tabItem {
                    Label("Store", systemImage: "app.dashed")
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
