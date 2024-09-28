//
//  ChangelogCell.swift
//  Parra Demo
//
//  Bootstrapped with ❤️ by Parra on 09/28/2024.
//  Copyright © 2024 Parra Inc.. All rights reserved.
//

import Parra
import SwiftUI

/// This example shows how you can use your own custom logic for determining how
/// and when to present a Parra Feedback Form. The steps to achieve this are:
///
/// 1. Create an `@State` variable to control the presentation state of the
///    changelog.
/// 2. Pass the `isPresented` binding to the `presentParraChangelogWidget` modifier.
/// 3. When you're ready to present the changelog, update the value of
///    `isPresented` to `true`. The changelog will be fetched and
///    presented automatically.
struct ChangelogCell: View {
    @Environment(\.parra) private var parra
    @Environment(\.parraAppInfo) private var parraAppInfo

    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var changelogInfo: ParraChangelogInfo?

    var showChangelog: Bool {
        guard let newInstalledVersionInfo = parraAppInfo.newInstalledVersionInfo else {
            return false
        }

        return newInstalledVersionInfo.configuration.hasOtherReleases
    }

    var body: some View {
        if showChangelog {
            Button(action: {
                loadChangelog()
            }) {
                Label(
                    title: {
                        Text("Changelog")
                            .foregroundStyle(Color.primary)
                    },
                    icon: {
                        if isLoading {
                            ProgressView()
                        } else {
                            Image(systemName: "note.text")
                        }
                    }
                )
            }
            .disabled(isLoading)
            .presentParraChangelogWidget(with: $changelogInfo)
        }
    }

    private func loadChangelog() {
        isLoading = true

        Task {
            do {
                errorMessage = nil
                changelogInfo = try await parra.releases.fetchChangelog()
            } catch {
                errorMessage = String(describing: error)
                changelogInfo = nil

                ParraLogger.error(error)
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
