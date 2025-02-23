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
                HStack(alignment: .top, spacing: 20) {
                    AvatarView(
                        avatar: memberUserList.first?.avatar,
                        size: CGSize(width: 44, height: 44),
                        showVerifiedBadge: memberUserList.first?.verified == true
                    )

                    VStack(alignment: .leading) {
                        HStack {
                            componentFactory.buildLabel(
                                text: membersList,
                                localAttributes: ParraAttributes.Label(
                                    text: .default(with: .headline),
                                    padding: .zero
                                )
                            )

                            if channel.status == .closed {
                                componentFactory.buildBadge(
                                    size: .sm,
                                    variant: .outlined,
                                    text: channel.status.description
                                )
                            } else {
                                Spacer()
                            }
                        }

                        previewView
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
        .padding(.vertical, 8)
    }

    // MARK: - Private

    @Environment(\.parraTheme) private var theme
    @Environment(\.parraComponentFactory) private var componentFactory
    @Environment(\.parraAuthState) private var authState

    private var isPreviewUnread: Bool {
        guard let latestMessage else {
            return false
        }

        guard let newestViewed = ParraChannelManager.shared.newestViewedMessage(
            for: channel
        ) else {
            return true
        }

        guard let latestSender = latestMessage.user else {
            // If there's no user, it was not sent by a tenant user, therefore
            // not the current user.
            return latestMessage.createdAt > newestViewed.createdAt
        }

        guard latestSender.id == authState.user?.info.id else {
            return latestMessage.createdAt > newestViewed.createdAt
        }

        return false // is the current user
    }

    @ViewBuilder private var previewView: some View {
        componentFactory.buildLabel(
            text: latestMessage?.content ?? "No message yet",
            localAttributes: ParraAttributes.Label(
                text: .default(
                    with: .body,
                    weight: isPreviewUnread ? .bold : .regular
                ),
                padding: .zero
            )
        )
        .opacity(latestMessage?.content == nil ? 0.5 : 1.0)
        .lineLimit(2)
    }

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
        return channel.latestMessages?.elements.first
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
