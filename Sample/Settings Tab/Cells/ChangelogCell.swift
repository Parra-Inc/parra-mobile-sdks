//
//  ChangelogCell.swift
//  Sample
//
//  Created by Mick MacCallum on 7/9/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import Parra
import SwiftUI

/// This example shows how you can use your own custom logic for determining how
/// and when to present a Parra Feedback Form. The steps to achieve this are:
///
/// 1. Create an `@State` variable to control the presentation state of the
///    changelog.
/// 2. Pass the `isPresented` binding to the `presentParraChangelog` modifier.
/// 3. When you're ready to present the changelog, update the value of
///    `isPresented` to `true`. The changelog will be fetched and
///    presented automatically.
struct ChangelogCell: View {
    // MARK: - Internal

    var showChangelog: Bool {
        guard let newInstalledVersionInfo = appInfo.newInstalledVersionInfo else {
            return false
        }

        return newInstalledVersionInfo.configuration.hasOtherReleases
    }

    var body: some View {
        if showChangelog {
            Button(action: {
                loadRoadmap()
            }) {
                Label(
                    title: { Text("Changelog") },
                    icon: {
                        if isLoading {
                            ProgressView()
                        } else {
                            Image(systemName: "note.text")
                        }
                    }
                )
            }
            .buttonStyle(.plain)
            .disabled(isLoading)
            .presentParraChangelog(with: $changelogInfo)
        }
    }

    // MARK: - Private

    @Environment(\.parra) private var parra
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var changelogInfo: ParraChangelogInfo?

    @EnvironmentObject private var themeObserver: ParraThemeObserver
    @EnvironmentObject private var appInfo: ParraAppInfo

    private func loadRoadmap() {
        isLoading = true

        Task {
            do {
                errorMessage = nil
                changelogInfo = try await parra.releases.fetchChangelog()
            } catch {
                errorMessage = String(describing: error)
                changelogInfo = nil

                Logger.error(error)
            }

            isLoading = false
        }
    }
}

#Preview {
    ParraAppPreview {
        ChangelogCell()
    }
}
