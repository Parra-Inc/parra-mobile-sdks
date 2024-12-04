//
//  UserSettingsGroupView.swift
//  Parra
//
//  Created by Mick MacCallum on 10/31/24.
//

import SwiftUI

struct UserSettingsGroupView<Footer>: View where Footer: View {
    let group: ParraUserSettingsGroup
    @ViewBuilder let footer: () -> Footer
    let onValueChanged: (
        _ key: String,
        _ value: ParraSettingsItemDataWithValue
    ) -> Void

    var body: some View {
        Section {
            ForEach(group.items, id: \.self) { item in
                UserSettingsItemView(item: item) { value in
                    onValueChanged(item.key, value)
                }
            }
        } header: {
            VStack(alignment: .leading) {
                Text(group.title)
                    .font(.headline)

                withContent(content: group.description) { content in
                    Text(content)
                        .font(.subheadline)
                }
            }
        } footer: {
            footer()
        }
    }
}
