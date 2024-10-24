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

struct ContentView: View {
    var body: some View {
        TabView {
            SampleTab()
                .tabItem {
                    Label("App", systemImage: "app.dashed")
                }

            StorefrontTab()
                .tabItem {
                    Label("Store", systemImage: "storefront")
                }

            SettingsTab()
                .tabItem {
                    Label("Profile", systemImage: "person")
                }
        }
        .onAppear {
            if !ParraStorefront.isInitialized {
                ParraStorefront.initialize(
                    with: ParraStorefront.Config(
                        shopifyDomain: <#SHOPIFY_DOMAIN#>,
                        shopifyApiKey: <#SHOPIFY_API_KEY#>
                    )
                )

                ParraStorefront.preloadProducts()
            }
        }
    }
}

#Preview {
    ParraAppPreview(authState: .authenticatedPreview) {
        ContentView()
    }
}
