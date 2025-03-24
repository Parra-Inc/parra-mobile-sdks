//
//  ChannelMessageAttachmentsView.swift
//  Parra
//
//  Created by Mick MacCallum on 3/20/25.
//

import SwiftUI

struct ChannelMessageAttachmentsView: View {
    // MARK: - Internal

    var attachments: [MessageAttachment]

    var body: some View {
        content
            .applyCornerRadii(size: .xl, from: theme)
            .sheet(isPresented: $isShowingFullScreen) {
                NavigationStack {
                    FullScreenGalleryView(
                        photos: images,
                        selectedPhoto: $selectedPhoto
                    )
                }
                .transition(.opacity)
            }
    }

    // MARK: - Private

    @State private var selectedPhoto: ParraImageAsset?
    @State private var isShowingFullScreen = false

    @Environment(\.parraTheme) private var theme
    @Environment(\.parraComponentFactory) private var componentFactory

    private var images: [ParraImageAsset] {
        return attachments.compactMap { attachment in
            if let image = attachment.image {
                return image
            }

            return nil
        }
    }

    @ViewBuilder private var content: some View {
        if images.isEmpty {
            EmptyView()
        } else if images.count == 1 {
            renderOne(asset: images[0])
        } else if images.count == 2 {
            renderTwo(assets: images)
        } else if images.count == 3 {
            renderThree(assets: images)
        } else if images.count == 4 {
            renderFour(assets: images)
        } else {
            renderFive(assets: images)
        }
    }

    @ViewBuilder
    private func renderSquareImage(
        for asset: ParraImageAsset
    ) -> some View {
        CellButton {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                selectedPhoto = asset
                isShowingFullScreen = true
            }
        } label: {
            Color.clear
                .aspectRatio(1, contentMode: .fill)
                .overlay(
                    componentFactory.buildAsyncImage(
                        config: ParraAsyncImageConfig(
                            contentMode: .fill,
                            showLoadingIndicator: false
                        ),
                        content: .init(
                            asset,
                            preferredThumbnailSize: .lg
                        )
                    )
                )
                .clipShape(.rect)
        }
        .id("message-attachment-button-\(asset.id)")
        .clipped()
    }

    @ViewBuilder
    private func renderOne(
        asset: ParraImageAsset
    ) -> some View {
        CellButton {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                selectedPhoto = asset
                isShowingFullScreen = true
            }
        } label: {
            componentFactory.buildAsyncImage(
                config: ParraAsyncImageConfig(
                    showLoadingIndicator: false
                ),
                content: .init(
                    asset,
                    preferredThumbnailSize: .lg
                )
            )
        }
        .id("message-attachment-button-\(asset.id)")
    }

    @ViewBuilder
    private func renderTwo(
        assets: [ParraImageAsset]
    ) -> some View {
        HStack(
            spacing: ChannelMessageBubble.Constant.imageSpacing
        ) {
            ForEach(assets) { asset in
                renderSquareImage(for: asset)
            }
        }
        .clipped()
    }

    @ViewBuilder
    private func renderThreeInRow(
        assets: [ParraImageAsset],
        remainingCount: Int
    ) -> some View {
        HStack(
            spacing: ChannelMessageBubble.Constant.imageSpacing
        ) {
            ForEach(assets.indexed(), id: \.element) { index, asset in
                renderSquareImage(for: asset)
                    .overlay {
                        if index == assets.count - 1 && remainingCount > 0 {
                            ZStack {
                                Color.black.opacity(0.5)
                                    .frame(
                                        maxWidth: .infinity,
                                        maxHeight: .infinity
                                    )

                                Text("+\(remainingCount)")
                                    .font(.title2)
                                    .bold()
                                    .foregroundStyle(.white)
                            }
                            .allowsHitTesting(false)
                        }
                    }
            }
        }
        .clipped()
    }

    @ViewBuilder
    private func renderThree(
        assets: [ParraImageAsset]
    ) -> some View {
        HStack(
            spacing: ChannelMessageBubble.Constant.imageSpacing
        ) {
            renderSquareImage(for: assets[0])
                .containerRelativeFrame(
                    .horizontal,
                    alignment: .leading
                ) { length, _ in
                    let constants = ChannelMessageBubble.Constant.self
                    let availableWidth = length - constants.gutter * 2 - constants
                        .avatarSize.width - constants.avatarSpacing

                    return (availableWidth * 2.0 / 3.0).rounded(
                        .down
                    )
                }
                .clipped()

            VStack(spacing: ChannelMessageBubble.Constant.imageSpacing) {
                renderSquareImage(for: assets[1])
                renderSquareImage(for: assets[2])
            }
            .containerRelativeFrame(
                .horizontal,
                alignment: .trailing
            ) { length, _ in
                let constants = ChannelMessageBubble.Constant.self
                let availableWidth = length - constants.gutter * 2 - constants.avatarSize
                    .width - constants.avatarSpacing

                return (availableWidth / 3.0).rounded(.up)
            }
            .clipped()
        }
    }

    @ViewBuilder
    private func renderFour(
        assets: [ParraImageAsset]
    ) -> some View {
        VStack(
            spacing: ChannelMessageBubble.Constant.imageSpacing
        ) {
            renderTwo(
                assets: Array(assets[0 ... 1])
            )
            renderTwo(
                assets: Array(assets[2 ... 3])
            )
        }
    }

    @ViewBuilder
    private func renderFive(
        assets: [ParraImageAsset]
    ) -> some View {
        VStack(
            spacing: ChannelMessageBubble.Constant.imageSpacing
        ) {
            renderTwo(
                assets: Array(assets[0 ... 1])
            )

            renderThreeInRow(
                assets: Array(assets[2 ... 4]),
                remainingCount: assets.count - 5
            )
        }
    }
}

#Preview {
    ParraViewPreview { _ in
    }
}
