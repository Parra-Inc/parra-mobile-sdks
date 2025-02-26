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

                avatarView(for: user)
            }
            .frame(maxWidth: .infinity)
        } else {
            HStack(alignment: .center, spacing: 6) {
                HStack(spacing: -20) {
                    ForEach(Array(users.enumerated()), id: \.element) { index, user in
                        avatarView(
                            for: user,
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
            }
        }
    }

    @ViewBuilder
    private func avatarView(
        for user: ParraUserStub,
        showLoadingIndicator: Bool = true
    ) -> some View {
        AvatarView(
            avatar: user.avatar,
            showLoadingIndicator: showLoadingIndicator,
            showVerifiedBadge: user.verified == true
        )
    }
}
