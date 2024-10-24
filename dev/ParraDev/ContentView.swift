//
//  ContentView.swift
//  Parra Demo
//
//  Bootstrapped with ❤️ by Parra on 08/01/2024.
//  Copyright © 2024 Parra Inc.. All rights reserved.
//

import Parra
import ParraStorefront
import SwiftUI

private let shopifyDomain: String = ""
private let shopifyApiKey: String = ""

struct StoreTab: View {
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
                    Label("Store", systemImage: "storefront")
                }

            SettingsTab()
                .tabItem {
                    Label("Profile", systemImage: "person")
                }
        }
        .onAppear {
            if !shopifyDomain.isEmpty && !shopifyApiKey.isEmpty {
                ParraStorefront.initialize(
                    with: ParraStorefront.Config(
                        shopifyDomain: shopifyDomain,
                        shopifyApiKey: shopifyApiKey
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
