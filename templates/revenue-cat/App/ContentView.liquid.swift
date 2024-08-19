//
//  AppDelegate.swift
//  {{ app.name.raw }}
//
//  Bootstrapped with ❤️ by Parra on {{ "now" | date: "%m/%d/%Y" }}.
//  Copyright © {{ "now" | date: "%Y" }} {{ tenant.name }}. All rights reserved.
//

import Parra
import SwiftUI
import RevenueCat

struct ContentView: View {
    @Environment(\.parraAuthState) private var parraAuthState

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
        .onChange(
            of: parraAuthState
        ) { oldValue, newValue in
            updateRevenueCatAuth(
                userId: newValue.user?.info.id
            )
        }
    }

    private func updateRevenueCatAuth(
        userId: String?
    ) {
        Task {
            do {
                if let userId {
                    _ = try await Purchases.shared.logIn(userId)
                } else {
                    _ = try await Purchases.shared.logOut()
                }
            } catch {
                ParraLogger.error("Error updating RevenueCat auth state", error)
            }
        }
    }
}

#Preview {
    ParraAppPreview(authState: .authenticatedPreview) {
        ContentView()
    }
}
