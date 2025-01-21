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
            ForEach($reactor.currentReactions) { $reaction in
                ReactionButtonView(reaction: $reaction) { reacted, summary in
                    if !userEntitlements.hasEntitlement(attachmentPaywall?.entitlement) {
                        isShowingPaywall = true
                    } else if authState.isLoggedIn || UIDevice.isPreview {
                        if reacted {
                            reactor.addExistingReaction(
                                option: summary,
                                api: parra.parraInternal.api
                            )
                        } else {
                            reactor.removeExistingReaction(
                                option: summary,
                                api: parra.parraInternal.api
                            )
                        }
                    } else {
                        isRequiredSignInPresented = true
                    }
                }
            }

            AddReactionButtonView {
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
        .onChange(of: pickerSelectedReaction) { oldValue, newValue in
            if let newValue, oldValue == nil {
                reactor.addNewReaction(
                    option: newValue,
                    api: parra.parraInternal.api
                )
            }
        }
        .presentParraPaywall(
            entitlement: attachmentPaywall?.entitlement.key ?? "unknown",
            context: attachmentPaywall?.context,
            isPresented: $isShowingPaywall,
            config: .default
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
                    selectedOption: $pickerSelectedReaction,
                    optionGroups: reactor.reactionOptionGroups,
                    showLabels: false,
                    searchEnabled: false
                )
                .presentationDetents([.large, .fraction(0.33)])
                .presentationDragIndicator(.visible)
            }
        }
    }

    // MARK: - Private

    @Environment(\.parra) private var parra
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
    ParraAppPreview {
        FeedReactionView(
            feedItemId: .uuid,
            reactor: StateObject(
                wrappedValue: Reactor(
                    feedItemId: .uuid,
                    reactionOptionGroups: ParraReactionOptionGroup.validStates(),
                    reactions: ParraReactionSummary.validStates(),
                    submitReaction: { _, _, _ in
                        return .uuid
                    },
                    removeReaction: { _, _, _ in
                    }
                )
            )
        )
    }
}
