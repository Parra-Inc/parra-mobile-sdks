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
        maxToDisplay: Int = 3,
        requiredEntitlement: ParraEntitlement? = nil,
        attemptUnlock: (() async -> Void)? = nil,
        didSelectAsset: ((ParraImageAsset) -> Void)? = nil
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
        case single(ParraImageAsset)
        case doubleSquare(ParraImageAsset, ParraImageAsset)
        case doubleRectangle(ParraImageAsset, ParraImageAsset)
        case verticalMultiple(ParraImageAsset, [ParraImageAsset])
        case horizontalMultiple(ParraImageAsset, [ParraImageAsset])
        case none

        // MARK: - Internal

        var allImages: [ParraImageAsset] {
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
                NavigationStack {
                    FullScreenGalleryView(
                        photos: layout.allImages,
                        selectedPhoto: $selectedPhoto
                    )
                }
                .transition(.opacity)
            }
    }

    var paywalled: Bool {
        requiredEntitlement != nil
    }

    @ViewBuilder
    func renderSingle(
        _ image: ParraImageAsset
    ) -> some View {
        let width = max(
            containerGeometry.size.width - outerSpacing * 2,
            0.0
        )

        let height = max(
            (image.size.height / image.size.width) * width,
            0.0
        )

        renderImageButton(
            for: image,
            size: CGSize(width: width, height: height)
        )
        .frame(
            width: width,
            height: height
        )
    }

    @ViewBuilder
    func renderDouble(
        _ leftImage: ParraImageAsset,
        _ rightImage: ParraImageAsset,
        _ width: CGFloat,
        _ height: CGFloat
    ) -> some View {
        HStack(spacing: innerSpacing) {
            renderImageButton(
                for: leftImage,
                size: CGSize(width: width, height: height)
            )
            .clipped()
            .frame(
                width: width,
                height: min(width * 2, height)
            )

            renderImageButton(
                for: rightImage,
                size: CGSize(width: width, height: height)
            )
            .clipped()
            .frame(
                width: width,
                height: min(width * 2, height)
            )
        }
    }

    @ViewBuilder
    func renderDoubleSquare(
        _ leftImage: ParraImageAsset,
        _ rightImage: ParraImageAsset
    ) -> some View {
        let width = max(
            (containerGeometry.size.width - outerSpacing * 2 - innerSpacing) / 2,
            0.0
        )

        renderDouble(leftImage, rightImage, width, width)
    }

    @ViewBuilder
    func renderDoubleRectangle(
        _ leftImage: ParraImageAsset,
        _ rightImage: ParraImageAsset
    ) -> some View {
        let width = max(
            (containerGeometry.size.width - outerSpacing * 2 - innerSpacing) / 2,
            0.0
        )

        let height = max(
            (leftImage.size.height / leftImage.size.width) * width,
            0.0
        )

        renderDouble(leftImage, rightImage, width, height)
    }

    @ViewBuilder
    func renderMultipleVertical(
        _ leftImage: ParraImageAsset,
        _ otherImages: [ParraImageAsset]
    ) -> some View {
        let imagesBeforeFold = otherImages.prefix(maxToDisplay - 1)
        let requiresShowMore = otherImages.count > maxToDisplay - 1
        let width = max(
            (containerGeometry.size.width - outerSpacing * 2 - innerSpacing) / 2,
            0.0
        )

        let height = max(
            CGFloat(imagesBeforeFold.count) * width + CGFloat(
                imagesBeforeFold.count - 1
            ) * innerSpacing,
            0.0
        )

        HStack(spacing: innerSpacing) {
            renderImageButton(
                for: leftImage,
                size: CGSize(width: width, height: height)
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
                            amount: otherImages.count - imagesBeforeFold.count,
                            size: CGSize(width: width, height: height)
                        )
                        .id(image.id)
                        .frame(
                            width: width,
                            height: width
                        )
                        .clipped()
                    } else {
                        renderImageButton(
                            for: image,
                            size: CGSize(width: width, height: height)
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
        _ topImage: ParraImageAsset,
        _ otherImages: [ParraImageAsset]
    ) -> some View {
        let imagesBeforeFold = otherImages.prefix(maxToDisplay - 1)
        let requiresShowMore = otherImages.count > maxToDisplay - 1
        let width = max(
            containerGeometry.size.width - outerSpacing * 2,
            0.0
        )
        let height = max(
            (topImage.size.height / topImage.size.width) * width,
            0.0
        )
        let smallSize = max(
            (width - CGFloat(imagesBeforeFold.count - 1) * innerSpacing) /
                CGFloat(imagesBeforeFold.count),
            0.0
        )

        VStack(spacing: innerSpacing) {
            renderImageButton(
                for: topImage,
                size: CGSize(width: width, height: height)
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
                            amount: otherImages.count - imagesBeforeFold.count,
                            size: CGSize(width: width, height: height)
                        )
                        .id(image.id)
                        .frame(
                            width: smallSize,
                            height: smallSize
                        )
                        .clipped()
                    } else {
                        renderImageButton(
                            for: image,
                            size: CGSize(width: width, height: height)
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
    private let didSelectAsset: ((ParraImageAsset) -> Void)?
    private let attemptUnlock: (() async -> Void)?

    @State private var selectedPhoto: ParraImageAsset?
    @State private var isShowingFullScreen = false
    @State private var unlockingAsset: ParraImageAsset?

    @Environment(\.parraComponentFactory) private var componentFactory
    @Environment(\.parraTheme) private var parraTheme

    private func renderImageButton(
        for image: ParraImageAsset,
        size: CGSize
    ) -> some View {
        Button {
            handleSelectedImage(image)
        } label: {
            Color.clear.background {
                componentFactory.buildAsyncImage(
                    config: ParraAsyncImageConfig(
                        contentMode: .fill,
                        blurContent: paywalled,
                        showFailureIndicator: false
                    ),
                    content: ParraAsyncImageContent(
                        image,
                        preferredThumbnailSize: .recommended(for: size)
                    )
                )
                .equatable()
                .overlay(alignment: .center) {
                    renderPaywallOverlay(for: image)
                }
            }
        }
        // Required to prevent highlighting the button then dragging the scroll
        // view from causing the button to be pressed.
        .simultaneousGesture(TapGesture())
        .buttonStyle(ContentCardButtonStyle())
        .disabled(unlockingAsset != nil)
    }

    private func renderSelectMoreButton(
        for image: ParraImageAsset,
        amount: Int,
        size: CGSize
    ) -> some View {
        Button {
            handleSelectedImage(image)
        } label: {
            Color.clear.background {
                ZStack {
                    componentFactory.buildAsyncImage(
                        config: ParraAsyncImageConfig(
                            contentMode: .fill,
                            blurContent: paywalled,
                            showFailureIndicator: false
                        ),
                        content: ParraAsyncImageContent(
                            image,
                            preferredThumbnailSize: .recommended(for: size)
                        )
                    )
                    .equatable()

                    if !paywalled {
                        Color.black.opacity(0.5)

                        Text("+\(amount) more")
                            .font(.callout)
                            .bold()
                            .foregroundStyle(.white)
                    }
                }
                .overlay(alignment: .center) {
                    renderPaywallOverlay(for: image)
                }
            }
        }
        // Required to prevent highlighting the button then dragging the scroll
        // view from causing the button to be pressed.
        .simultaneousGesture(TapGesture())
        .disabled(unlockingAsset != nil)
        .buttonStyle(ContentCardButtonStyle())
    }

    @ViewBuilder
    private func renderPaywallOverlay(
        for image: ParraImageAsset
    ) -> some View {
        if let requiredEntitlement {
            VStack(spacing: 6) {
                if image == unlockingAsset {
                    ProgressView()
                        .controlSize(.large)
                        .foregroundColor(parraTheme.palette.secondary.toParraColor())
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
        _ image: ParraImageAsset
    ) {
        if paywalled {
            if let attemptUnlock {
                Task { @MainActor in
                    unlockingAsset = image

                    await attemptUnlock()

                    unlockingAsset = nil
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
