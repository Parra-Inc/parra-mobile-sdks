//
//  ChangelogCell.swift
//  Parra Demo
//
//  Bootstrapped with ❤️ by Parra on 11/14/2024.
//  Copyright © 2024 Parra Inc.. All rights reserved.
//

import Parra
import SwiftUI

/// This example shows how you can use your own custom logic for determining how
/// and when to present a Parra Feedback Form.
struct ChangelogCell: View {
    @State private var isPresented = false
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
                isLoading: $isPresented,
                text: "Changelog",
                symbol: "note.text"
            )
            .presentParraChangelogWidget(isPresented: $isPresented)
        }
    }
}

#Preview {
    ParraAppPreview {
        ChangelogCell()
    }
}
