//
//  ChangelogCell.swift
//  {{ app.name.raw }}
//
//  Bootstrapped with ❤️ by Parra on {{ "now" | date: "%m/%d/%Y" }}.
//  Copyright © {{ "now" | date: "%Y" }} {{ tenant.name }}. All rights reserved.
//

import Parra
import SwiftUI

/// This example shows how you can use your own custom logic for determining how
/// and when to present a Parra Feedback Form.
struct ChangelogCell: View {
    @State private var presentationState: ParraSheetPresentationState = .ready
    @Environment(\.parraAppInfo) private var parraAppInfo

    var showChangelog: Bool {
        guard let newInstalledVersionInfo = parraAppInfo.newInstalledVersionInfo else {
            return false
        }

        return newInstalledVersionInfo.configuration.hasOtherReleases
    }

    var body: some View {
        if showChangelog {
            ListItemLoadingButton(
                presentationState: $presentationState,
                text: "Changelog",
                symbol: "note.text"
            )
            .presentParraChangelogWidget(
                presentationState: $presentationState
            )
        }
    }
}

#Preview {
    ParraAppPreview {
        ChangelogCell()
    }
}
