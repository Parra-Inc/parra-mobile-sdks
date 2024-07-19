//
//  ShareCell.swift
//  Sample
//
//  Created by Mick MacCallum on 7/8/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
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
                        title: { Text("Share this app") },
                        icon: { Image(systemName: "square.and.arrow.up") }
                    )
                }
                .buttonStyle(.plain)

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
