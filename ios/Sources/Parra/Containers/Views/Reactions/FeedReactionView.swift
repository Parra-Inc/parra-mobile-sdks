//
//  FeedReactionView.swift
//  Parra
//
//  Created by Mick MacCallum on 12/9/24.
//

import SwiftUI

struct FeedReactionView: View {
    // MARK: - Lifecycle

    init?(
        feedItem: ParraFeedItem,
        reactor: StateObject<Reactor>,
        showCommentCount: Bool,
        attachmentPaywall: ParraAppPaywallConfiguration? = nil
    ) {
        self.feedItem = feedItem
        self._reactor = reactor
        self.showCommentCount = showCommentCount
        self.attachmentPaywall = attachmentPaywall
    }

    // MARK: - Internal

    let feedItem: ParraFeedItem
    let showCommentCount: Bool
    let attachmentPaywall: ParraAppPaywallConfiguration?

    var body: some View {
        let accentColor = theme.palette.primaryText
            .toParraColor()
            .opacity(0.7)

        HStack(alignment: .bottom, spacing: 8) {
            WrappingHStack(
                alignment: .leading,
                horizontalSpacing: 8,
                verticalSpacing: 8,
                fitContentWidth: true
            ) {
                reactionButtons

                // Keep these together to prevent wrapping between them
                HStack(spacing: 6) {
                    AddReactionButtonView(
                        attachmentPaywall: attachmentPaywall
                    ) {
                        if UIDevice.isPreview {
                            isReactionPickerPresented = true
                        } else if !userEntitlements
                            .hasEntitlement(attachmentPaywall?.entitlement)
                        {
                            isShowingPaywall = true
                        } else if authState.isLoggedIn {
                            isReactionPickerPresented = true
                        } else {
                            isRequiredSignInPresented = true
                        }
                    }

                    if reactor.totalReactions > 0 {
                        componentFactory.buildLabel(
                            text: "\(reactor.totalReactions)",
                            localAttributes: .init(
                                text: ParraAttributes.Text(
                                    style: .caption,
                                    color: accentColor
                                )
                            )
                        )
                    }
                }
            }

            // Keep this spacer outside of condition below to prevent an
            // untappable area next to the reactions.
            Spacer()

            if showCommentCount {
                let commentCount = feedItem.comments?.commentCount ?? 0
                let hasComments = commentCount > 0

                HStack(alignment: .center, spacing: 4) {
                    componentFactory.buildImage(
                        config: .init(),
                        content: .symbol(hasComments ? "bubble.fill" : "bubble"),
                        localAttributes: ParraAttributes.Image(
                            tint: accentColor,
                            size: CGSize(width: 20, height: 20)
                        )
                    )

                    if hasComments {
                        componentFactory.buildLabel(
                            text: "\(commentCount)",
                            localAttributes: .init(
                                text: ParraAttributes.Text(
                                    style: .caption,
                                    color: accentColor
                                )
                            )
                        )
                        .padding(.bottom, 3)
                    }
                }
                .padding(.bottom, 2)
            }
        }
        .contentShape(.rect)
        .presentParraPaywall(
            entitlement: attachmentPaywall?.entitlement.key ?? "unknown",
            context: attachmentPaywall?.context,
            isPresented: $isShowingPaywall
        )
        .presentParraSignInWidget(
            isPresented: $isRequiredSignInPresented,
            config: ParraAuthenticationFlowConfig(
                landingScreen: .default(
                    .defaultWith(
                        title: "Sign in First",
                        subtitle: "You must be signed in to add reactions",
                        using: theme,
                        componentFactory: componentFactory,
                        appInfo: appInfo
                    )
                )
            ),
            onDismiss: { type in
                print("Dismissed \(type)")
            }
        )
        .sheet(
            isPresented: $isReactionPickerPresented
        ) {
            NavigationStack {
                ReactionPickerView(
                    reactor: _reactor,
                    showLabels: false,
                    searchEnabled: false
                )
                .presentationDetents([.large, .fraction(0.42)])
                .presentationDragIndicator(.visible)
            }
        }
    }

    // MARK: - Private

    @Environment(\.parraAuthState) private var authState
    @Environment(\.parraAppInfo) private var appInfo
    @Environment(\.parraTheme) private var theme
    @Environment(\.parraComponentFactory) private var componentFactory
    @Environment(\.parraUserEntitlements) private var userEntitlements

    @State private var isReactionPickerPresented: Bool = false
    @State private var isRequiredSignInPresented: Bool = false
    @State private var isShowingPaywall: Bool = false
    @State private var pickerSelectedReaction: ParraReactionOption?
    @StateObject private var reactor: Reactor

    @ViewBuilder private var reactionButtons: some View {
        ForEach($reactor.currentReactions) { $reaction in
            ReactionButtonView(reaction: $reaction) { reacted, summary in
                if !userEntitlements.hasEntitlement(attachmentPaywall?.entitlement) {
                    isShowingPaywall = true
                } else if authState.isLoggedIn || UIDevice.isPreview {
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
                    isRequiredSignInPresented = true
                }
            }
        }
    }
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
                        return .uuid
                    },
                    removeReaction: { _, _, _ in
                    }
                )
            ),
            showCommentCount: true
        )
    }
}
