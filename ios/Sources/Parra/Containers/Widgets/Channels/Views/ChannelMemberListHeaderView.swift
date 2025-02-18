//
//  ChannelMemberListHeaderView.swift
//  Parra
//
//  Created by Mick MacCallum on 2/13/25.
//

import SwiftUI

struct ChannelMemberListHeaderView: View {
    // MARK: - Internal

    var users: [ParraUserStub]

    var body: some View {
        content.contextMenu {
            // full user list
            VStack {
                ForEach(users) { user in
                    componentFactory.buildLabel(
                        text: user.displayName,
                        localAttributes: .default(with: .callout)
                    )
                }
            }
        }
    }

    // MARK: - Private

    @Environment(\.parraTheme) private var theme
    @Environment(\.parraComponentFactory) private var componentFactory
    @Environment(\.redactionReasons) private var redactionReasons

    @ViewBuilder private var content: some View {
        if users.isEmpty {
            EmptyView()
        } else if users.count == 1 {
            HStack {
                let user = users[0]
                AvatarView(avatar: user.avatar)

                // Don't know why, but if we use the component factory label here
                // it doesn't get rendered.
                Text(verbatim: user.displayName)
                    .applyTextAttributes(.default(with: .headline), using: theme)

                componentFactory.buildLabel(
                    text: user.displayName,
                    localAttributes: ParraAttributes.Label(
                        text: .default(with: .headline),
                        padding: .zero
                    )
                )
            }
            .frame(maxWidth: .infinity)
        } else {
            HStack(alignment: .center, spacing: 6) {
                HStack(spacing: -20) {
                    ForEach(Array(users.enumerated()), id: \.element) {
                        index,
                            user
                        in
                        AvatarView(
                            avatar: user.avatar,
                            showLoadingIndicator: index == users.count - 1
                        )
                        .background(
                            theme.palette.primarySeparator.toParraColor()
                        )
                        .applyCornerRadii(size: .full, from: theme)
                        .applyBorder(
                            borderColor: theme.palette.secondarySeparator
                                .toParraColor(),
                            borderWidth: 2,
                            cornerRadius: .full,
                            from: theme
                        )
                    }
                }

                let names = if users.count == 2 {
                    users.map(\.displayName).toCommaList()
                } else {
                    "\(users.count) people"
                }

                // Don't know why, but if we use the component factory label here
                // it doesn't get rendered.
                Text(verbatim: names)
                    .applyTextAttributes(.default(with: .headline), using: theme)
            }
        }
    }
}
