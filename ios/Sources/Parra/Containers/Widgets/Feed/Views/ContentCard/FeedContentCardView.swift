//
//  FeedContentCardView.swift
//  Parra
//
//  Created by Mick MacCallum on 9/25/24.
//

import SwiftUI

struct FeedContentCardView: View {
    // MARK: - Lifecycle

    init(
        contentCard: ParraContentCard,
        feedItem: ParraFeedItem,
        reactionOptions: [ParraReactionOptionGroup]?,
        reactions: [ParraReactionSummary]?,
        containerGeometry: GeometryProxy,
        spacing: CGFloat,
        navigationPath: Binding<NavigationPath>,
        performActionForFeedItemData: @escaping (_: ParraFeedItemData) -> Void,
        api: API
    ) {
        self.contentCard = contentCard
        self.feedItem = feedItem
        self.containerGeometry = containerGeometry
        self.spacing = spacing
        _navigationPath = navigationPath
        self.performActionForFeedItemData = performActionForFeedItemData
        self._reactor = StateObject(
            wrappedValue: Reactor(
                feedItemId: feedItem.id,
                reactionOptionGroups: reactionOptions ?? [],
                reactions: reactions ?? [],
                api: api,
                submitReaction: { api, itemId, reactionOptionId in
                    let response = try await api.addFeedReaction(
                        feedItemId: itemId,
                        reactionOptionId: reactionOptionId
                    )

                    return response.id
                },
                removeReaction: { api, itemId, reactionId in
                    try await api.removeFeedReaction(
                        feedItemId: itemId,
                        reactionId: reactionId
                    )
                }
            )
        )
    }

    // MARK: - Internal

    let contentCard: ParraContentCard
    let feedItem: ParraFeedItem
    let containerGeometry: GeometryProxy
    let spacing: CGFloat
    let performActionForFeedItemData: (_ feedItemData: ParraFeedItemData) -> Void
    @Binding var navigationPath: NavigationPath

    var body: some View {
        Button(action: {
            if let message = contentCard.action?.confirmationMessage, !message.isEmpty {
                isConfirmationPresented = true
            } else {
                if let action = contentCard.action, let form = action.form {
                    feedbackForm = form
                } else {
                    performActionForFeedItemData(
                        .contentCard(contentCard)
                    )
                }
            }
        }) {
            ZStack(alignment: .center) {
                backgroundImage

                VStack(alignment: .leading) {
                    topBar

                    Spacer(minLength: 15)

                    overlayInfo
                }
                .frame(
                    maxWidth: .infinity,
                    maxHeight: .infinity
                )
            }
        }
        .background(parraTheme.palette.secondaryBackground)
        .applyCornerRadii(size: .xl, from: parraTheme)
        .buttonStyle(ContentCardButtonStyle())
        // Required to prevent highlighting the button then dragging the scroll
        // view from causing the button to be pressed.
        .simultaneousGesture(TapGesture())
        .safeAreaPadding(.horizontal, 16)
        .padding(.vertical, spacing)
        .disabled(!hasAction || !redactionReasons.isEmpty)
        .presentParraFeedbackFormWidget(
            with: $feedbackForm
        )
        .onAppear {
            if redactionReasons.isEmpty {
                // Don't track impressions for placeholder cells.
                Parra.default.logEvent(
                    .view(element: "content-card"),
                    [
                        "content_card": contentCard.id
                    ]
                )
            }
        }
        .alert(
            "Open link?",
            isPresented: $isConfirmationPresented
        ) {
            Button(role: .cancel) {} label: {
                Text("Cancel")
            }

            Button {
                performActionForFeedItemData(
                    .contentCard(contentCard)
                )
            } label: {
                Text("Open link")
            }
        } message: {
            Text(contentCard.action?.confirmationMessage ?? "")
        }
    }

    // MARK: - Private

    @State private var feedbackForm: ParraFeedbackFormDataStub?

    @State private var isConfirmationPresented: Bool = false

    @StateObject private var reactor: Reactor

    @Environment(\.parra) private var parra
    @Environment(\.parraComponentFactory) private var componentFactory
    @Environment(\.parraTheme) private var parraTheme
    @Environment(\.redactionReasons) private var redactionReasons
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.displayScale) private var displayScale

    private var hasAction: Bool {
        return contentCard.action != nil
    }

    private var hasOverlayContent: Bool {
        return contentCard.title != nil || contentCard.description != nil
    }

    private var palette: ParraColorPalette {
        return parraTheme.palette
    }

    private var backgroundImage: some View {
        withContent(content: contentCard.background?.image) { content in
            let width = max(containerGeometry.size.width - 16 * 2, 0)
            let minAspect = min(content.size.width / content.size.height, 3.75)
            let minHeight = (width / minAspect).rounded(.down)

            Color.clear.overlay(
                alignment: .center
            ) {
                componentFactory.buildAsyncImage(
                    config: ParraAsyncImageConfig(contentMode: .fill),
                    content: ParraAsyncImageContent(
                        content,
                        preferredThumbnailSize: .recommended(
                            for: CGSize(
                                width: width,
                                height: minHeight
                            ),
                            in: displayScale
                        )
                    )
                )
                .scaledToFill()
            }
            .frame(
                idealWidth: width,
                maxWidth: .infinity,
                minHeight: minHeight,
                maxHeight: .infinity
            )
        }
    }

    @ViewBuilder private var topBar: some View {
        let color = colorScheme == .dark
            ? palette.primaryText.shade950.toParraColor()
            : palette.primaryText.shade200.toParraColor()

        let backgroundColor = palette.secondary.toParraColor().opacity(0.8)

        HStack(alignment: .top) {
            if let badge = contentCard.badge, redactionReasons.isEmpty {
                componentFactory.buildLabel(
                    text: badge,
                    localAttributes: ParraAttributes.Label(
                        text: ParraAttributes.Text(
                            style: .caption2,
                            color: color,
                            alignment: .leading
                        ),
                        cornerRadius: .full,
                        padding: .custom(
                            EdgeInsets(vertical: 0, horizontal: 8)
                        ),
                        background: backgroundColor,
                        frame: .fixed(
                            .init(height: 20, alignment: .leading)
                        )
                    )
                )
            }

            Spacer()

            if let action = contentCard.action, redactionReasons.isEmpty {
                ZStack(alignment: .center) {
                    backgroundColor
                        .frame(width: 20, height: 20)
                        .clipShape(
                            .circle,
                            style: .init(eoFill: true, antialiased: true)
                        )

                    componentFactory.buildImage(
                        content: .symbol(action.symbol, .hierarchical),
                        localAttributes: ParraAttributes.Image(
                            tint: color,
                            background: .clear
                        )
                    )
                    .frame(width: 11, height: 11)
                    .offset(
                        action.type == .feedbackForm ? CGSize(
                            width: -1,
                            height: 1
                        ) : .zero
                    )
                }
            }
        }
        .padding([.top, .horizontal], 14)
    }

    @ViewBuilder private var overlayInfo: some View {
        if hasOverlayContent && redactionReasons.isEmpty {
            VStack(alignment: .leading) {
                withContent(content: contentCard.title) { content in
                    componentFactory.buildLabel(
                        text: content,
                        localAttributes: ParraAttributes.Label(
                            text: ParraAttributes.Text(
                                style: .headline,
                                color: palette.secondaryChipText.toParraColor(),
                                alignment: .leading
                            )
                        )
                    )
                    .lineLimit(2)
                    .truncationMode(.tail)
                }

                withContent(content: contentCard.description) { content in
                    componentFactory.buildLabel(
                        text: content,
                        localAttributes: ParraAttributes.Label(
                            text: ParraAttributes.Text(
                                style: .subheadline,
                                color: palette.secondaryChipText.toParraColor(),
                                alignment: .leading
                            )
                        )
                    )
                    .lineLimit(3)
                    .truncationMode(.tail)
                }

                if reactor.showReactions {
                    let showCommentCount = if let comments = feedItem.comments,
                                              !comments.disabled
                    {
                        true
                    } else {
                        false
                    }

                    VStack {
                        FeedReactionView(
                            feedItem: feedItem,
                            reactor: _reactor,
                            showCommentCount: showCommentCount
                        )
                    }
                    .padding(
                        EdgeInsets(top: 8, leading: 0, bottom: 16, trailing: 0)
                    )
                    .frame(
                        maxWidth: .infinity,
                        alignment: .leading
                    )
                }
            }
            .padding()
            .frame(
                maxWidth: .infinity,
                alignment: .bottomLeading
            )
            .background(
                LinearGradient(
                    gradient: Gradient(
                        colors: [
                            .clear,
                            palette.secondaryChipBackground.toParraColor().opacity(0.7),
                            palette.secondaryChipBackground.toParraColor().opacity(0.85),
                            palette.secondaryChipBackground.toParraColor().opacity(1.0)
                        ]
                    ),
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
        }
    }
}
