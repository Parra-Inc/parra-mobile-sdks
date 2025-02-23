//
//  ChannelWidget.swift
//  Parra
//
//  Created by Mick MacCallum on 2/13/25.
//

import SwiftUI

struct ChannelWidget: ParraContainer {
    // MARK: - Lifecycle

    init(
        config: ParraChannelConfiguration,
        contentObserver: ContentObserver,
        navigationPath: Binding<NavigationPath>
    ) {
        self.config = config
        self._contentObserver = StateObject(wrappedValue: contentObserver)

        _navigationPath = navigationPath
    }

    // MARK: - Internal

    @StateObject var contentObserver: ContentObserver
    @Binding var navigationPath: NavigationPath
    let config: ParraChannelConfiguration

    // Until we have websockets, this will have to do.
    let timer = Timer.publish(
        every: 15,
        on: .main,
        in: .common
    ).autoconnect()

    var messages: Binding<[Message]> {
        return $contentObserver.messagePaginator.items
    }

    var body: some View {
        let defaultWidgetAttributes = ParraAttributes.Widget.default(
            with: parraTheme
        )

        let contentPadding = parraTheme.padding.value(
            for: defaultWidgetAttributes.contentPadding
        )

        scrollView(
            with: contentPadding
        )
        .applyWidgetAttributes(
            attributes: defaultWidgetAttributes.withoutContentPadding(),
            using: parraTheme
        )
        .environment(config)
        .environment(componentFactory)
        .environmentObject(contentObserver)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            contentObserver.loadInitialMessages()

            newestViewedMessage = ParraChannelManager.shared.newestViewedMessage(
                for: contentObserver.channel
            )
        }
        .onReceive(timer) { _ in
            contentObserver.checkForNewMessages()
        }
        .toolbar {
            ToolbarItem(placement: .principal) {
                if let members = contentObserver.channel.members?.elements {
                    let users: [ParraUserStub] = members
                        .sorted { m1, m2 in
                            // rough, but assuming more roles means more important
                            // so display first
                            return m1.roles.elements.count > m2.roles.elements.count
                        }
                        .compactMap { member in
                            if let currentUser = authState.user,
                               currentUser.info.id == member.user?.id
                            {
                                // remove the current user from the list
                                return nil
                            }

                            return member.user
                        }

                    HStack {
                        Spacer()

                        ChannelMemberListHeaderView(users: users)

                        Spacer()
                    }
                    .frame(width: 100)
                } else {
                    // Need to render something to occupy the space before data
                    // loads preventing the navigation back button from changing
                    // once the view is visible.
                    Color.clear
                        .frame(minWidth: 50)
                }
            }
        }
    }

    // MARK: - Private

    @State private var newestViewedMessage: ParraChannelManager.ChannelInfo.ViewedMessage?

    @Environment(\.parraAuthState) private var authState

    @Environment(\.parraComponentFactory) private var componentFactory
    @Environment(\.parraAlertManager) private var alertManager
    @Environment(\.parraTheme) private var parraTheme
    @Environment(\.parraUserEntitlements) private var userEntitlements
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(\.verticalSizeClass) private var verticalSizeClass

    @ViewBuilder private var messageStack: some View {
        LazyVStack {
            ForEach(messages) { message in
                let isCurrentUser = if let currentUser = authState.user {
                    currentUser.info.id == message.wrappedValue.user?.id
                } else {
                    false
                }

                ChannelMessageBubble(
                    message: message,
                    isCurrentUser: isCurrentUser
                )
                .redacted(
                    when: contentObserver.messagePaginator.isShowingPlaceholders
                )
                .onAppear {
                    ParraChannelManager.shared.viewMessage(
                        message.wrappedValue,
                        for: contentObserver.channel
                    )
                }
            }
            .upsideDown()
        }
    }

    @ViewBuilder private var emptyContent: some View {
        if !contentObserver.messagePaginator.isLoading {
            VStack {
                Spacer()
                componentFactory.buildEmptyState(
                    config: .default,
                    content: contentObserver.content.emptyStateView
                )
                Spacer()
            }
        }
    }

    @ViewBuilder private var errorContent: some View {
        VStack {
            Spacer()
            componentFactory.buildEmptyState(
                config: .errorDefault,
                content: contentObserver.content.errorStateView
            )
            Spacer()
        }
    }

    @ViewBuilder
    private func addCommentBar(
        with proxy: ScrollViewProxy
    ) -> some View {
        AddCommentBarView { text in
            guard let user = authState.user else {
                Logger.error("Tried to submit a comment without a user")

                return false
            }

            do {
                try withAnimation {
                    let newMessage = try contentObserver.sendMessage(
                        with: text,
                        from: user
                    )

                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                        withAnimation {
                            proxy.scrollTo(
                                newMessage,
                                anchor: .center
                            )
                        }
                    }
                }

                return true
            } catch {
                alertManager
                    .showErrorToast(
                        title: "Error sending message",
                        userFacingMessage: "Something went wrong sending that message. Please try again.",
                        underlyingError: error
                    )

                return false
            }
        }
    }

    @ViewBuilder
    private func scrollView(
        with contentPadding: EdgeInsets
    ) -> some View {
        ScrollViewReader { proxy in
            VStack {
                ScrollView {
                    messageStack
                }
                .upsideDown()
                // A limited number of placeholder cells will be generated.
                // Don't allow scrolling past them while loading.
                .scrollDisabled(
                    contentObserver.messagePaginator.isShowingPlaceholders
                )
                .contentMargins(
                    .vertical,
                    contentPadding.bottom / 2,
                    for: .scrollContent
                )
                .emptyPlaceholder(messages) {
                    emptyContent
                }
                .errorPlaceholder(contentObserver.messagePaginator.error) {
                    errorContent
                }
                .refreshable {
                    contentObserver.refresh()
                }

                addCommentBar(with: proxy)
            }
            .frame(
                maxWidth: .infinity,
                maxHeight: .infinity
            )
        }
    }
}

#Preview {
    ParraContainerPreview<ChannelWidget>(
        config: .default,
        authState: .authenticatedPreview
    ) { parra, _, config in
        NavigationStack {
            ChannelWidget(
                config: .default,
                contentObserver: .init(
                    initialParams: ChannelWidget.ContentObserver.InitialParams(
                        config: .default,
                        channel: .validStates()[0],
                        requiredEntitlement: "",
                        context: nil,
                        api: parra.parraInternal.api
                    )
                ),
                navigationPath: .constant(.init())
            )
        }
    }
}
