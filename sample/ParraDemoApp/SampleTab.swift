//
//  SampleTab.swift
//  Parra Demo
//
//  Bootstrapped with ❤️ by Parra on 12/14/2024.
//  Copyright © 2024 Parra Inc.. All rights reserved.
//

import Parra
import SwiftUI

// Visit Parra's docs to learn about the features available to you.
// https://docs.parra.io/sdks/ios

struct SampleTab: View {
    @Binding var navigationPath: NavigationPath

    @Environment(\.parraTheme) private var parraTheme

    var body: some View {
        NavigationStack(path: $navigationPath) {
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
                        string: "https://docs.parra.io/cli/templates/default?platform=ios"
                    )!
                ) {
                    Text("Get started")
                        .font(.headline)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .navigationTitle("App")
            .background(parraTheme.palette.primaryBackground)
        }
    }
}

#Preview {
    ParraAppPreview {
        SampleTab(navigationPath: .constant(NavigationPath()))
    }
}
