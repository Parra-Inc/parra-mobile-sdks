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
            with: theme
        )

        let contentPadding = theme.padding.value(
            for: defaultWidgetAttributes.contentPadding
        )

        scrollView(
            with: contentPadding
        )
        .applyWidgetAttributes(
            attributes: defaultWidgetAttributes.withoutContentPadding(),
            using: theme
        )
        .environment(config)
        .environment(componentFactory)
        .environmentObject(contentObserver)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            ParraChannelManager.shared.visibleChannelId = contentObserver.channel.id

            contentObserver.loadInitialMessages()

            newestViewedMessage = ParraChannelManager.shared.newestViewedMessage(
                for: contentObserver.channel
            )
        }
        .onDisappear {
            ParraChannelManager.shared.visibleChannelId = nil
        }
        .onReceive(
            NotificationCenter.default.publisher(
                for: UIScene.willEnterForegroundNotification
            )
        ) { _ in
            ParraChannelManager.shared.visibleChannelId = contentObserver.channel.id
        }
        .onReceive(
            NotificationCenter.default.publisher(
                for: UIScene.didEnterBackgroundNotification
            )
        ) { _ in
            ParraChannelManager.shared.visibleChannelId = nil
        }
        .onReceive(timer) { _ in
            contentObserver.checkForNewMessages()
        }
        .onChange(of: contentObserver.channel, initial: true) { _, newValue in
            if newValue.hasMemberRole(authState.user, role: .admin) {
                // Admins can still send messages to closed channels
                allowSubmission = newValue.status != .archived
            } else {
                allowSubmission = newValue.status == .active
            }
        }
        .confirmationDialog(
            "Lock Conversation",
            isPresented: $isConfirmingLock,
            titleVisibility: .visible
        ) {
            Button("Cancel", role: .cancel) {}

            Button("Lock", role: .destructive) {
                Task { @MainActor in
                    do {
                        try await contentObserver.adminLockChannel()
                    } catch {
                        alertManager.showErrorToast(
                            title: "Error Locking Conversation",
                            userFacingMessage: "Something went wrong locking the conversation. Please try again.",
                            underlyingError: error
                        )
                    }
                }
            }
        } message: {
            Text(
                "Members will no longer be able to send messages without paying to unlock the conversation. Admins (including you) can still send messages."
            )
        }
        .confirmationDialog(
            "Unlock Conversation",
            isPresented: $isConfirmingUnlock,
            titleVisibility: .visible
        ) {
            Button("Cancel", role: .cancel) {}

            Button("Unlock") {
                Task { @MainActor in
                    do {
                        try await contentObserver.adminUnlockChannel()
                    } catch {
                        alertManager.showErrorToast(
                            title: "Error Unlocking Conversation",
                            userFacingMessage: "Something went wrong unlocking the conversation. Please try again.",
                            underlyingError: error
                        )
                    }
                }
            }
        } message: {
            Text(
                "All members will be allowed to send messages again."
            )
        }
        .confirmationDialog(
            "Leave Conversation",
            isPresented: $isConfirmingLeave,
            titleVisibility: .visible
        ) {
            Button("Cancel", role: .cancel) {}

            Button("Leave", role: .destructive) {
                Task { @MainActor in
                    do {
                        try await contentObserver.adminLeaveChannel()

                        // Relies on navigating back triggering a refresh, which
                        // will cause the channel to be removed from the list
                        dismiss()
                    } catch {
                        alertManager.showErrorToast(
                            title: "Error Leaving Conversation",
                            userFacingMessage: "Something went wrong leaving the conversation. Please try again.",
                            underlyingError: error
                        )
                    }
                }
            }
        } message: {
            Text(
                "Removes this conversation from your messages list and lock it so that no new messages can be added by other members. Other members will still be able to see the conversation."
            )
        }
        .confirmationDialog(
            "Archive Conversation",
            isPresented: $isConfirmingArchive,
            titleVisibility: .visible
        ) {
            Button("Cancel", role: .cancel) {}

            Button("Archive", role: .destructive) {
                Task { @MainActor in
                    do {
                        try await contentObserver.adminArchiveChannel()

                        // Relies on navigating back triggering a refresh, which
                        // will cause the channel to be removed from the list
                        dismiss()
                    } catch {
                        alertManager.showErrorToast(
                            title: "Error Archiving Conversation",
                            userFacingMessage: "Something went wrong archiving the conversation. Please try again.",
                            underlyingError: error
                        )
                    }
                }
            }
        } message: {
            Text(
                "This conversation will be deleted and not visible to anyone. This action should only be taken when a member posts inappropriate content or is otherwise abusive."
            )
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                if contentObserver.channel.hasMemberRole(
                    authState.user,
                    role: .admin
                ) {
                    AdminMenuView(
                        isConfirmingLock: $isConfirmingLock,
                        isConfirmingUnlock: $isConfirmingUnlock,
                        isConfirmingLeave: $isConfirmingLeave,
                        isConfirmingArchive: $isConfirmingArchive,
                        contentObserver: contentObserver
                    )
                } else {
                    ParraDismissButton()
                }
            }

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

                    ChannelMemberListHeaderView(users: users)
                        .fixedSize()
                }
            }
        }
    }

    // MARK: - Private

    @State private var newestViewedMessage: ParraChannelManager.ChannelInfo.ViewedMessage?

    @Environment(\.parraAuthState) private var authState

    @Environment(\.parraComponentFactory) private var componentFactory
    @Environment(\.parraAlertManager) private var alertManager
    @Environment(\.parraTheme) private var theme
    @Environment(\.parraUserEntitlements) private var userEntitlements
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(\.verticalSizeClass) private var verticalSizeClass
    @Environment(\.dismiss) private var dismiss

    @State private var allowSubmission = false
    @State private var isConfirmingLock = false
    @State private var isConfirmingUnlock = false
    @State private var isConfirmingLeave = false
    @State private var isConfirmingArchive = false

    @State private var size = CGSize(
        width: UIScreen.main.bounds.width,
        height: 70 // just a guess
    )

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
        VStack {
            Spacer()
            componentFactory.buildEmptyState(
                config: .default,
                content: contentObserver.content.emptyStateView
            )
            Spacer()
        }
        .frame(
            maxWidth: .infinity,
            maxHeight: .infinity
        )
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

    private var showCommentBar: Bool {
        if contentObserver.channel.hasMemberRole(
            authState.user,
            role: .admin
        ) {
            // Admins always see the add message bar
            return true
        }

        return contentObserver.channel.status == .active
    }

    @ViewBuilder
    private func addCommentBar(
        with proxy: ScrollViewProxy
    ) -> some View {
        AddCommentBarView(
            allowSubmission: $allowSubmission
        ) { text in
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
            VStack(spacing: 0) {
                if contentObserver.channel.status == .locked {
                    HStack {
                        Spacer()

                        componentFactory.buildLabel(
                            content: ParraLabelContent(
                                text: "This conversation has ended",
                                icon: .symbol("exclamationmark.circle")
                            ),
                            localAttributes: .default(
                                with: .callout,
                                alignment: .center
                            )
                        )

                        Spacer()
                    }
                    .padding()
                    .background(theme.palette.secondaryBackground)
                    .shadow(
                        color: theme.palette.secondaryBackground.opacity(0.7),
                        radius: 4,
                        x: 0,
                        y: 2
                    )
                    .mask(Rectangle().padding(.bottom, -20))
                }

                ScrollView {
                    messageStack
                }
                .scrollDismissesKeyboard(.interactively)
                .upsideDown()
                // A limited number of placeholder cells will be generated.
                // Don't allow scrolling past them while loading.
                .scrollDisabled(
                    contentObserver.messagePaginator.isShowingPlaceholders
                )
                .contentMargins(
                    [.top, .bottom],
                    EdgeInsets(
                        top: showCommentBar ? contentPadding.bottom / 2 + size
                            .height : 44,
                        leading: 0,
                        bottom: contentPadding.bottom / 2,
                        trailing: 0
                    ),
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
                // must keep so that the add message bar stays on the bottom
                // when in the empty state
                .frame(
                    maxWidth: .infinity,
                    maxHeight: .infinity
                )
            }
            .overlay(alignment: .bottom) {
                if showCommentBar {
                    addCommentBar(
                        with: proxy
                    )
                    .onGeometryChange(
                        for: CGSize.self
                    ) { geometry in
                        return geometry.size
                    } action: { newValue in
                        size = newValue
                    }
                }
            }
            .ignoresSafeArea(
                .container,
                edges: showCommentBar ? [] : [.bottom]
            )
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
