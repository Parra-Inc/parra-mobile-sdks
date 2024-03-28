//
//  LatestReleaseSample.swift
//  Sample
//
//  Created by Mick MacCallum on 3/23/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import Parra
import SwiftUI

/// This example demonstrates how to use custom logic for fetching information
/// about your latest app release, and displaying the Parra Release modal to
/// display it, when ready. The steps to achieve this are:
///
/// 1. Access the Parra instance attached to your app using `@Environment`.
/// 2. Use the `parra` instance to fetch the most recent release info for your
///    app.
/// 3. Store the `NewInstalledVersionInfo` data in `@State`
/// 4. Use the `presentParraRelease` modifier and pass the app version state as
///    a parameter. When it becomes non nil, the release details screen will be
///    presented.
struct LatestReleaseSample: View {
    // MARK: - Internal

    @State var appVersionInfo: NewInstalledVersionInfo? // #3
    @State var errorMessage: String?
    @State var isLoading = false

    @Environment(\.parra) var parra // #1

    var body: some View {
        VStack {
            Button(action: {
                fetchLatestRelease()
            }, label: {
                HStack(spacing: 12) {
                    Text("Fetch and present latest release")

                    if isLoading {
                        ProgressView()
                    }
                }
            })
            .disabled(isLoading)
        }
        .presentParraRelease(with: $appVersionInfo)
    }

    // MARK: - Private

    private func fetchLatestRelease() {
        isLoading = true

        Task {
            if let appVersionInfo = try? await parra
                .fetchLatestRelease()
            { // #2
                self.appVersionInfo = appVersionInfo
                errorMessage = nil
            } else {
                errorMessage = "Failed to fetch latest release"
                appVersionInfo = nil
            }

            isLoading = false
        }
    }
}

#Preview {
    ParraAppPreview {
        LatestReleaseSample()
    }
}
