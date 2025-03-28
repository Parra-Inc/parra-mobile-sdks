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
        CellNavigationLink(
            value: channel,
            label: {
                HStack(alignment: .top, spacing: 16) {
                    HStack(alignment: .center, spacing: 0) {
                        if isPreviewUnread {
                            Circle()
                                .foregroundStyle(
                                    theme.palette.primary.toParraColor()
                                )
                                .frame(
                                    width: 8, height: 8
                                )
                                .padding(.leading, 6)
                                .padding(.trailing, 6)

                            avatars
                        } else {
                            avatars
                                .padding(.leading, 20)
                        }
                    }

                    VStack(alignment: .leading) {
                        HStack {
                            componentFactory.buildLabel(
                                text: membersList,
                                localAttributes: ParraAttributes.Label(
                                    text: .default(with: .headline),
                                    padding: .zero
                                )
                            )

                            if channel.status == .locked {
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
                //                .swipeActions(edge: .trailing) {
                //                    Button(role: .destructive) {
                //
                //                    } label: {
                //                        Label("Archive", systemImage: "trash")
                //                    }
                //
                //                    Button {
                //
                //                    } label: {
                //                        Label("Close", systemImage: "flag")
                //                    }
                //                }
            }
        )
        .padding(.trailing, 20)
        .padding(.vertical, 8)
    }

    // MARK: - Private

    @Environment(\.parraTheme) private var theme
    @Environment(\.parraComponentFactory) private var componentFactory
    @Environment(\.parraAuthState) private var authState

    private var avatars: some View {
        AvatarView(
            avatar: memberUserList.first?.avatar,
            size: CGSize(width: 44, height: 44),
            showVerifiedBadge: memberUserList.first?.verified == true
        )
    }

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

    private var attachmentType: (Int, String)? {
        guard let attachments = latestMessage?.attachments?.elements,
              !attachments.isEmpty else
        {
            return nil
        }

        let type: AttachmentType = attachments[0].type

        for attachment in attachments[1...] {
            // When there are mixed attachment types, just say "attachment"
            if type != attachment.type {
                return (attachments.count, "attachment")
            }
        }

        switch type {
        case .image:
            return (attachments.count, "photo")
        @unknown default:
            return (attachments.count, "attachment")
        }
    }

    @ViewBuilder private var previewView: some View {
        let previewMessage = if let latestMessage {
            if let content = latestMessage.content {
                content
            } else {
                if let (count, type) = attachmentType {
                    "\(count) \(count.simplePluralized(singularString: type))"
                } else {
                    "" // ???
                }
            }
        } else {
            "No messages yet"
        }

        componentFactory.buildLabel(
            text: previewMessage,
            localAttributes: ParraAttributes.Label(
                text: .default(
                    with: .body,
                    weight: isPreviewUnread ? .semibold : .regular
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
