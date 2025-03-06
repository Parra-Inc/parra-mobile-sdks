//
//  PickerInlineReactionView.swift
//  Parra
//
//  Created by Mick MacCallum on 12/17/24.
//

import SwiftUI

struct PickerInlineReactionView: View {
    // MARK: - Lifecycle

    init(
        reactor: StateObject<Reactor>
    ) {
        self._reactor = reactor
    }

    // MARK: - Internal

    var body: some View {
        WrappingHStack(
            alignment: .leading,
            horizontalSpacing: 8,
            verticalSpacing: 8,
            fitContentWidth: true
        ) {
            ForEach($reactor.currentReactions) { $reaction in
                ReactionButtonView(reaction: $reaction) { reacted, summary in
                    if authState.isLoggedIn || UIDevice.isPreview {
                        if reacted {
                            reactor.addExistingReaction(
                                option: summary
                            )
                        } else {
                            reactor.removeExistingReaction(
                                option: summary
                            )
                        }
                    } else {
                        ParraNotificationCenter.default.post(
                            name: Parra.signInRequiredNotification,
                            object: ParraAuthenticationFlowConfig(
                                landingScreen: .default(
                                    .defaultWith(
                                        title: "Sign in First",
                                        subtitle: "You must be signed in to add reactions",
                                        using: theme,
                                        componentFactory: componentFactory,
                                        appInfo: appInfo
                                    )
                                )
                            )
                        )
                    }
                }
            }
        }
        .contentShape(.rect)
    }

    // MARK: - Private

    @StateObject private var reactor: Reactor

    @Environment(\.parraTheme) private var theme
    @Environment(\.parraComponentFactory) private var componentFactory
    @Environment(\.parraAuthState) private var authState
    @Environment(\.parraAppInfo) private var appInfo
}

#Preview {
    ParraContainerPreview<FeedWidget>(config: .default) { parra, _, _ in
        FeedReactionView(
            feedItem: .validStates()[0],
            reactor: StateObject(
                wrappedValue: Reactor(
                    feedItemId: .uuid,
                    reactionOptionGroups: ParraReactionOptionGroup.validStates(),
                    reactions: ParraReactionSummary.validStates(),
                    api: parra.parraInternal.api,
                    submitReaction: { _, _, _ in
                        return .validStates()[0]
                    },
                    removeReaction: { _, _, _ in
                    }
                )
            ),
            showCommentCount: true
        )
    }
}
