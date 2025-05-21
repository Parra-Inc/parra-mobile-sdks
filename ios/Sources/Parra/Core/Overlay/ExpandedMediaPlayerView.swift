//
//  ExpandedMediaPlayerView.swift
//  Parra
//
//  Created by Mick MacCallum on 5/19/25.
//

import SwiftUI

struct ExpandedMediaPlayerView: View {
    // MARK: - Internal

    var media: UrlMedia
    var size: CGSize
    var safeArea: EdgeInsets
    @Binding var expandPlayer: Bool
    var animation: Namespace.ID

    var body: some View {
        VStack(spacing: 0) {
            Capsule()
                .fill(theme.palette.secondaryChipBackground)
                .frame(width: 35, height: 5)
                .padding(.bottom, 12)

            if expandPlayer, let imageUrl = media.imageUrl {
                VStack {
                    componentFactory.buildAsyncImage(
                        content: .init(url: imageUrl),
                        localAttributes: ParraAttributes.AsyncImage(
                            cornerRadius: .md,
                            background: theme.palette.secondaryBackground
                        )
                    )
                    .matchedGeometryEffect(id: "Artwork", in: animation)
                    .aspectRatio(1.0, contentMode: .fill)
                    .frame(
                        width: 270,
                        height: 270
                    )
                }
                .clipped()
            }

            ScrollView {
                VStack(alignment: .leading, spacing: 4) {
                    withContent(content: media.publishedAt) { content in
                        componentFactory.buildLabel(
                            text: content.formatted(
                                date: .long,
                                time: .omitted
                            ),
                            localAttributes: .default(with: .caption)
                        )
                    }

                    componentFactory.buildLabel(
                        text: media.title,
                        localAttributes: .default(with: .headline)
                    )

                    withContent(content: media.author) { content in
                        componentFactory.buildLabel(
                            text: content,
                            localAttributes: .default(with: .subheadline)
                        )
                    }

                    description
                        .padding(.top, 16)
                }
                .padding(.horizontal, 20)
            }
            .padding(.top, 50)
            .padding(.bottom, 20)

            VStack {
                ProgressView(value: player.progress)
                    .progressViewStyle(.linear)

                HStack {
                    componentFactory.buildLabel(
                        text: Duration.seconds(player.currentTime).formatted(
                            .time(pattern: .hourMinuteSecond)
                        ),
                        localAttributes:
                        .default(with: .callout, alignment: .leading)
                    )

                    Spacer()

                    componentFactory.buildLabel(
                        text: Duration.seconds(player.currentTime - player.duration)
                            .formatted(
                                .time(pattern: .hourMinuteSecond)
                            ),
                        localAttributes:
                        .default(with: .callout, alignment: .trailing)
                    )
                }

                HStack(spacing: 24) {
                    Group {
                        Button(
                            "",
                            systemImage: "15.arrow.trianglehead.counterclockwise"
                        ) {
                            player.skipBackward()
                        }

                        RssPlayButton(
                            urlMedia: media
                        )

                        Button("", systemImage: "15.arrow.trianglehead.clockwise") {
                            player.skipForward()
                        }
                    }
                    .font(.largeTitle)
                    .foregroundStyle(Color.primary)
                }
                .padding(.vertical)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 50)
            .safeAreaPadding(.bottom)
        }
        .background(theme.palette.secondaryBackground)
        .frame(
            maxWidth: .infinity,
            maxHeight: .infinity
        )
        .opacity(expandPlayer ? 1 : 0)
        .safeAreaPadding(.top, safeArea.top + 20)
    }

    // MARK: - Private

    @State private var isDescriptionExpanded = false
    @State private var player = MediaPlaybackManager.shared

    @Environment(\.parraTheme) private var theme
    @Environment(\.parraComponentFactory) private var componentFactory

    private var markdownDescription: String? {
        do {
            let document = ParraBasicHtmlParser(rawHTML: media.description)
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
        } else if !media.description.isEmpty {
            DisclosureGroup(
                isExpanded: $isDescriptionExpanded
            ) {
                componentFactory.buildLabel(
                    text: media.description,
                    localAttributes: .default(with: .body)
                )
            } label: {
                EmptyView()
            }
            .disclosureGroupStyle(DescriptionDisclosureStyle())
        }
    }
}
