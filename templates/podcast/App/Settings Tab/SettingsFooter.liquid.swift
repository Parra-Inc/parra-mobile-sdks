//
//  SettingsFooter.swift
//  {{ app.name.raw }}
//
//  Bootstrapped with ❤️ by Parra on {{ "now" | date: "%m/%d/%Y" }}.
//  Copyright © {{ "now" | date: "%Y" }} {{ tenant.name }}. All rights reserved.
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
