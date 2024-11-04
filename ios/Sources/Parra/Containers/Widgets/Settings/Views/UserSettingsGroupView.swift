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

    var body: some View {
        Section {
            ForEach(group.items) { item in
                UserSettingsItemView(item: item)
                    .id(item.id)
            }
        } header: {
            VStack(alignment: .leading) {
                Text(group.title)

                withContent(content: group.description) { content in
                    Text(content)
                        .font(.subheadline)
                }
            }
        } footer: {
            footer()
        }
        .headerProminence(.increased)
    }
}
