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

    init(url: URL? = nil) {
        if let url {
            self.state = .url(url)
        } else {
            self.state = .empty
        }
    }

    init(image: UIImage) {
        self.state = .loaded(image)
    }

    // MARK: - Internal

    // Invoked when user action changes the photo. So not when a pre-provided
    // url finishes loading, or when an image is provided initially.
    var onSelectionChanged: ((UIImage?) -> Void)?

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
        case .url(let url):
            AsyncImage(
                url: url,
                transaction: Transaction(
                    animation: .easeIn(duration: 0.35)
                ),
                content: imageContent
            )
        case .loaded(let image):
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
                Image(systemName: "photo.circle.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 24, height: 24, alignment: .bottomTrailing)
                    .foregroundStyle(ParraColorSwatch.slate.shade700)
                    .background(palette.secondaryBackground)
                    .clipShape(.circle)
                    .padding(.bottom, 4)
                    .padding(.trailing, 4)
            }

            if state.isLoading {
                loadingView
            }
        }
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
            matching: .any(
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
        .sheet(isPresented: $showingCamera) {
            CameraView()
        }
        .onChange(of: selectedPhoto) {
            Task {
                guard let selectedPhoto else {
                    onSelectionChanged?(nil)

                    return
                }

                do {
                    state = .loadingFromLibrary

                    let data = try await selectedPhoto.loadTransferable(
                        type: Data.self
                    )

                    if let data, let image = UIImage(data: data) {
                        state = .loaded(image)

                        onSelectionChanged?(image)
                    } else {
                        throw ParraError.message("Failed to decode image data")
                    }
                } catch {
                    state = .error(error)

                    onSelectionChanged?(nil)
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
            PhotoWell()

            PhotoWell(url: URL(string: "https://i.imgur.com/bA8JXya.png")!)

            PhotoWell(image: UIImage(systemName: "swift")!)
        }
    }
}
