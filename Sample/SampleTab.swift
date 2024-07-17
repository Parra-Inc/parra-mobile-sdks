//
//  SampleTab.swift
//  Sample
//
//  Created by Mick MacCallum on 4/18/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import Parra
import SwiftUI

struct SampleTab: View {
    // MARK: - Internal

    var body: some View {
        NavigationStack {
            VStack {
                Link(
                    destination: URL(
                        string: "https://docs.parra.io/sdks/guides/quickstart/swiftui"
                    )!
                ) {
                    Text("Get started")
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .navigationTitle("Your app")
            .background(themeObserver.theme.palette.secondaryBackground)
        }
    }

    // MARK: - Private

    @EnvironmentObject private var themeObserver: ParraThemeObserver
}

#Preview {
    ParraAppPreview {
        SampleTab()
    }
}
