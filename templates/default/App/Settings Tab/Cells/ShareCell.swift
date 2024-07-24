//
//  ShareCell.swift
//  {{ app.name }}
//
//  Bootstrapped with ❤️ by Parra on {{ "now" | date: "%m/%d/%Y" }}.
//  Copyright © {{ "now" | date: "%Y" }} {{ tenant.name }}. All rights reserved.
//

import Parra
import SwiftUI

struct ShareCell: View {
    // MARK: - Internal

    var body: some View {
        if let appStoreUrl = parraAppInfo.application.appStoreUrl {
            HStack {
                ShareLink(
                    item: appStoreUrl,
                    message: Text(
                        "Check out this awesome new app that I'm building using Parra!"
                    )
                ) {
                    Label(
                        title: {
                            Text("Share This App")
                        },
                        icon: {
                            Image(systemName: "square.and.arrow.up")
                                .foregroundStyle(.tint)
                        }
                    )
                }
                .foregroundStyle(Color.primary)

                Spacer()

                Image(systemName: "arrow.up.right")
                    .foregroundStyle(.gray)
            }
        }
    }

    // MARK: - Private

    @EnvironmentObject private var parraAppInfo: ParraAppInfo
}

#Preview {
    ParraAppPreview {
        ShareCell()
    }
}
