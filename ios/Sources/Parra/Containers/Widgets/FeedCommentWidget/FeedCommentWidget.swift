//
//  FeedCommentWidget.swift
//  Parra
//
//  Created by Mick MacCallum on 12/17/24.
//

import SwiftUI

struct KeyboardProvider: ViewModifier {
    var keyboardHeight: Binding<CGFloat>

    func body(content: Content) -> some View {
        content
            .onReceive(
                NotificationCenter.default
                    .publisher(for: UIResponder.keyboardWillShowNotification),
                perform: { notification in
                    guard let userInfo = notification.userInfo,
                          let keyboardRect =
                          userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else {
                        return
                    }

                    keyboardHeight.wrappedValue = keyboardRect.height
                }
            ).onReceive(
                NotificationCenter.default
                    .publisher(for: UIResponder.keyboardWillHideNotification),
                perform: { _ in
                    keyboardHeight.wrappedValue = 0
                }
            )
    }
}

public extension View {
    func keyboardHeight(_ state: Binding<CGFloat>) -> some View {
        modifier(KeyboardProvider(keyboardHeight: state))
    }
}

struct FeedCommentWidget: ParraContainer {
    // MARK: - Lifecycle

    init(
        config: FeedCommentWidgetConfig,
        contentObserver: ContentObserver,
        navigationPath: Binding<NavigationPath>
    ) {
        self.config = config
        self._contentObserver = StateObject(wrappedValue: contentObserver)
    }

    // MARK: - Internal

    @StateObject var contentObserver: ContentObserver
    let config: FeedCommentWidgetConfig

    var comments: Binding<[ParraComment]> {
        return $contentObserver.commentPaginator.items
    }

    var commentsTitle: String? {
        if comments.isEmpty {
            return nil
        }

        if comments.count == 1 {
            return "1 Comment"
        }

        return "\(comments.count) Comments"
    }

    @ViewBuilder var scrollView: some View {
        ScrollView {
            VStack(spacing: 0) {
                AnyView(config.headerViewBuilder())

                LazyVStack(spacing: 0) {
                    if let commentsTitle {
                        componentFactory.buildLabel(
                            text: commentsTitle,
                            localAttributes: .default(with: .headline)
                        )
                        .frame(
                            maxWidth: .infinity,
                            alignment: .leading
                        )
                        .padding(.bottom, 4)
                        .padding(.leading, 16)
                    }

                    FeedCommentsView(
                        feedItem: contentObserver.feedItem,
                        comments: comments
                    )
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
                            localAttributes: ParraAttributes.EmptyState(
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
                        config: .errorDefault,
                        content: contentObserver.content.errorStateView
                    )
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
                scrollView
                    .contentMargins(
                        .bottom,
                        EdgeInsets(top: 0, leading: 0, bottom: 65, trailing: 0),
                        for: .scrollContent
                    )
                    .contentMargins(
                        .bottom,
                        EdgeInsets(top: 0, leading: 0, bottom: 70, trailing: 0),
                        for: .scrollIndicators
                    )
                    .overlay(alignment: .bottom) {
                        AddCommentBarView { text in
                            guard let user = authState.user else {
                                Logger.error("Tried to submit a comment without a user")

                                return
                            }

                            withAnimation {
                                let newComment = contentObserver.addComment(
                                    with: text,
                                    from: user
                                )

                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                                    withAnimation {
                                        proxy.scrollTo(newComment, anchor: .bottom)
                                    }
                                }
                            }
                        }
                    }
            }

            Color(theme.palette.primaryBackground)
                .frame(height: 1)
                .ignoresSafeArea()
        }
        .keyboardHeight($keyboardHeight)
        .background(theme.palette.primaryBackground)
        .onAppear {
            // This is a slightly nicer visual since they load in too quickly
            // half way through transitioning to the screen.
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                contentObserver.loadComments()
            }
        }
    }

    // MARK: - Private

    @State private var keyboardHeight: CGFloat = 0

    @State private var headerHeight: CGFloat = 0
    @State private var footerHeight: CGFloat = 0

    @Environment(\.parraComponentFactory) private var componentFactory
    @Environment(\.parraTheme) private var theme
    @Environment(\.parraAuthState) private var authState
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
