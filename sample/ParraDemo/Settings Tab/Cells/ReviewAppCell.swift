//
//  ReviewAppCell.swift
//  Parra Demo
//
//  Bootstrapped with ❤️ by Parra on 08/01/2024.
//  Copyright © 2024 Parra Inc.. All rights reserved.
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
                        title: {
                            Text("Write a Review")
                        },
                        icon: {
                            Image(systemName: "pencil.line")
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
    ParraAppPreview(authState: .authenticatedPreview) {
        ReviewAppCell()
            .padding()
    }
}
