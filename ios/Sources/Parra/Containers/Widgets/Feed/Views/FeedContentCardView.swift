//
//  FeedContentCardView.swift
//  Parra
//
//  Created by Mick MacCallum on 9/25/24.
//

import SwiftUI

struct FeedContentCardView: View {
    // MARK: - Internal

    let contentCard: ContentCard
    let containerGeometry: GeometryProxy

    var body: some View {
        Button(action: {
            contentObserver.performActionForContentCard(contentCard)
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
        .safeAreaPadding(.horizontal)
        .padding(.vertical, 8)
        .disabled(!hasAction || !redactionReasons.isEmpty)
        .onAppear {
            if redactionReasons.isEmpty {
                // Don't track impressions for placeholder cells.
                contentObserver.trackContentCardImpression(contentCard)
            }
        }
    }

    // MARK: - Private

    @Environment(\.parraComponentFactory) private var componentFactory
    @Environment(\.parraTheme) private var parraTheme
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.redactionReasons) private var redactionReasons
    @Environment(FeedWidget.ContentObserver.self) private var contentObserver

    private var hasAction: Bool {
        return contentCard.action != nil
    }

    private var hasOverlayContent: Bool {
        return contentCard.title != nil || contentCard.description != nil
    }

    private var palette: ParraColorPalette {
        return parraTheme.darkPalette ?? .defaultDark
    }

    private var backgroundImage: some View {
        withContent(content: contentCard.background?.image) { content in
            let width = containerGeometry.size.width
            let minAspect = min(content.size.width / content.size.height, 3.75)
            let minHeight = (width / minAspect).rounded(.down)

            Color.clear
                .overlay(alignment: .center) {
                    componentFactory.buildAsyncImage(
                        config: ParraImageConfig(contentMode: .fill),
                        content: ParraAsyncImageContent(
                            url: content.url,
                            originalSize: content.size
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
            // Use this if we ever decide to support showing time posted on content cards.
//            componentFactory.buildLabel(
//                text: contentCard.createdAt.timeAgo(
//                    dateTimeStyle: .numeric
//                ),
//                localAttributes: ParraAttributes.Label(
//                    text: ParraAttributes.Text(
//                        style: .caption2,
//                        color: palette.secondaryText.toParraColor(),
//                        alignment: .leading
//                    )
//                )
//            )

            Spacer()

            if hasAction {
                ZStack(alignment: .center) {
                    Color(palette.primaryBackground)
                        .frame(width: 20, height: 20)
                        .clipShape(
                            .circle,
                            style: .init(eoFill: true, antialiased: true)
                        )
                        .opacity(0.8)

                    componentFactory.buildImage(
                        content: .symbol("link.circle.fill", .monochrome)
                    )
                    .frame(width: 20, height: 20)
                }
            }
        }
        .padding([.top, .horizontal], 14)
    }

    @ViewBuilder private var overlayInfo: some View {
        if hasOverlayContent {
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
