//
//  PhotoWell.swift
//  Parra
//
//  Created by Mick MacCallum on 4/24/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import PhotosUI
import SwiftUI

struct PhotoWell: View {
    // MARK: - Lifecycle

    init(
        stub: ImageAssetStub? = nil,
        onSelectionChanged: ((UIImage) async -> Void)? = nil
    ) {
        let asset: Asset? = if let id = stub?.id, let url = stub?.url {
            Asset(
                id: id,
                url: url
            )
        } else {
            nil
        }

        self.init(
            asset: asset,
            onSelectionChanged: onSelectionChanged
        )
    }

    init(
        asset: Asset? = nil,
        onSelectionChanged: ((UIImage) async -> Void)? = nil
    ) {
        if let asset {
            self.state = .asset(asset)
        } else {
            self.state = .empty
        }

        self.onSelectionChanged = onSelectionChanged
    }

    init(
        image: UIImage,
        onSelectionChanged: ((UIImage) async -> Void)? = nil
    ) {
        self.state = .loaded(image)
        self.onSelectionChanged = onSelectionChanged
    }

    // MARK: - Internal

    // Invoked when user action changes the photo. So not when a pre-provided
    // url finishes loading, or when an image is provided initially.
    var onSelectionChanged: ((UIImage) async -> Void)?

    var failureImage: some View {
        Image(systemName: "person.crop.circle.badge.exclamationmark.fill")
            .resizable()
    }

    var emptyImage: some View {
        Image(systemName: "person.crop.circle.fill")
            .resizable()
    }

    var loadingView: some View {
        ProgressView()
            .progressViewStyle(CircularProgressViewStyle())
            .foregroundStyle(ParraColorSwatch.slate.shade300)
    }

    @ViewBuilder var currentImageElement: some View {
        switch state {
        case .empty, .loadingFromLibrary:
            Image(systemName: "person.crop.circle.fill")
                .resizable()
        case .asset(let asset):
            CachedAsyncImage(
                url: asset.url,
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
        case .error:
            Image(systemName: "person.crop.circle.badge.exclamationmark.fill")
                .resizable()
        }
    }

    var body: some View {
        let palette = themeObserver.theme.palette
        let mainColor = ParraColorSwatch.slate.shade300

        ZStack {
            Button(action: {
                showingConfirmation = true
            }, label: {
                currentImageElement
                    .foregroundStyle(mainColor)
                    .frame(width: 100, height: 100)
                    .background(palette.secondaryBackground)
                    .clipShape(.circle)
                    .overlay( /// apply a rounded border
                        RoundedRectangle(cornerRadius: 100)
                            .stroke(mainColor, lineWidth: 5)
                    )
            })
            .overlay(alignment: .bottomTrailing) {
                if onSelectionChanged != nil {
                    Image(systemName: "photo.circle.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(
                            width: 24,
                            height: 24,
                            alignment: .bottomTrailing
                        )
                        .foregroundStyle(ParraColorSwatch.slate.shade700)
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
        }
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
                    applyNewImage(image)
                }

                showingCamera = false
            }
        }
        .onChange(of: selectedPhoto) {
            Task {
                guard let selectedPhoto else {
                    return
                }

                do {
                    state = .loadingFromLibrary

                    let data = try await selectedPhoto.loadTransferable(
                        type: Data.self
                    )

                    if let data, let image = UIImage(data: data) {
                        applyNewImage(image)
                    } else {
                        throw ParraError.message("Failed to decode image data")
                    }
                } catch {
                    state = .error(error)
                }
            }
        }
    }

    // MARK: - Private

    @State private var state: WellState
    @State private var showingConfirmation = false
    @State private var showingPhotoPicker = false
    @State private var showingCamera = false
    @State private var selectedPhoto: PhotosPickerItem?

    @EnvironmentObject private var themeObserver: ParraThemeObserver

    private func applyNewImage(_ image: UIImage) {
        state = .processing(image)

        Task {
            if let onSelectionChanged {
                await onSelectionChanged(image)
            }

            Task { @MainActor in
                state = .loaded(image)
            }
        }
    }

    @ViewBuilder
    private func imageContent(
        for phase: AsyncImagePhase
    ) -> some View {
        switch phase {
        case .empty:
            ZStack {
                emptyImage

                loadingView
            }
        case .success(let image):
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
            PhotoWell(asset: nil)

            PhotoWell(
                asset: Asset(
                    id: UUID().uuidString,
                    url: URL(string: "https://i.imgur.com/bA8JXya.png")!
                ),
                onSelectionChanged: { _ in }
            )

            PhotoWell(
                image: UIImage(systemName: "swift")!,
                onSelectionChanged: { _ in }
            )
        }
    }
}
