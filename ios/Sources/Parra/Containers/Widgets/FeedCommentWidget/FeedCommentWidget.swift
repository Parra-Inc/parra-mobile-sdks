//
//  FeedCommentWidget.swift
//  Parra
//
//  Created by Mick MacCallum on 12/17/24.
//

import SwiftUI
import UIKit

struct FeedCommentWidget: ParraContainer {
    // MARK: - Lifecycle

    init(
        config: ParraFeedCommentWidgetConfig,
        contentObserver: ContentObserver,
        navigationPath: Binding<NavigationPath>
    ) {
        self.config = config
        self._contentObserver = StateObject(wrappedValue: contentObserver)
    }

    // MARK: - Internal

    @StateObject var contentObserver: ContentObserver
    let config: ParraFeedCommentWidgetConfig

    let timer = Timer.publish(
        every: 15,
        on: .main,
        in: .common
    ).autoconnect()

    var comments: Binding<[ParraComment]> {
        return $contentObserver.commentPaginator.items
    }

    @ViewBuilder var commentStack: some View {
        LazyVStack(spacing: 0) {
            let recentMessage = userEntitlements.hasEntitlement(
                contentObserver.attachmentPaywall?.entitlement
            ) ? "Recent Comments (\(contentObserver.totalComments))" : ""

            HStack {
                componentFactory.buildLabel(
                    text: recentMessage,
                    localAttributes: .default(with: .headline)
                )
                .frame(
                    maxWidth: .infinity,
                    alignment: .leading
                )

                Spacer()
            }
            .padding(.top, 10)
            .padding(.bottom, 6)
            .padding(.horizontal, 16)

            ParraPaywalledContentView(
                entitlement: contentObserver.attachmentPaywall?.entitlement,
                context: contentObserver.attachmentPaywall?.context
            ) { requiredEntitlement, _ in
                FeedCommentsView(
                    feedItem: contentObserver.feedItem,
                    comments: comments,
                    requiredEntitlement: requiredEntitlement,
                    context: contentObserver.attachmentPaywall?.context
                ) { index in
                    contentObserver.commentPaginator.loadMore(
                        after: index
                    )
                }
            } unlockedContentBuilder: {
                FeedCommentsView(
                    feedItem: contentObserver.feedItem,
                    comments: comments,
                    requiredEntitlement: nil,
                    context: nil
                ) { index in
                    contentObserver.commentPaginator.loadMore(
                        after: index
                    )
                }
            }
        }
        .padding(.vertical)
        .background(theme.palette.secondaryBackground)
        .redacted(
            when: contentObserver.commentPaginator.isShowingPlaceholders
        )
        .emptyPlaceholder(comments) {
            if !contentObserver.commentPaginator.isLoading {
                componentFactory.buildEmptyState(
                    config: .init(
                        alignment: .center
                    ),
                    content: contentObserver.content.emptyStateView,
                    localAttributes: emptyStateAttributes
                )
                .frame(
                    minHeight: 300
                )
            } else {
                EmptyView()
            }
        }
        .errorPlaceholder(contentObserver.commentPaginator.error) {
            componentFactory.buildEmptyState(
                config: .init(
                    alignment: .center
                ),
                content: contentObserver.content.errorStateView,
                localAttributes: emptyStateAttributes
            )
            .frame(
                minHeight: 300
            )
        }
    }

    @ViewBuilder var scrollView: some View {
        ScrollView {
            VStack(spacing: 0) {
                AnyView(config.headerViewBuilder())

                if let commentInfo = contentObserver.feedItem.comments {
                    if !commentInfo.disabled {
                        commentStack
                    }
                } else {
                    commentStack
                }

                AnyView(config.footerViewBuilder())
            }
        }
        .background(theme.palette.secondaryBackground)
        // Can't use interactive since this bug will occur
        // https://github.com/feedback-assistant/reports/issues/437
        .scrollDismissesKeyboard(.automatic)
    }

    var body: some View {
        VStack(spacing: 0) {
            ScrollViewReader { proxy in
                scrollView.contentMargins(
                    .bottom,
                    EdgeInsets(top: 0, leading: 0, bottom: 65, trailing: 0),
                    for: .scrollContent
                )
                .contentMargins(
                    .bottom,
                    EdgeInsets(top: 0, leading: 0, bottom: 70, trailing: 0),
                    for: .scrollIndicators
                )
                .overlay(
                    alignment: .bottom
                ) {
                    if let commentInfo = contentObserver.feedItem.comments {
                        if !commentInfo.disabled {
                            addCommentBar(proxy: proxy)
                        }
                    }
                }
            }

            Color(theme.palette.primaryBackground)
                .frame(height: 1)
                .ignoresSafeArea()
        }
        .background(theme.palette.primaryBackground)
        .onAppear {
            // This is a slightly nicer visual since they load in too quickly
            // half way through transitioning to the screen.
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                contentObserver.loadComments()
            }
        }
        .refreshable {
            await contentObserver.refresh()
        }
        .onReceive(timer) { _ in
            contentObserver.checkForNewComments()
        }
        .presentParraPaywall(
            entitlement: contentObserver.attachmentPaywall?.entitlement.key ?? "unknown",
            context: contentObserver.attachmentPaywall?.context,
            presentationState: $paywallPresentationState
        )
        .presentParraSignInWidget(
            isPresented: $isRequiredSignInPresented,
            config: ParraAuthenticationFlowConfig(
                landingScreen: .default(
                    .defaultWith(
                        title: "Sign in First",
                        subtitle: "You must be signed in to add comments",
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
    }

    // MARK: - Private

    @State private var headerHeight: CGFloat = 0
    @State private var footerHeight: CGFloat = 0
    @State private var isRequiredSignInPresented: Bool = false
    @State private var paywallPresentationState = ParraSheetPresentationState.ready

    @Environment(\.parraComponentFactory) private var componentFactory
    @Environment(\.parraTheme) private var theme
    @Environment(\.parraAuthState) private var authState
    @Environment(\.parraUserEntitlements) private var userEntitlements
    @Environment(\.parraAppInfo) private var appInfo

    @State private var allowSubmission = false

    private var emptyStateAttributes: ParraAttributes.EmptyState {
        ParraAttributes.EmptyState(
            titleLabel: .default(
                with: .title3,
                alignment: .center
            ),
            subtitleLabel: .default(
                with: .body,
                alignment: .center
            ),
            padding: .custom(
                EdgeInsets(
                    top: 0,
                    leading: 0,
                    bottom: 28,
                    trailing: 0
                )
            ),
            background: theme.palette.secondaryBackground
        )
    }

    @ViewBuilder
    private func addCommentBar(
        proxy: ScrollViewProxy
    ) -> some View {
        AddCommentBarView(
            allowSubmission: $allowSubmission
        ) { text in
            guard let user = authState.user else {
                Logger.error("Tried to submit a comment without a user")

                return false
            }

            if !userEntitlements.hasEntitlement(
                contentObserver.attachmentPaywall?.entitlement
            ) {
                Task { @MainActor in
                    await UIApplication.dismissKeyboard()
                }

                DispatchQueue.main.asyncAfter(
                    deadline: .now() + 0.1
                ) {
                    paywallPresentationState = .loading
                }
            } else if authState.isLoggedIn {
                withAnimation {
                    let newComment = contentObserver.addComment(
                        with: text,
                        from: user
                    )

                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                        withAnimation {
                            proxy.scrollTo(
                                newComment,
                                anchor: .center
                            )
                        }
                    }
                }

                return true
            } else {
                Task { @MainActor in
                    await UIApplication.dismissKeyboard()
                }

                DispatchQueue.main.asyncAfter(
                    deadline: .now() + 0.1
                ) {
                    isRequiredSignInPresented = true
                }
            }

            return false
        }
    }
}

#Preview {
    ParraContainerPreview<FeedCommentWidget>(
        config: .default
    ) { parra, _, config in
        TabView {
            FeedCommentWidget(
                config: .init(
                    headerViewBuilder: {
                        VStack {
                            Text("HEADER")
                        }
                        .background(.orange)
                        .frame(
                            height: 300
                        )
                    }
                ),
                contentObserver: .init(
                    initialParams: FeedCommentWidget.ContentObserver.InitialParams(
                        feedItem: .validStates()[0],
                        config: .default,
                        commentsResponse: .validStates()[0],
                        attachmentPaywall: nil,
                        api: parra.parraInternal.api
                    )
                ),
                navigationPath: .constant(.init())
            )
            .tabItem {
                Label("Test", systemImage: "lightbulb")
            }
            .tag("test")
        }
    }
}
