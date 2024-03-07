//
//  ParraDefaultEmptyView.swift
//  Parra
//
//  Created by Mick MacCallum on 3/6/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

struct ParraDefaultEmptyView: View {
    let symbolName: String
    let title: String
    let description: String?

    var body: some View {
        VStack(alignment: .center) {
            Spacer()

            VStack(spacing: 16) {
                Image(systemName: "tray")
                    .symbolRenderingMode(.monochrome)
                    .resizable()
                    .foregroundColor(.accentColor)
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 80)

                Text(title)
                    .font(.title)

                if let description {
                    Text(description)
                        .font(.body)
                        .multilineTextAlignment(.leading)
                }
            }
            .padding()
            .frame(
                maxWidth: .infinity,
                maxHeight: .infinity
            )

            Spacer()
        }
    }
}

#Preview {
    ParraDefaultEmptyView(
        symbolName: "tray",
        title: "Something went wrong",
        description: "Looks like we hit an error. That's our bad. We're working on preventing this from happening again!"
    )
}
