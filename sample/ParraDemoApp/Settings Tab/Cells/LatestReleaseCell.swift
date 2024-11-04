//
//  LatestReleaseCell.swift
//  Parra Demo
//
//  Bootstrapped with ❤️ by Parra on 11/04/2024.
//  Copyright © 2024 Parra Inc.. All rights reserved.
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
/// 4. Use the `presentParraReleaseWidget` modifier and pass the app version state as
///    a parameter. When it becomes non nil, the release details screen will be
///    presented.
struct LatestReleaseCell: View {
    @Environment(\.parra) private var parra // #1

    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var appVersionInfo: ParraNewInstalledVersionInfo? // #3

    var body: some View {
        if parra.releases.updateAvailable() {
            Button(action: {
                loadLatestRelease()
            }) {
                ListItemLabel(
                    text: "Update Available",
                    symbol: "arrow.down.circle"
                )
            }
            .disabled(isLoading)
            .presentParraReleaseWidget(with: $appVersionInfo)
        }
    }

    private func loadLatestRelease() {
        isLoading = true

        Task {
            if let appVersionInfo = try? await parra.releases
                .fetchLatestRelease() // #2
            {
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
        LatestReleaseCell()
    }
}
