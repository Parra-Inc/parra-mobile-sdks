//
//  ChannelMessageBubble.swift
//  Parra
//
//  Created by Mick MacCallum on 2/13/25.
//

import SwiftUI

struct ChannelMessageBubble: View {
    // MARK: - Internal

    @Binding var message: Message
    var isCurrentUser: Bool

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            avatar
            content
        }
        .padding(.horizontal)
        .padding(.top, 4)
        .padding(.bottom, 8)
        .frame(
            maxWidth: .infinity,
            alignment: .leading
        )
    }

    // MARK: - Private

    @Environment(\.parraTheme) private var theme
    @Environment(\.parraComponentFactory) private var componentFactory
    @Environment(\.redactionReasons) private var redactionReasons

    @ViewBuilder private var avatar: some View {
        AvatarView(avatar: message.user?.avatar)
    }

    @ViewBuilder private var content: some View {
        VStack(
            alignment: .leading,
            spacing: 6
        ) {
            HStack(alignment: .center, spacing: 6) {
                if let user = message.user {
                    UserWithRolesView(user: user)
                }

                componentFactory.buildLabel(
                    text: message.createdAt.timeAgoAbbreviated(),
                    localAttributes: ParraAttributes.Label(
                        text: .default(with: .caption),
                        padding: .custom(
                            EdgeInsets(top: 1, leading: 0, bottom: 0, trailing: 0)
                        )
                    )
                )
            }

            componentFactory.buildLabel(
                text: message.content,
                localAttributes: ParraAttributes.Label(
                    text: .default(
                        with: .body,
                        color: isCurrentUser ? theme.palette.primaryChipText
                            .toParraColor() : theme.palette.secondaryChipText
                            .toParraColor()
                    ),
                    cornerRadius: .lg,
                    padding: .xl,
                    background: isCurrentUser ? theme.palette.primaryChipBackground
                        .toParraColor() : theme.palette.secondaryChipBackground
                        .toParraColor()
                )
            )
        }
    }
}
