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
        feedItemId: String,
        reactor: StateObject<Reactor>,
        attachmentPaywall: ParraAppPaywallConfiguration? = nil
    ) {
        self.feedItemId = feedItemId
        self._reactor = reactor
        self.attachmentPaywall = attachmentPaywall
    }

    // MARK: - Internal

    let feedItemId: String
    let attachmentPaywall: ParraAppPaywallConfiguration?

    var body: some View {
        WrappingHStack(
            alignment: .leading,
            horizontalSpacing: 8,
            verticalSpacing: 8,
            fitContentWidth: true
        ) {
            reactionButtons

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
                    .init(
                        background: theme.palette.primaryBackground.toParraColor(),
                        logoView: signInLogoView,
                        titleView: signInTitleView,
                        bottomView: nil
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

    @ViewBuilder private var signInTitleView: some View {
        componentFactory.buildLabel(
            content: ParraLabelContent(
                text: "Sign in First"
            ),
            localAttributes: ParraAttributes.Label(
                text: ParraAttributes.Text(
                    font: .systemFont(ofSize: 50, weight: .heavy),
                    alignment: .center
                ),
                padding: .md
            )
        )
        .minimumScaleFactor(0.5)
        .lineLimit(2)

        componentFactory.buildLabel(
            content: ParraLabelContent(text: "You must be signed in to add reactions"),
            localAttributes: ParraAttributes.Label(
                text: .default(with: .subheadline),
                padding: .zero
            )
        )
    }

    @ViewBuilder private var signInLogoView: some View {
        if let logo = appInfo.tenant.logo {
            componentFactory.buildAsyncImage(
                content: ParraAsyncImageContent(
                    logo,
                    preferredThumbnailSize: .lg
                ),
                localAttributes: ParraAttributes.AsyncImage(
                    size: CGSize(width: 200, height: 200),
                    padding: .zero
                )
            )
        }
    }
}

#Preview {
    ParraContainerPreview<FeedWidget>(config: .default) { parra, _, _ in
        FeedReactionView(
            feedItemId: .uuid,
            reactor: StateObject(
                wrappedValue: Reactor(
                    feedItemId: .uuid,
                    reactionOptionGroups: ParraReactionOptionGroup.validStates(),
                    reactions: ParraReactionSummary.validStates(),
                    api: parra.parraInternal.api
                )
            )
        )
    }
}
