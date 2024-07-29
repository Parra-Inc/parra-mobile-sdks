//
//  ContentView.liquid.swift
//  {{ app.name }}
//
//  Bootstrapped with ❤️ by Parra on {{ "now" | date: "%m/%d/%Y" }}.
//  Copyright © {{ "now" | date: "%Y" }} {{ tenant.name }}. All rights reserved.
//

import Parra
import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
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
