//
//  ReviewAppCell.swift
//  Sample
//
//  Created by Mick MacCallum on 7/8/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import Parra
import SwiftUI

struct ReviewAppCell: View {
    // MARK: - Internal

    var body: some View {
        if let writeReviewUrl = parraAppInfo.application
            .appStoreWriteReviewUrl
        {
            HStack {
                Link(
                    destination: writeReviewUrl
                ) {
                    Label(
                        title: { Text("Write a review") },
                        icon: { Image(systemName: "pencil.line") }
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
    ParraAppPreview(authState: .authenticatedPreview) {
        ReviewAppCell()
            .padding()
    }
}
