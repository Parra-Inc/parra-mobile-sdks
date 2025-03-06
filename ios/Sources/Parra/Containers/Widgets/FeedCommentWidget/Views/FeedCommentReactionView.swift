//
//  FeedCommentReactionView.swift
//  Parra
//
//  Created by Mick MacCallum on 12/18/24.
//

import SwiftUI

struct FeedCommentReactionView: View {
    // MARK: - Lifecycle

    init(
        comment: ParraComment,
        isReactionPickerPresented: Binding<Bool>,
        reactor: StateObject<Reactor>,
        contentObserver: StateObject<FeedCommentWidget.ContentObserver>
    ) {
        self.comment = comment
        self._isReactionPickerPresented = isReactionPickerPresented
        self._reactor = reactor
        self._contentObserver = contentObserver
    }

    // MARK: - Internal

    @StateObject var contentObserver: FeedCommentWidget.ContentObserver

    var isCurrentUser: Bool {
        return comment.user.id == authState.user?.info.id
    }

    var body: some View {
        HStack(alignment: .center, spacing: 8) {
            // Show the 3 most popular reactions, then the add reaction button,
            // then if there are more reactions, show the total reaction count.

            ForEach($reactor.firstReactions) { $reaction in
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
            .disabled(isCurrentUser)

            if !isCurrentUser {
                AddReactionButtonView(attachmentPaywall: nil) {
                    isReactionPickerPresented = true
                }
            }

            if reactor.currentReactions.count > 3 {
                componentFactory.buildLabel(
                    text: reactor.totalReactions.formatted(
                        .number
                    ),
                    localAttributes: ParraAttributes.Label(
                        text: .default(with: .caption2)
                    )
                )
            }
        }
        .contentShape(.rect)
        .sheet(
            isPresented: $isReactionPickerPresented
        ) {
            FeedCommentReactionPickerView(
                comment: comment,
                reactor: _reactor,
                showLabels: false,
                searchEnabled: false
            ) { commentId in
                contentObserver.deleteComment(commentId: commentId)
            }
            .presentationDetents([.large, .fraction(0.6)])
            .presentationDragIndicator(.visible)
        }
    }

    // MARK: - Private

    @Environment(\.parraAuthState) private var authState
    @Environment(\.parraTheme) private var theme
    @Environment(\.parraAppInfo) private var appInfo
    @Environment(\.parraComponentFactory) private var componentFactory

    @Binding private var isReactionPickerPresented: Bool

    private let comment: ParraComment
    @StateObject private var reactor: Reactor
}
