//
//  ContentView.swift
//  {{ app.name.raw }}
//
//  Bootstrapped with ❤️ by Parra on {{ "now" | date: "%m/%d/%Y" }}.
//  Copyright © {{ "now" | date: "%Y" }} {{ tenant.name }}. All rights reserved.
//

import Parra
import ParraStorefront
import SwiftUI

struct ContentView: View {
    @State private var navigationState = AppNavigationState.shared
    @Environment(\.parraTheme) private var theme

    var body: some View {
        ParraTabView(selection: $navigationState.selectedTab) {
            SampleTab(
                navigationPath: $navigationState.sampleNavigationPath
            )
            .tabItem {
                Label("{{ template.tabs.sample.tab.name }}", systemImage: "{{ template.tabs.sample.tab.sf_symbol }}")
            }
            .tag(AppNavigationState.Tab.sample)

            VideosTab(
                navigationPath: $navigationState.videosNavigationPath
            )
            .tabItem {
                Label("{{ template.tabs.videos.tab.name }}", systemImage: "{{ template.tabs.videos.tab.sf_symbol }}")
            }
            .tag(AppNavigationState.Tab.videos)

            EpisodesTab(
                navigationPath: $navigationState.videosNavigationPath
            )
            .tabItem {
                Label("{{ template.tabs.episodes.tab.name }}", systemImage: "{{ template.tabs.episodes.tab.sf_symbol }}")
            }
            .tag(AppNavigationState.Tab.episodes)

            ShopTab(
                navigationPath: $navigationState.shopNavigationPath
            )
            .tabItem {
                Label("{{ template.tabs.shop.tab.name }}", systemImage: "{{ template.tabs.shop.tab.sf_symbol }}")
            }
            .tag(AppNavigationState.Tab.shop)

            SettingsTab(
                navigationPath: $navigationState.settingsNavigationPath
            )
            .tabItem {
                Label("{{ template.tabs.settings.tab.name }}", systemImage: "{{ template.tabs.settings.tab.sf_symbol }}")
            }
            .tag(AppNavigationState.Tab.settings)
        }
        .tint(theme.palette.primary.toParraColor())
        .onAppear {
        {% if template.tabs.shop.shopify %}
            if !ParraStorefront.isInitialized {
                ParraStorefront.initialize(
                    with: ParraStorefront.Config(
                        shopifyDomain: "{{ template.tabs.shop.shopify.domain }}",
                        shopifyApiKey: "{{ template.tabs.shop.shopify.api_key }}"
                    )
                )

                ParraStorefront.preloadProducts()
            }
        {% endif %}
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
