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
            ShareLink(
                item: appStoreUrl,
                message: Text(
                    "Check out this awesome new app that I'm building using Parra!"
                )
            ) {
                Label(
                    title: { Text("Share \(parraAppInfo.application.name)") },
                    icon: { Image(systemName: "square.and.arrow.up") }
                )
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
