//
//  ChannelMessageBubble.swift
//  Parra
//
//  Created by Mick MacCallum on 2/13/25.
//

import SwiftUI

struct ChannelMessageBubble: View {
    // MARK: - Internal

    enum Constant {
        static let imageSpacing: CGFloat = 4.0
        static let gutter: CGFloat = 16.0
        static let avatarSize = CGSize(width: 34, height: 34)
        static let avatarSpacing: CGFloat = 12.0
    }

    @Binding var message: Message
    var isCurrentUser: Bool

    var body: some View {
        HStack(alignment: .top, spacing: Constant.avatarSpacing) {
            avatar
            content
        }
        .padding(.horizontal, Constant.gutter)
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
        AvatarView(
            avatar: message.user?.avatar,
            size: Constant.avatarSize
        )
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

            if let attachments = message.attachments?.elements, !attachments.isEmpty {
                ChannelMessageAttachmentsView(
                    attachments: attachments
                )
            }

            if let content = message.content, !content.isEmpty {
                componentFactory.buildLabel(
                    text: content,
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
}
