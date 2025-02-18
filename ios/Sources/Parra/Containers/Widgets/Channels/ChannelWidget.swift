//
//  ChannelWidget.swift
//  Parra
//
//  Created by Mick MacCallum on 2/13/25.
//

import SwiftUI

// struct FlippedUpsideDown: ViewModifier {
//    func body(content: Content) -> some View {
//        content
//            .rotationEffect(.pi)
//            .scaleEffect(x: -1, y: 1, anchor: .center)
//    }
// }
//
// extension View{
//    func flippedUpsideDown() -> some View{
//        self.modifier(FlippedUpsideDown())
//    }
// }

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
        .onAppear {
            contentObserver.loadInitialMessages()
        }
//        .navigationTitle(config.navigationTitle)
        .navigationBarTitleDisplayMode(.inline)
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

                    ChannelMemberListHeaderView(users: users)
                }
            }
        }
    }

    func scrollView(
        with contentPadding: EdgeInsets
    ) -> some View {
        ScrollViewReader { proxy in
            ScrollView {
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
                    }
                }

//                VStack(spacing: 0) {
//                    .redacted(
//                        when: contentObserver.commentPaginator.isShowingPlaceholders
//                    )
//                    .emptyPlaceholder(items) {
//                        if !contentObserver.commentPaginator.isLoading {
//                            componentFactory.buildEmptyState(
//                                config: .default,
//                                content: contentObserver.content.emptyStateView
//                            )
//                            .frame(
//                                minHeight: geometry.size
//                                    .height - headerHeight - footerHeight
//                            )
//                            .layoutPriority(1)
//                        } else {
//                            EmptyView()
//                        }
//                    }
//                    .errorPlaceholder(contentObserver.commentPaginator.error) {
//                        componentFactory.buildEmptyState(
//                            config: .errorDefault,
//                            content: contentObserver.content.errorStateView
//                        )
//                        .frame(
//                            minHeight: geometry.size.height - headerHeight - footerHeight
//                        )
//                        .layoutPriority(1)
//                    }
//
//                    Spacer()
//
//                    if contentObserver.commentPaginator.isLoading {
//                        VStack(alignment: .center) {
//                            ProgressView()
//                        }
//                        .frame(maxWidth: .infinity)
//                        .padding(contentPadding)
//                    }
//
//                    AnyView(config.footerViewBuilder())
//                        .layoutPriority(10)
//                        .modifier(SizeCalculator())
//                        .onPreferenceChange(SizePreferenceKey.self) { size in
//                            footerHeight = size.height
//                        }
//                }
//                .frame(
//                    minHeight: geometry.size.height
//                )
            }
            .overlay(alignment: .bottom) {
                AddCommentBarView { text in
                    guard let user = authState.user else {
                        Logger.error("Tried to submit a comment without a user")

                        return false
                    }

                    if !userEntitlements.hasEntitlement(
                        for: contentObserver.requiredEntitlement
                    ) {
                        Task { @MainActor in
                            await UIApplication.dismissKeyboard()
                        }

                        DispatchQueue.main.asyncAfter(
                            deadline: .now() + 0.1
                        ) {
                            isShowingPaywall = true
                        }
                    } else {
                        withAnimation {
                            do {
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
                            } catch {
                                alertManager
                                    .showErrorToast(
                                        title: "Error sending message",
                                        userFacingMessage: "Something went wrong sending that message. Please try again.",
                                        underlyingError: error
                                    )
                            }
                        }

                        return true
                    }

                    return false
                }
            }
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
            .refreshable {
                contentObserver.refresh()
            }
            .frame(
                maxWidth: .infinity,
                maxHeight: .infinity
            )
        }
    }

    // MARK: - Private

    @Environment(\.parraAuthState) private var authState

    @State private var isShowingPaywall = false

    @Environment(\.parraComponentFactory) private var componentFactory
    @Environment(\.parraAlertManager) private var alertManager
    @Environment(\.parraTheme) private var parraTheme
    @Environment(\.parraUserEntitlements) private var userEntitlements
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(\.verticalSizeClass) private var verticalSizeClass
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
