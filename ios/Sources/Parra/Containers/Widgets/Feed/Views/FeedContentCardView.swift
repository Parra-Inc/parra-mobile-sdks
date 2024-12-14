//
//  FeedContentCardView.swift
//  Parra
//
//  Created by Mick MacCallum on 9/25/24.
//

import SwiftUI

struct FeedContentCardView: View {
    // MARK: - Internal

    let contentCard: ParraContentCard
    let containerGeometry: GeometryProxy
    let spacing: CGFloat
    let performActionForFeedItemData: (_ feedItemData: ParraFeedItemData) -> Void

    var body: some View {
        Button(action: {
            if let message = contentCard.action?.confirmationMessage, !message.isEmpty {
                isConfirmationPresented = true
            } else {
                performActionForFeedItemData(
                    .contentCard(contentCard)
                )
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

    @State private var isConfirmationPresented: Bool = false

    @Environment(\.parraComponentFactory) private var componentFactory
    @Environment(\.parraTheme) private var parraTheme
    @Environment(\.redactionReasons) private var redactionReasons
    @Environment(\.colorScheme) private var colorScheme

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
                    config: ParraImageConfig(contentMode: .fill),
                    content: ParraAsyncImageContent(
                        content,
                        preferredThumbnailSize: .md
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

    private var topBar: some View {
        HStack(alignment: .top) {
            if let badge = contentCard.badge, redactionReasons.isEmpty {
                componentFactory.buildLabel(
                    text: badge,
                    localAttributes: ParraAttributes.Label(
                        text: ParraAttributes.Text(
                            style: .caption2,
                            color: colorScheme == .dark
                                ? palette.primaryText.shade950.toParraColor()
                                : palette.primaryText.shade200.toParraColor(),
                            alignment: .leading
                        ),
                        cornerRadius: .full,
                        padding: .custom(
                            EdgeInsets(vertical: 0, horizontal: 8)
                        ),
                        background: palette.secondary
                            .toParraColor()
                            .opacity(0.8),
                        frame: .fixed(
                            .init(height: 20, alignment: .leading)
                        )
                    )
                )
            }

            Spacer()

            if hasAction && redactionReasons.isEmpty {
                ZStack(alignment: .center) {
                    Color(palette.secondaryChipBackground.toParraColor())
                        .frame(width: 20, height: 20)
                        .clipShape(
                            .circle,
                            style: .init(eoFill: true, antialiased: true)
                        )

                    componentFactory.buildImage(
                        content: .symbol("link.circle.fill", .hierarchical),
                        localAttributes: ParraAttributes.Image(
                            tint: palette.secondaryChipText.toParraColor(),
                            background: .clear
                        )
                    )
                    .frame(width: 20, height: 20)
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
                                style: .callout,
                                color: palette.primaryText.toParraColor(),
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
                                style: .callout,
                                color: palette.secondaryText.toParraColor(),
                                alignment: .leading
                            )
                        )
                    )
                    .lineLimit(3)
                    .truncationMode(.tail)
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
                            .black.opacity(0.3),
                            .black.opacity(0.7),
                            .black.opacity(0.7)
                        ]
                    ),
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
        }
    }
}
