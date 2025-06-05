//
//  FeedRssItemDetailHeaderView.swift
//  Parra
//
//  Created by Mick MacCallum on 5/20/25.
//

import SwiftUI

struct FeedRssItemDetailHeaderView: View {
    // MARK: - Lifecycle

    init(
        rssItem: ParraAppRssItemData,
        feedItem: ParraFeedItem,
        containerGeometry: GeometryProxy,
        reactor: StateObject<Reactor>
    ) {
        self.rssItem = rssItem
        self.feedItem = feedItem
        self.containerGeometry = containerGeometry
        self._reactor = reactor
    }

    // MARK: - Internal

    let rssItem: ParraAppRssItemData
    let feedItem: ParraFeedItem
    let containerGeometry: GeometryProxy
    @StateObject var reactor: Reactor

    var body: some View {
        VStack {
            if let imageUrl = rssItem.imageUrl {
                VStack {
                    componentFactory.buildAsyncImage(
                        content: .init(url: imageUrl),
                        localAttributes: ParraAttributes.AsyncImage(
                            cornerRadius: .md,
                            background: theme.palette.secondaryBackground
                        )
                    )
                    .aspectRatio(1.0, contentMode: .fill)
                    .frame(
                        width: 270,
                        height: 270
                    )
                }
                .clipped()
                .padding(.bottom, 34)
            }

            componentFactory.buildLabel(
                text: rssItem.title,
                localAttributes: .default(with: .headline, alignment: .leading)
            )
            .frame(
                maxWidth: .infinity,
                alignment: .leading
            )

            HStack {
                VStack {
                    withContent(content: rssItem.author) { content in
                        componentFactory.buildLabel(
                            text: content,
                            localAttributes: .default(with: .subheadline)
                        )
                        .frame(
                            maxWidth: .infinity,
                            alignment: .leading
                        )
                    }

                    withContent(content: rssItem.publishedAt) { content in
                        componentFactory.buildLabel(
                            text: content.formatted(
                                date: .complete,
                                time: .omitted
                            ),
                            localAttributes: .default(with: .caption)
                        )
                        .frame(
                            maxWidth: .infinity,
                            alignment: .leading
                        )
                    }
                }

                Spacer()

                if let urlMedia = UrlMedia.from(
                    rssItem: rssItem,
                    on: feedItem
                ) {
                    RssPlayButton(
                        urlMedia: urlMedia
                    )
                    .font(.title3)
                    .foregroundStyle(theme.palette.primaryChipText)
                    .padding()
                    .background(theme.palette.primaryChipBackground)
                    .applyCornerRadii(size: .full, from: theme)
                }
            }

            reactions

            mediaStack

            description
        }
        .padding(.top, 20)
        .padding(.horizontal, 20)
    }

    @ViewBuilder var mediaStack: some View {
        if let media = player.currentMedia, media.id == rssItem.id {
            VStack {
                ScrubbingProgressView(
                    progress: .init(
                        get: {
                            return player.progress
                        },
                        set: { value in
                            player.seek(fraction: value)
                        }
                    ),
                    duration: player.duration
                )

                HStack {
                    componentFactory.buildLabel(
                        text: Duration.seconds(player.currentTime).formatted(
                            .time(pattern: .hourMinuteSecond)
                        ),
                        localAttributes: .default(
                            with: .callout,
                            alignment: .leading
                        )
                    )

                    Spacer()

                    componentFactory.buildLabel(
                        text: Duration.seconds(player.currentTime - player.duration)
                            .formatted(
                                .time(pattern: .hourMinuteSecond)
                            ),
                        localAttributes: .default(
                            with: .callout,
                            alignment: .trailing
                        )
                    )
                }

                HStack(spacing: 0) {
                    Menu {
                        ForEach([0.5, 1.0, 1.2, 1.5, 1.8, 2.0], id: \.self) { rate in
                            Button {
                                player.setRate(rate)
                            } label: {
                                Text("\(rate.formatted())x")
                            }
                        }
                    } label: {
                        Text("\(player.playbackRate.formatted())x")
                            .font(.callout)
                            .foregroundStyle(theme.palette.primaryText.toParraColor())
                            .minimumScaleFactor(0.8)
                    }
                    .frame(
                        width: 26,
                        height: 26
                    )

                    Spacer()

                    Button(
                        "",
                        systemImage: "15.arrow.trianglehead.counterclockwise"
                    ) {
                        player.skipBackward()
                    }
                    .font(.largeTitle)
                    .foregroundStyle(theme.palette.primaryText.toParraColor())

                    Spacer()

                    RssPlayButton(
                        urlMedia: media
                    )
                    .foregroundStyle(theme.palette.primaryText.toParraColor())
                    .font(.largeTitle)

                    Spacer()

                    Button("", systemImage: "15.arrow.trianglehead.clockwise") {
                        player.skipForward()
                    }
                    .font(.largeTitle)
                    .foregroundStyle(theme.palette.primaryText.toParraColor())

                    Spacer()

                    DevicePickerView(
                        activeTintColor: theme.palette.primary.toParraColor(),
                        tintColor: theme.palette.primaryText.toParraColor()
                    )
                    .frame(
                        width: 26,
                        height: 26
                    )
                }
                .frame(
                    maxWidth: .infinity
                )
                .padding(.top, 24)
            }
            .frame(
                maxWidth: .infinity
            )
            .padding(.vertical, 32)
        }
    }

    @ViewBuilder var reactions: some View {
        if reactor.showReactions {
            VStack {
                FeedReactionView(
                    feedItem: feedItem,
                    reactor: _reactor,
                    showCommentCount: false
                )
            }
            .padding(
                .padding(top: 8, leading: 0, bottom: 8, trailing: 0)
            )
            .frame(
                maxWidth: .infinity,
                alignment: .leading
            )
        }
    }

    // MARK: - Private

    @Environment(\.parraTheme) private var theme
    @Environment(\.parraComponentFactory) private var componentFactory

    @State private var isDescriptionExpanded = false
    @State private var player = MediaPlaybackManager.shared

    private var markdownDescription: String? {
        do {
            let document = ParraBasicHtmlParser(
                rawHTML: rssItem.description
            )

            try document.parse()

            return try document.asMarkdown()
        } catch {
            ParraLogger.error("Error converting description to markdown", error)

            return nil
        }
    }

    @ViewBuilder private var description: some View {
        if let markdownDescription, let attr = try? AttributedString(
            markdown: markdownDescription,
            options: AttributedString.MarkdownParsingOptions(
                allowsExtendedAttributes: true,
                interpretedSyntax: .inlineOnlyPreservingWhitespace,
                failurePolicy: .returnPartiallyParsedIfPossible
            )
        ) {
            ViewThatFits(in: .vertical) {
                Text(attr)
                    .applyTextAttributes(
                        .default(with: .body),
                        using: theme
                    )
                    .textSelection(.enabled)

                DisclosureGroup(
                    isExpanded: $isDescriptionExpanded
                ) {
                    Text(attr)
                        .applyTextAttributes(
                            .default(with: .body),
                            using: theme
                        )
                        .textSelection(.enabled)
                } label: {
                    EmptyView()
                }
                .disclosureGroupStyle(DescriptionDisclosureStyle())
            }
        } else if !rssItem.description.isEmpty {
            DisclosureGroup(
                isExpanded: $isDescriptionExpanded
            ) {
                componentFactory.buildLabel(
                    text: rssItem.description,
                    localAttributes: .default(with: .body)
                )
            } label: {
                EmptyView()
            }
            .disclosureGroupStyle(DescriptionDisclosureStyle())
        }
    }
}
