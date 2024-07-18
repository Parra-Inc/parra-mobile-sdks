//
//  ContentView.swift
//  Sample
//
//  Created by Mick MacCallum on 2/8/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import Parra
import SwiftUI

struct ContentView: View {
    // MARK: - Internal

    var body: some View {
        TabView {
            SampleTab()
                .tabItem {
                    Label(
                        appInfo.application.name,
                        systemImage: "app.dashed"
                    )
                }

            SettingsTab()
                .tabItem {
                    Label("Profile", systemImage: "person")
                }
        }
    }

    // MARK: - Private

    @EnvironmentObject private var appInfo: ParraAppInfo
}

#Preview {
    ParraAppPreview {
        ContentView()
    }
}
