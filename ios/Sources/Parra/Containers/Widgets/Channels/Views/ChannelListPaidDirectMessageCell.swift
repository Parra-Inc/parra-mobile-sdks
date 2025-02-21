//
//  ChannelListPaidDirectMessageCell.swift
//  Parra
//
//  Created by Mick MacCallum on 2/17/25.
//

import SwiftUI

struct ChannelListPaidDirectMessageCell: View {
    // MARK: - Internal

    @Binding var channel: Channel

    var body: some View {
        NavigationLink(
            value: channel,
            label: {
                HStack(alignment: .top) {
                    AvatarView(
                        avatar: memberUserList.first?.avatar
                    )

                    VStack(alignment: .leading) {
                        componentFactory.buildLabel(
                            text: membersList,
                            localAttributes: ParraAttributes.Label(
                                text: .default(with: .headline),
                                padding: .zero
                            )
                        )

                        componentFactory.buildLabel(
                            text: preview,
                            localAttributes: ParraAttributes.Label(
                                text: .default(with: .body),
                                padding: .zero
                            )
                        )
                        .lineLimit(2)

                        //                    Text(channel.status.rawValue)
                    }
                    .frame(
                        maxWidth: .infinity,
                        alignment: .leading
                    )

                    componentFactory.buildLabel(
                        text: (latestMessage?.updatedAt ?? channel.updatedAt)
                            .timeAgoAbbreviated(),
                        localAttributes: ParraAttributes.Label(
                            text: .default(with: .caption),
                            padding: .custom(
                                EdgeInsets(top: 1, leading: 0, bottom: 0, trailing: 0)
                            )
                        )
                    )
                }
            }
        )
        // Required to prevent highlighting the button then dragging the scroll
        // view from causing the button to be pressed.
        .simultaneousGesture(TapGesture())
        .buttonStyle(ContentCardButtonStyle())
        .padding(.horizontal)
        .padding(.vertical, 4)
    }

    // MARK: - Private

    @Environment(\.parraTheme) private var theme
    @Environment(\.parraComponentFactory) private var componentFactory
    @Environment(\.parraAuthState) private var authState

    private var memberUserList: [ParraUserStub] {
        guard let members = channel.members?.elements else {
            return []
        }

        let users: [ParraUserStub] = members.compactMap { member in
            guard let user = member.user else {
                return nil
            }

            if let currentUser = authState.user, currentUser.info.id == user.id {
                // remove the current user from the list
                return nil
            }

            return user
        }

        return users
    }

    private var membersList: String {
        return memberUserList.map { user in
            user.displayName
        }.toCommaList()
    }

    private var latestMessage: Message? {
        // TODO: Need to figure out what to do when new messages are updated.

        return channel.latestMessages?.elements.first
    }

    private var preview: String {
        guard let latestMessage else {
            return "No messages yet"
        }

        return latestMessage.content
    }
}

#Preview {
    ParraViewPreview { _ in
        ScrollView {
            VStack {
                ForEach(Channel.validStates()) { channel in
                    ChannelListPaidDirectMessageCell(
                        channel: .constant(channel)
                    )
                }
            }
        }
    }
}
