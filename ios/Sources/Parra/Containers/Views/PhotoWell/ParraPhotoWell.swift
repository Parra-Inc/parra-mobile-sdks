//
//  ParraPhotoWell.swift
//  Parra
//
//  Created by Mick MacCallum on 4/24/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import ImageIO
import PhotosUI
import SwiftUI

public struct ParraPhotoWell: View {
    // MARK: - Lifecycle

    public init(
        asset: ParraImageAsset? = nil,
        size: CGSize = CGSize(width: 100, height: 100),
        onSelectionChanged: ((UIImage?) async -> Void)? = nil
    ) {
        if let asset {
            self.state = .asset(asset)
        } else {
            self.state = .empty
        }

        self.size = size
        self.onSelectionChanged = onSelectionChanged
    }

    public init(
        url: URL? = nil,
        size: CGSize = CGSize(width: 100, height: 100),
        onSelectionChanged: ((UIImage?) async -> Void)? = nil
    ) {
        if let url {
            self.state = .url(url)
        } else {
            self.state = .empty
        }

        self.size = size
        self.onSelectionChanged = onSelectionChanged
    }

    public init(
        image: UIImage,
        size: CGSize = CGSize(width: 100, height: 100),
        onSelectionChanged: ((UIImage?) async -> Void)? = nil
    ) {
        self.state = .loaded(image)
        self.size = size
        self.onSelectionChanged = onSelectionChanged
    }

    // MARK: - Public

    public var body: some View {
        let longSide = max(size.width, size.height)
        let palette = parraTheme.palette
        let mainColor = colorScheme == .light
            ? ParraColorSwatch.gray.shade300
            : ParraColorSwatch.gray.shade500

        ZStack {
            Button(action: {
                showingConfirmation = true
            }, label: {
                currentImageElement
                    .foregroundStyle(mainColor)
                    .frame(width: size.width, height: size.height)
                    .background(palette.secondaryBackground)
                    .clipShape(.circle)
                    .overlay( /// apply a rounded border
                        RoundedRectangle(
                            cornerRadius: longSide
                        )
                        .stroke(mainColor, lineWidth: ceil(longSide * 0.04))
                    )
            })
            .overlay(alignment: .bottomTrailing) {
                let overlayIcon: String? = if case .error = state {
                    "exclamationmark.circle.fill"
                } else if onSelectionChanged != nil, isEnabled {
                    "photo.circle.fill"
                } else {
                    nil
                }

                if let overlayIcon {
                    Image(systemName: overlayIcon)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(
                            width: ceil(longSide * 0.24),
                            height: ceil(longSide * 0.24),
                            alignment: .bottomTrailing
                        )
                        .foregroundStyle(ParraColorSwatch.gray.shade400)
                        .background(palette.secondaryBackground)
                        .clipShape(.circle)
                        .padding(.bottom, 4)
                        .padding(.trailing, 4)
                }
            }

            if state.isLoading {
                loadingView
            }
        }
        .disabled(onSelectionChanged == nil)
        .confirmationDialog("Choose", isPresented: $showingConfirmation) {
            Button("Choose from library") {
                showingConfirmation = false
                showingPhotoPicker = true
            }
            Button("Take a photo") {
                showingConfirmation = false
                showingCamera = true
            }

            switch state {
            case .loaded, .asset:
                Button("Remove profile picture", role: .destructive) {
                    showingConfirmation = false
                    showingRemoveConfirmation = true
                }
            default:
                EmptyView()
            }
        }
        .alert(
            "Remove profile picture",
            isPresented: $showingRemoveConfirmation,
            actions: {
                Button("Delete", role: .destructive) {
                    showingRemoveConfirmation = false

                    removeExistingImage()
                }

                Button("Cancel", role: .cancel) {
                    showingRemoveConfirmation = false
                }
            },
            message: {
                Text("This will delete your existing profile picture")
            }
        )
        .photosPicker(
            isPresented: $showingPhotoPicker,
            selection: $selectedPhoto,
            matching: .all(
                of: [
                    .images,
                    .not(
                        .any(
                            of: [
                                .screenshots, .livePhotos, .depthEffectPhotos,
                                .panoramas
                            ]
                        )
                    )
                ]
            ),
            preferredItemEncoding: .compatible
        )
        .fullScreenCover(isPresented: $showingCamera) {
            CameraView { image in
                if let image {
                    editingImage = image
                }

                showingCamera = false
            }
        }
        .fullScreenCover(
            isPresented: .init(
                get: {
                    return editingImage != nil
                },
                set: { _ in
                }
            )
        ) {
            if let editingImage {
                PhotoCropperView(
                    image: editingImage,
                    maskShape: .circle
                ) { finalImage in
                    if let finalImage {
                        applyNewImage(finalImage)
                    } else {
                        selectedPhoto = nil
                        self.editingImage = nil
                    }
                }
            }
        }
        .onChange(of: selectedPhoto) {
            Task {
                guard let selectedPhoto else {
                    return
                }

                do {
                    let data = try await selectedPhoto.loadTransferable(
                        type: Data.self
                    )

                    if let data, let image = UIImage(data: data) {
                        editingImage = image
                    } else {
                        throw ParraError.message("Failed to decode image data")
                    }
                } catch {
                    state = .error(error)
                    editingImage = nil
                    self.selectedPhoto = nil
                }
            }
        }
    }

    // MARK: - Internal

    let size: CGSize

    // Invoked when user action changes the photo. So not when a pre-provided
    // url finishes loading, or when an image is provided initially. If this is
    // called with a nil image parameter, it means the user has opted to remove
    // their existing photo.
    var onSelectionChanged: ((UIImage?) async -> Void)?

    @Environment(\.isEnabled) var isEnabled

    var failureImage: some View {
        Image(systemName: "network.slash")
            .resizable()
            .frame(width: size.width / 2, height: size.height / 2)
    }

    var emptyImage: some View {
        Image(systemName: "person.crop.circle.fill")
            .resizable()
    }

    var loadingView: some View {
        ProgressView()
            .progressViewStyle(CircularProgressViewStyle())
            .foregroundStyle(ParraColorSwatch.gray.shade300)
    }

    @ViewBuilder var currentImageElement: some View {
        switch state {
        case .empty, .error:
            Image(systemName: "person.crop.circle.fill")
                .resizable()
        case .url(let url):
            CachedAsyncImage(
                url: url,
                urlCache: URLSessionConfiguration.apiConfiguration
                    .urlCache ?? .shared,
                transaction: Transaction(
                    animation: .easeIn(duration: 0.35)
                ),
                content: imageContent
            )
            .scaledToFill()
        case .asset(let asset):
            CachedAsyncImage(
                url: imageUrl(for: asset),
                urlCache: URLSessionConfiguration.apiConfiguration
                    .urlCache ?? .shared,
                transaction: Transaction(
                    animation: .easeIn(duration: 0.35)
                ),
                content: imageContent
            )
            .scaledToFill()
        case .loaded(let image), .processing(let image):
            Image(uiImage: image)
                .resizable()
                .scaledToFill()
        }
    }

    // MARK: - Private

    @State private var state: WellState
    @State private var showingConfirmation = false
    @State private var showingRemoveConfirmation = false
    @State private var showingPhotoPicker = false
    @State private var showingCamera = false
    @State private var selectedPhoto: PhotosPickerItem?
    @State private var editingImage: UIImage?

    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.parraTheme) private var parraTheme
    @Environment(\.displayScale) private var displayScale

    private var thumbSizeFittingSize: ParraImageAssetThumbnailSize {
        return ParraImageAssetThumbnailSize.recommended(
            for: size,
            in: displayScale
        )
    }

    private func imageUrl(for asset: ParraImageAsset) -> URL {
        guard let thumb = asset.thumbnailUrl(for: thumbSizeFittingSize) else {
            return asset.url
        }

        return thumb.0
    }

    private func applyNewImage(_ image: UIImage) {
        guard let stripped = removeExifData(from: image) else {
            state = .error(
                ParraError.message("Failed to remove metadata from image")
            )

            return
        }

        editingImage = nil
        selectedPhoto = nil
        state = .processing(stripped)

        Task {
            if let onSelectionChanged {
                await onSelectionChanged(stripped)
            }

            Task { @MainActor in
                state = .loaded(stripped)
            }
        }
    }

    private func removeExifData(from image: UIImage) -> UIImage? {
        guard let data = image.pngData() else {
            return nil
        }

        guard let source = CGImageSourceCreateWithData(data as CFData, nil) else {
            return nil
        }

        guard let type = CGImageSourceGetType(source) else {
            return nil
        }

        let count = CGImageSourceGetCount(source)
        let mutableData = NSMutableData(data: data)
        guard let destination = CGImageDestinationCreateWithData(
            mutableData,
            type,
            count,
            nil
        ) else {
            return nil
        }
        // Check the keys for what you need to remove
        // As per documentation, if you need a key removed, assign it kCFNull
        let removeExifProperties: CFDictionary = [
            String(kCGImagePropertyExifDictionary): kCFNull,
            String(kCGImagePropertyDepth): kCFNull,
            String(kCGImagePropertyGPSLatitude): kCFNull,
            String(kCGImagePropertyGPSLongitude): kCFNull,
            String(kCGImagePropertyGPSAltitude): kCFNull,
            String(kCGImagePropertyGPSDictionary): kCFNull,
            String(kCGImagePropertyGPSSpeed): kCFNull
        ] as CFDictionary

        for i in 0 ..< count {
            CGImageDestinationAddImageFromSource(
                destination,
                source,
                i,
                removeExifProperties
            )
        }

        guard CGImageDestinationFinalize(destination) else {
            return nil
        }

        return UIImage(data: mutableData as Data)
    }

    private func removeExistingImage() {
        state = .empty

        Task {
            if let onSelectionChanged {
                await onSelectionChanged(nil)
            }
        }
    }

    @ViewBuilder
    private func imageContent(
        for phase: CachedAsyncImagePhase
    ) -> some View {
        switch phase {
        case .empty:
            ZStack {
                emptyImage

                loadingView
            }
        case .success(let image, _):
            image
                .resizable()
                .transition(.opacity)
        case .failure(let error):
            let _ = Logger.error("Error loading image for well", error)

            failureImage
        @unknown default:
            emptyImage
        }
    }
}

#Preview {
    ParraViewPreview { _ in
        VStack {
            ParraPhotoWell(asset: nil)

            ParraPhotoWell(
                asset: ParraImageAsset(
                    id: UUID().uuidString,
                    size: CGSize(width: 640, height: 480),
                    url: URL(string: "https://i.imgur.com/bA8JXya.png")!
                ),
                onSelectionChanged: { _ in }
            )

            ParraPhotoWell(
                image: UIImage(systemName: "swift")!,
                onSelectionChanged: { _ in }
            )

            ParraPhotoWell(
                asset: ParraImageAsset(
                    id: UUID().uuidString,
                    size: CGSize(width: 640, height: 480),
                    url: URL(string: "https://i.imgur.com/invalid-url.png")!
                ),
                onSelectionChanged: { _ in }
            )
        }
    }
}
