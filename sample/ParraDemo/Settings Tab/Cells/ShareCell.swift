//
//  ShareCell.swift
//  Parra Demo
//
//  Bootstrapped with ❤️ by Parra on 08/06/2024.
//  Copyright © 2024 Parra Inc.. All rights reserved.
//

import Parra
import SwiftUI

struct ShareCell: View {
    @EnvironmentObject private var parraAppInfo: ParraAppInfo

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
}

#Preview {
    ParraAppPreview {
        ShareCell()
    }
}
