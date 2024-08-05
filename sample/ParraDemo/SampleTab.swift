//
//  SampleTab.swift
//  Parra Demo
//
//  Bootstrapped with ❤️ by Parra on 08/05/2024.
//  Copyright © 2024 Parra Inc.. All rights reserved.
//

import Parra
import SwiftUI

struct SampleTab: View {
    @EnvironmentObject private var themeManager: ParraThemeManager

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
}

#Preview {
    ParraAppPreview {
        SampleTab()
    }
}
