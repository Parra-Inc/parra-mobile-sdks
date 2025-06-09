//
//  SettingsFooter.swift
//  Parra Demo
//
//  Bootstrapped with ❤️ by Parra on 06/09/2025.
//  Copyright © 2025 Parra Inc.. All rights reserved.
//

import Parra
import SwiftUI

struct SettingsFooter: View {
    @Environment(\.parraAppInfo) private var parraAppInfo

    @ViewBuilder 
    var body: some View {
        let version =
            "Version \(Parra.appBundleVersionShort()!) (\(Parra.appBundleVersion()!))"

        HStack(alignment: .center) {
            Text(version)
                .font(.footnote)
                .foregroundStyle(.gray)

            if !parraAppInfo.tenant.hideBranding {
                Divider()

                PoweredByParraButton()
            }
        }
        .padding(.vertical, 36)
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    ParraAppPreview {
        SettingsFooter()
    }
}
