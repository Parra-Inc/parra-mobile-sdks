//
//  ShareCell.swift
//  Parra Demo
//
//  Bootstrapped with ❤️ by Parra on 12/13/2024.
//  Copyright © 2024 Parra Inc.. All rights reserved.
//

import Parra
import SwiftUI

struct ShareCell: View {
    @Environment(\.parraAppInfo) private var parraAppInfo

    var body: some View {
        if let appStoreUrl = parraAppInfo.application.appStoreUrl {
            HStack {
                ShareLink(
                    item: appStoreUrl,
                    message: Text(
                        "Check out this awesome new app that I'm building using Parra!"
                    )
                ) {
                    ListItemLabel(
                        text: "Share this App",
                        symbol: "square.and.arrow.up"
                    )
                }
                .foregroundStyle(Color.primary)

                Spacer()

                Image(systemName: "arrow.up.right")
                    .foregroundStyle(.gray)
            }
        }
    }
}

#Preview {
    ParraAppPreview {
        ShareCell()
    }
}
