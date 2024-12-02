//
//  CreatorUpdateAttachmentsView.swift
//  Parra
//
//  Created by Mick MacCallum on 10/26/24.
//

import SwiftUI

struct CreatorUpdateAttachmentsView: View {
    // MARK: - Lifecycle

    init(
        attachments: [ParraCreatorUpdateAttachmentStub],
        containerGeometry: GeometryProxy,
        innerSpacing: CGFloat = 4.0,
        outerSpacing: CGFloat = 16.0,
        maxToDisplay: Int = 4,
        requiredEntitlement: ParraEntitlement? = nil,
        attemptUnlock: (() async -> Void)? = nil,
        didSelectAsset: ((ParraImageAssetStub) -> Void)? = nil
    ) {
        self.containerGeometry = containerGeometry
        self.innerSpacing = innerSpacing
        self.outerSpacing = outerSpacing
        self.maxToDisplay = maxToDisplay
        self.requiredEntitlement = requiredEntitlement
        self.attemptUnlock = attemptUnlock
        self.didSelectAsset = didSelectAsset

        let images = attachments.compactMap { attachment in
            attachment.image
        }

        if images.isEmpty {
            self.layout = .none
        } else if images.count == 1 {
            self.layout = .single(images[0])
        } else if images.count == 2 {
            let image1 = images[0]
            let image2 = images[1]

            self.layout = if image1.size.width >= image1.size.height {
                .doubleSquare(image1, image2)
            } else {
                .doubleRectangle(image1, image2)
            }
        } else {
            let image1 = images[0]
            let otherImages = Array(images.dropFirst())

            self.layout = if image1.size.width >= image1.size.height {
                .horizontalMultiple(image1, otherImages)
            } else {
                .verticalMultiple(image1, otherImages)
            }
        }
    }

    // MARK: - Internal

    enum Layout {
        case single(ParraImageAssetStub)
        case doubleSquare(ParraImageAssetStub, ParraImageAssetStub)
        case doubleRectangle(ParraImageAssetStub, ParraImageAssetStub)
        case verticalMultiple(ParraImageAssetStub, [ParraImageAssetStub])
        case horizontalMultiple(ParraImageAssetStub, [ParraImageAssetStub])
        case none

        // MARK: - Internal

        var allImages: [ParraImageAssetStub] {
            switch self {
            case .single(let image):
                return [image]
            case .doubleSquare(let image1, let image2):
                return [image1, image2]
            case .doubleRectangle(let image1, let image2):
                return [image1, image2]
            case .verticalMultiple(let image, let images):
                return [image] + images
            case .horizontalMultiple(let image, let images):
                return [image] + images
            case .none:
                return []
            }
        }
    }

    @ViewBuilder var content: some View {
        switch layout {
        case .single(let image):
            renderSingle(image)
        case .doubleSquare(let leftImage, let rightImage):
            renderDoubleSquare(leftImage, rightImage)
        case .doubleRectangle(let leftImage, let rightImage):
            renderDoubleRectangle(leftImage, rightImage)
        case .verticalMultiple(let leftImage, let otherImages):
            renderMultipleVertical(leftImage, otherImages)
        case .horizontalMultiple(let leftImage, let otherImages):
            renderMultipleHorizontal(leftImage, otherImages)
        case .none:
            renderEmpty()
        }
    }

    var body: some View {
        content
            .background(parraTheme.palette.secondaryBackground.toParraColor())
            .sheet(isPresented: $isShowingFullScreen) {
                FullScreenGalleryView(
                    photos: layout.allImages,
                    selectedPhoto: $selectedPhoto,
                    isShowingFullScreen: $isShowingFullScreen
                )
                .transition(.opacity)
                .presentationDragIndicator(.visible)
                .presentationDetents([.large])
            }
    }

    var paywalled: Bool {
        requiredEntitlement != nil
    }

    @ViewBuilder
    func renderSingle(
        _ image: ParraImageAssetStub
    ) -> some View {
        let width = containerGeometry.size.width - outerSpacing * 2
        let height = (image.size.height / image.size.width) * width

        renderImageButton(
            for: image
        )
        .frame(
            width: width,
            height: height
        )
    }

    @ViewBuilder
    func renderDouble(
        _ leftImage: ParraImageAssetStub,
        _ rightImage: ParraImageAssetStub,
        _ width: CGFloat,
        _ height: CGFloat
    ) -> some View {
        // TODO: Need to define min and max aspect ratios

        HStack(spacing: innerSpacing) {
            renderImageButton(
                for: leftImage
            )
            .clipped()
            .frame(
                width: width,
                height: height
            )

            renderImageButton(
                for: rightImage
            )
            .clipped()
            .frame(
                width: width,
                height: height
            )
        }
    }

    @ViewBuilder
    func renderDoubleSquare(
        _ leftImage: ParraImageAssetStub,
        _ rightImage: ParraImageAssetStub
    ) -> some View {
        let width = (containerGeometry.size.width - outerSpacing * 2 - innerSpacing) / 2

        renderDouble(leftImage, rightImage, width, width)
    }

    @ViewBuilder
    func renderDoubleRectangle(
        _ leftImage: ParraImageAssetStub,
        _ rightImage: ParraImageAssetStub
    ) -> some View {
        let width = (containerGeometry.size.width - outerSpacing * 2 - innerSpacing) / 2
        let height = (leftImage.size.height / leftImage.size.width) * width

        renderDouble(leftImage, rightImage, width, height)
    }

    @ViewBuilder
    func renderMultipleVertical(
        _ leftImage: ParraImageAssetStub,
        _ otherImages: [ParraImageAssetStub]
    ) -> some View {
        let imagesBeforeFold = otherImages.prefix(maxToDisplay - 1)
        let requiresShowMore = otherImages.count > maxToDisplay - 1
        let width = (containerGeometry.size.width - outerSpacing * 2 - innerSpacing) / 2
        let height = CGFloat(imagesBeforeFold.count) * width + CGFloat(
            imagesBeforeFold.count - 1
        ) * innerSpacing

        HStack(spacing: innerSpacing) {
            renderImageButton(
                for: leftImage
            )
            .frame(
                width: width,
                height: height
            )

            VStack(spacing: innerSpacing) {
                ForEach(
                    Array(imagesBeforeFold.enumerated()),
                    id: \.element
                ) { index, image in
                    if index == imagesBeforeFold.count - 1, requiresShowMore {
                        renderSelectMoreButton(
                            for: image,
                            amount: otherImages.count - imagesBeforeFold.count
                        )
                        .id(image.id)
                        .frame(
                            width: width,
                            height: width
                        )
                        .clipped()
                    } else {
                        renderImageButton(
                            for: image
                        )
                        .id(image.id)
                        .frame(
                            width: width,
                            height: width
                        )
                        .clipped()
                    }
                }
            }
        }
    }

    @ViewBuilder
    func renderMultipleHorizontal(
        _ topImage: ParraImageAssetStub,
        _ otherImages: [ParraImageAssetStub]
    ) -> some View {
        let imagesBeforeFold = otherImages.prefix(maxToDisplay - 1)
        let requiresShowMore = otherImages.count > maxToDisplay - 1
        let width = containerGeometry.size.width - outerSpacing * 2
        let height = (topImage.size.height / topImage.size.width) * width
        let smallSize = (width - CGFloat(imagesBeforeFold.count - 1) * innerSpacing) /
            CGFloat(imagesBeforeFold.count)

        VStack(spacing: innerSpacing) {
            renderImageButton(
                for: topImage
            )
            .frame(
                width: width,
                height: height
            )

            HStack(spacing: innerSpacing) {
                ForEach(
                    Array(imagesBeforeFold.enumerated()),
                    id: \.element
                ) { index, image in
                    if index == imagesBeforeFold.count - 1, requiresShowMore {
                        renderSelectMoreButton(
                            for: image,
                            amount: otherImages.count - imagesBeforeFold.count
                        )
                        .id(image.id)
                        .frame(
                            width: smallSize,
                            height: smallSize
                        )
                        .clipped()
                    } else {
                        renderImageButton(
                            for: image
                        )
                        .id(image.id)
                        .frame(
                            width: smallSize,
                            height: smallSize
                        )
                        .clipped()
                    }
                }
            }
        }
    }

    func renderEmpty() -> some View {
        EmptyView()
    }

    // MARK: - Private

    private let containerGeometry: GeometryProxy
    private let layout: Layout
    private let innerSpacing: CGFloat
    private let outerSpacing: CGFloat
    private let maxToDisplay: Int
    private let requiredEntitlement: ParraEntitlement?
    private let didSelectAsset: ((ParraImageAssetStub) -> Void)?
    private let attemptUnlock: (() async -> Void)?

    @State private var selectedPhoto: ParraImageAssetStub?
    @State private var isShowingFullScreen = false
    @State private var isUnlocking = false

    @Environment(\.parraComponentFactory) private var componentFactory
    @Environment(\.parraTheme) private var parraTheme

    private func renderImageButton(
        for image: ParraImageAssetStub
    ) -> some View {
        Button {
            handleSelectedImage(image)
        } label: {
            Color.clear.background {
                componentFactory.buildAsyncImage(
                    config: ParraImageConfig(
                        contentMode: .fill
                    ),
                    content: ParraAsyncImageContent(
                        url: image.url,
                        originalSize: image.size
                    )
                )
                .blur(radius: paywalled ? 10 : 0, opaque: true)
                .overlay(alignment: .center) {
                    renderPaywallOverlay()
                }
            }
        }
        .buttonStyle(ContentCardButtonStyle())
        .disabled(isUnlocking)
    }

    private func renderSelectMoreButton(
        for image: ParraImageAssetStub,
        amount: Int
    ) -> some View {
        Button {
            handleSelectedImage(image)
        } label: {
            Color.clear.background {
                ZStack {
                    componentFactory.buildAsyncImage(
                        config: ParraImageConfig(
                            contentMode: .fill
                        ),
                        content: ParraAsyncImageContent(
                            url: image.url,
                            originalSize: image.size
                        )
                    )

                    Color.black.opacity(0.5)

                    Text("\(amount) more")
                        .font(.callout)
                        .bold()
                        .foregroundStyle(.white)
                }
                .blur(radius: paywalled ? 10 : 0, opaque: true)
                .overlay(alignment: .center) {
                    renderPaywallOverlay()
                }
            }
        }
        .disabled(isUnlocking)
        .buttonStyle(ContentCardButtonStyle())
    }

    @ViewBuilder
    private func renderPaywallOverlay() -> some View {
        if let requiredEntitlement {
            VStack(spacing: 6) {
                if isUnlocking {
                    ProgressView()
                } else {
                    componentFactory.buildImage(
                        content: .symbol("lock.circle"),
                        localAttributes: ParraAttributes.Image(
                            tint: parraTheme.palette.secondary.toParraColor(),
                            size: CGSize(
                                width: 36,
                                height: 36
                            )
                        )
                    )
                }

                componentFactory.buildLabel(
                    text: requiredEntitlement.title,
                    localAttributes: .default(with: .callout)
                )
            }
        }
    }

    private func handleSelectedImage(
        _ image: ParraImageAssetStub
    ) {
        if paywalled {
            Task {
                if let attemptUnlock {
                    isUnlocking = true

                    await attemptUnlock()

                    isUnlocking = false
                }
            }
        } else {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                selectedPhoto = image
                isShowingFullScreen = true
            }

            didSelectAsset?(image)
        }
    }
}

#Preview("Empty") {
    ParraAppPreview {
        GeometryReader { proxy in
            VStack {
                CreatorUpdateAttachmentsView(
                    attachments: [],
                    containerGeometry: proxy
                )
                .padding()
            }
            .background(Color(UIColor.lightGray))
        }
    }
}

#Preview("Single") {
    ParraAppPreview {
        GeometryReader { proxy in
            VStack {
                CreatorUpdateAttachmentsView(
                    attachments: [
                        .validStates()[0]
                    ],
                    containerGeometry: proxy
                )
                .padding()
            }
            .background(Color(UIColor.lightGray))
        }
    }
}

#Preview("Double Square") {
    ParraAppPreview {
        GeometryReader { proxy in
            VStack {
                CreatorUpdateAttachmentsView(
                    attachments: [
                        .validStates()[0],
                        .validStates()[1]
                    ],
                    containerGeometry: proxy
                )
                .padding()
            }
            .background(Color(UIColor.lightGray))
        }
    }
}

#Preview("Double Rectangle") {
    ParraAppPreview {
        GeometryReader { proxy in
            VStack {
                CreatorUpdateAttachmentsView(
                    attachments: [
                        .validStates()[4],
                        .validStates()[3]
                    ],
                    containerGeometry: proxy
                )
                .padding()
            }
            .background(Color(UIColor.lightGray))
        }
    }
}

#Preview("Vertical Multiple") {
    ParraAppPreview {
        GeometryReader { proxy in
            VStack {
                CreatorUpdateAttachmentsView(
                    attachments: [
                        .validStates()[4],
                        .validStates()[3],
                        .validStates()[0],
                        .validStates()[1],
                        .validStates()[2]
                    ],
                    containerGeometry: proxy
                )
                .padding()
            }
            .background(Color(UIColor.lightGray))
        }
    }
}

#Preview("Horizontal Multiple") {
    ParraAppPreview {
        GeometryReader { proxy in
            VStack {
                CreatorUpdateAttachmentsView(
                    attachments: [
                        .validStates()[3],
                        .validStates()[4],
                        .validStates()[0],
                        .validStates()[1],
                        .validStates()[2]
                    ],
                    containerGeometry: proxy
                )
                .padding()
            }
            .background(Color(UIColor.lightGray))
        }
    }
}
