//
//  UserSettingsItemInfoView.swift
//  Parra
//
//  Created by Mick MacCallum on 10/31/24.
//

import SwiftUI

struct UserSettingsItemInfoView: View {
    let item: ParraUserSettingsItem

    var body: some View {
        VStack(alignment: .leading) {
            Text(item.title)
                .lineLimit(1)

            withContent(content: item.description) { content in
                Text(content)
                    .font(.subheadline)
                    .lineLimit(3)
            }
        }
        .frame(
            maxWidth: .infinity,
            alignment: .leading
        )
        .layoutPriority(10)
    }
}
