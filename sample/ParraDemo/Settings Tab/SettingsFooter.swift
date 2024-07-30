//
//  SettingsFooter.swift
//  Parra Demo
//
//  Bootstrapped with ❤️ by Parra on 07/30/2024.
//  Copyright © 2024 Parra Inc.. All rights reserved.
//

import Parra
import SwiftUI

struct SettingsFooter: View {
    // MARK: - Internal

    @ViewBuilder var body: some View {
        let version =
            "Version \(Parra.appBundleVersionShort()!) (\(Parra.appBundleVersion()!))"

        HStack(alignment: .center) {
            Text(version)
                .font(.footnote)
                .foregroundStyle(.gray)

            Divider()

            PoweredByParraButton()
        }
        .padding(.vertical, 36)
        .frame(maxWidth: .infinity)
    }

    // MARK: - Private

    @EnvironmentObject private var appInfo: ParraAppInfo
}

#Preview {
    ParraAppPreview {
        SettingsFooter()
    }
}
