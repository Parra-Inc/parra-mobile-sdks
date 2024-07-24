//
//  SampleTab.swift
//  {{ app.name }}
//
//  Bootstrapped with ❤️ by Parra on {{ "now" | date: "%m/%d/%Y" }}.
//  Copyright © {{ "now" | date: "%Y" }} {{ tenant.name }}. All rights reserved.
//

import Parra
import SwiftUI

struct SampleTab: View {
    // MARK: - Internal

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Image(systemName: "app.dashed")
                    .resizable()
                    .foregroundStyle(.gray)
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 96)

                Text("We can't wait to see\nwhat you build!")
                    .font(.title)
                    .bold()
                    .multilineTextAlignment(.center)

                Link(
                    destination: URL(
                        string: "https://docs.parra.io/sdks/guides/quickstart/swiftui"
                    )!
                ) {
                    Text("Get started")
                        .font(.headline)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .navigationTitle("App")
            .background(themeManager.theme.palette.secondaryBackground)
        }
    }

    // MARK: - Private

    @EnvironmentObject private var themeManager: ParraThemeManager
}

#Preview {
    ParraAppPreview {
        SampleTab()
    }
}
